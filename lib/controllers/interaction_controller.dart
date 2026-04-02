import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/interaction_model.dart';

class InteractionController {
  // 🔥 QUAN TRỌNG: Đã sửa tên collection thành 'interactions' đúng như ảnh bạn gửi
  final CollectionReference _ref =
      FirebaseFirestore.instance.collection('interactions');

  // Hàm lấy luồng dữ liệu (Stream) theo loại (rating/comment)
  Stream<List<InteractionModel>> getInteractionsStream(String type) {
    return _ref
        .where('type', isEqualTo: type)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InteractionModel.fromSnapshot(doc))
            .toList());
  }

  // Hàm xóa
  Future<void> deleteInteraction(String docId) async {
    try {
      await _ref.doc(docId).delete();
    } catch (e) {
      rethrow; // Ném lỗi ra để UI xử lý hiển thị thông báo
    }
  }
}
