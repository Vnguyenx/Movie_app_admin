import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../views/users/user_detail_screen.dart';

/// Widget hiển thị một item user trong danh sách
/// Có thể tái sử dụng ở nhiều màn hình khác nhau
class UserListItem extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onUserUpdated; // Callback khi cần refresh data

  const UserListItem({
    super.key,
    required this.user,
    this.onUserUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: _buildAvatar(),
        title: _buildTitle(),
        subtitle: _buildSubtitle(),
        trailing: const Icon(Icons.arrow_right, color: Colors.white24),
        onTap: () => _navigateToDetail(context),
      ),
    );
  }

  /// Xây dựng avatar người dùng
  Widget _buildAvatar() {
    return CircleAvatar(
      backgroundColor: Colors.blueGrey,
      radius: 24,
      // Chỉ load ảnh khi link có dữ liệu (không rỗng)
      foregroundImage: (user.photoURL.trim().isNotEmpty)
          ? NetworkImage(user.photoURL.trim())
          : null,
      // Fix lỗi Crash: Chỉ khai báo hàm lỗi khi CÓ ảnh
      onForegroundImageError: (user.photoURL.trim().isNotEmpty)
          ? (_, __) {
              // Link chết hoặc lỗi 404 sẽ chạy vào đây
              print("Lỗi load ảnh user: ${user.displayName}");
            }
          : null,
      // Fallback: Hiện chữ cái đầu nếu không có ảnh hoặc ảnh lỗi
      child: Text(
        user.safeName.isNotEmpty ? user.safeName[0].toUpperCase() : '?',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Xây dựng phần title với badge Admin/Banned
  Widget _buildTitle() {
    return Row(
      children: [
        Text(
          user.safeName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (user.role == 'admin') _buildAdminBadge(),
        if (user.isBanned) _buildBannedBadge(),
      ],
    );
  }

  /// Badge Admin
  Widget _buildAdminBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        "ADMIN",
        style: TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }

  /// Badge Banned
  Widget _buildBannedBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        "BANNED",
        style: TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }

  /// Xây dựng phần subtitle (email)
  Widget _buildSubtitle() {
    return Text(
      user.email,
      style: const TextStyle(color: Colors.white54),
    );
  }

  /// Điều hướng đến màn hình chi tiết user
  Future<void> _navigateToDetail(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserDetailScreen(user: user),
      ),
    );

    // Nếu có thay đổi, gọi callback để refresh
    if (result == true && onUserUpdated != null) {
      onUserUpdated!();
    }
  }
}
