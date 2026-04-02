import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserController {
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  // 1. Lấy danh sách users
  Future<List<UserModel>> fetchUsers() async {
    try {
      final snapshot =
          await _userCollection.orderBy('createdAt', descending: true).get();

      return snapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
    } catch (e) {
      print("Lỗi lấy users: $e");
      return [];
    }
  }

  // 2. Thêm user mới (Lưu ý: Chỉ thêm data vào Firestore, không tạo tài khoản Auth thực tế)
  Future<void> addUser(Map<String, dynamic> data) async {
    await _userCollection.add(data);
  }

  // 3. Cập nhật thông tin user
  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _userCollection.doc(id).update(data);
  }

  // 4. Xóa user
  Future<void> deleteUser(String id) async {
    await _userCollection.doc(id).delete();
  }

  // 5. Tìm kiếm & Lọc (Xử lý dưới local cho mượt vì số lượng user admin quản lý thường không quá lớn)
  List<UserModel> applyFilters({
    required List<UserModel> sourceList,
    String query = '',
    String? roleFilter,
  }) {
    return sourceList.where((user) {
      // Lọc theo tên hoặc email
      final matchesQuery =
          user.displayName.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase());

      // Lọc theo Role (nếu có chọn)
      final matchesRole = roleFilter == null || user.role == roleFilter;

      return matchesQuery && matchesRole;
    }).toList();
  }

  // Hàm Ban user trong 7 ngày
  Future<void> banUser7Days(String userId) async {
    final expireDate =
        DateTime.now().add(const Duration(days: 7)); // Cộng thêm 7 ngày
    await _userCollection.doc(userId).update({
      'bannedUntil': expireDate,
    });
  }

  // Hàm Mở khóa ngay lập tức
  Future<void> unbanUser(String userId) async {
    await _userCollection.doc(userId).update({
      'bannedUntil': null, // Xóa mốc thời gian cấm
    });
  }
}
