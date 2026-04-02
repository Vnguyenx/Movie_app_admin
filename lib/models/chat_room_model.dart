// Model cho danh sách phòng chat bên ngoài
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id; // Chính là userId
  final String userEmail;
  final String lastMessage;
  final DateTime lastTime;
  final int unreadCount;

  ChatRoom({
    required this.id,
    required this.userEmail,
    required this.lastMessage,
    required this.lastTime,
    this.unreadCount = 0,
  });

  factory ChatRoom.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      id: doc.id,
      userEmail: data['userEmail'] ?? 'Unknown User',
      lastMessage: data['lastMessage'] ?? '',
      lastTime: data['lastTime'] != null
          ? (data['lastTime'] as Timestamp).toDate()
          : DateTime.now(),
      unreadCount: data['unreadAdminCount'] ?? 0,
    );
  }
}
