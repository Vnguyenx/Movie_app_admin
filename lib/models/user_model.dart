import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String photoURL;
  final String userName;
  final String role;
  final DateTime? bannedUntil;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.userName = '',
    required this.photoURL,
    required this.role,
    this.bannedUntil,
    required this.createdAt,
  });

  String get safeName {
    if (displayName.trim().isNotEmpty)
      return displayName; // 1. Ưu tiên Tên hiển thị
    if (userName.trim().isNotEmpty)
      return userName; // 2. Dự phòng Tên đăng nhập
    return email
        .split('@')[0]; // 3. Đường cùng: Lấy phần đầu email (vnguyen@...)
  }

  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};

    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',

      // Đọc userName (nếu DB lưu là 'username' hoặc 'userName')
      userName: data['userName'] ?? data['username'] ?? '',

      photoURL: data['photoURL'] ??
          data['img'] ??
          data['avatar'] ??
          data['photoUrl'] ??
          '',
      role: data['role'] ?? 'user',
      bannedUntil: (data['bannedUntil'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Getter này rất hay, giữ nguyên nhé!
  bool get isBanned {
    if (bannedUntil == null) return false;
    return bannedUntil!.isAfter(DateTime.now());
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'userName': userName,
      'photoUrl': photoURL,
      'role': role,
      'bannedUntil': bannedUntil,
      'createdAt': createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
