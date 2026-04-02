import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/chat_room_model.dart';

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Lấy danh sách phòng chat
  Stream<List<ChatRoom>> getChatRooms() {
    return _firestore
        .collection('chats')
        .orderBy('lastTime', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatRoom.fromSnapshot(doc)).toList());
  }

  // 2. Lấy chi tiết tin nhắn (Giữ nguyên)
  Stream<List<ChatMessage>> getMessages(String userId) {
    return _firestore
        .collection('chats')
        .doc(userId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatMessage.fromSnapshot(doc)).toList());
  }

  // 3. Admin gửi tin nhắn trả lời (Đã tối ưu)
  Future<void> sendAdminMessage(String userId, String text) async {
    final timestamp = FieldValue.serverTimestamp();

    // A. Lưu tin nhắn
    await _firestore
        .collection('chats')
        .doc(userId)
        .collection('messages')
        .add({
      'text': text,
      'isAdmin': true,
      'createdAt': timestamp,
    });

    // B. Cập nhật phòng chat
    // Khi Admin nhắn, nghĩa là Admin đang xem -> unreadAdminCount về 0
    // Và tăng unreadUserCount lên 1 để báo cho User biết
    await _firestore.collection('chats').doc(userId).set({
      'lastMessage': "Admin: $text",
      'lastTime': timestamp,
      'unreadAdminCount': 0, // Reset về 0
      'unreadUserCount': FieldValue.increment(1), // Tăng báo hiệu cho User
    }, SetOptions(merge: true));
  }

  // 4. Xóa chat (Giữ nguyên)
  Future<void> deleteChatRoom(String userId) async {
    final messagesRef =
        _firestore.collection('chats').doc(userId).collection('messages');
    final snapshots = await messagesRef.get();
    WriteBatch batch = _firestore.batch();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    await _firestore.collection('chats').doc(userId).delete();
  }

  // ==========================================
  // PHẦN SỬA ĐỔI QUAN TRỌNG (CÁCH 2 - TÍNH TỔNG)
  // ==========================================

  // 5. Đếm TỔNG SỐ TIN NHẮN chưa đọc
  Stream<int> getUnreadMessagesCount() {
    return _firestore
        .collection('chats')
        .where('unreadAdminCount', isGreaterThan: 0) // Chỉ lấy phòng có tin mới
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (var doc in snapshot.docs) {
        // Cộng dồn số tin chưa đọc của từng phòng
        final data = doc.data();
        final count = data['unreadAdminCount'] as int? ?? 0;
        total += count;
      }
      return total;
    });
  }

  // 6. Đánh dấu đã đọc (Sửa logic set về 0)
  Future<void> markAsRead(String userId) async {
    try {
      await _firestore.collection('chats').doc(userId).update({
        'unreadAdminCount': 0, // Reset biến đếm về 0 thay vì dùng isRead
      });
    } catch (e) {
      print("Lỗi markAsRead: $e");
    }
  }
}
