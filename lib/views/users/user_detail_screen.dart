import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Cần import intl để format ngày tháng
import '../../models/user_model.dart';
import '../../controllers/user_controller.dart';
import 'add_edit_user_screen.dart'; // Import màn hình sửa

class UserDetailScreen extends StatefulWidget {
  final UserModel user;

  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final UserController _controller = UserController();
  late UserModel _currentUser; // Biến local để update UI ngay khi Ban xong

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  // Hành động Ban
  Future<void> _handleBan() async {
    await _controller.banUser7Days(_currentUser.id);
    _refreshUser(); // Load lại data mới nhất từ server hoặc update local
  }

  // Hành động Mở khóa
  Future<void> _handleUnban() async {
    await _controller.unbanUser(_currentUser.id);
    _refreshUser();
  }

  // Load lại trạng thái để UI cập nhật ngày giờ
  void _refreshUser() {
    // Trong thực tế nên fetch lại từ DB, ở đây mình update giả lập logic để UI đổi màu liền
    if (mounted) {
      Navigator.pop(context, true); // Quay về list để list tự reload cho chuẩn
    }
  }

  @override
  Widget build(BuildContext context) {
    // Logic hiển thị trạng thái
    bool isBanned = _currentUser.isBanned;
    String statusText = isBanned
        ? "ĐANG BỊ CẤM (Mở khóa: ${DateFormat('dd/MM/yyyy HH:mm').format(_currentUser.bannedUntil!)})"
        : "ĐANG HOẠT ĐỘNG";

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title:
            const Text("Chi tiết User", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0F172A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blueAccent),
            onPressed: () async {
              // Điều hướng sang màn hình Sửa
              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AddEditUserScreen(user: _currentUser)));
              if (result == true) Navigator.pop(context, true); // Reload list
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            tooltip: 'Xóa người dùng',
            onPressed: () async {
              // 1. Hiển thị hộp thoại xác nhận
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor:
                      const Color(0xFF1E293B), // Màu nền tối cho hợp theme
                  title: const Text("Xác nhận xóa",
                      style: TextStyle(color: Colors.white)),
                  content: Text(
                    "Bạn có chắc muốn xóa vĩnh viễn user '${_currentUser.displayName}' không?\nHành động này không thể hoàn tác.",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(ctx, false), // Chọn Hủy -> Trả về false
                      child: const Text("Hủy",
                          style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(ctx, true), // Chọn Xóa -> Trả về true
                      child: const Text("Xóa",
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );

              // 2. Xử lý xóa nếu người dùng chọn "Xóa"
              if (confirm == true) {
                try {
                  // Gọi controller xóa data trên Firebase
                  await _controller.deleteUser(_currentUser.id);

                  if (mounted) {
                    // Hiện thông báo thành công
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Đã xóa người dùng thành công!")),
                    );
                    // Quay về màn hình danh sách và báo reload (return true)
                    Navigator.pop(context, true);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lỗi khi xóa: $e")),
                    );
                  }
                }
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _currentUser.photoURL.isNotEmpty
                    ? NetworkImage(_currentUser.photoURL)
                    : null,
                child: _currentUser.photoURL.isEmpty
                    ? Text(_currentUser.displayName[0],
                        style: const TextStyle(fontSize: 30))
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Text(_currentUser.displayName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            Text(_currentUser.email,
                style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 30),

            // --- THẺ TRẠNG THÁI ---
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isBanned
                    ? Colors.red.withOpacity(0.2)
                    : Colors.green.withOpacity(0.2),
                border: Border.all(color: isBanned ? Colors.red : Colors.green),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Icon(isBanned ? Icons.block : Icons.check_circle,
                      color: isBanned ? Colors.red : Colors.green, size: 40),
                  const SizedBox(height: 10),
                  Text(statusText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color:
                              isBanned ? Colors.redAccent : Colors.greenAccent,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- NÚT HÀNH ĐỘNG BAN/UNBAN ---
            if (isBanned)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50)),
                icon: const Icon(Icons.lock_open, color: Colors.white),
                label: const Text("MỞ KHÓA NGAY",
                    style: TextStyle(color: Colors.white)),
                onPressed: _handleUnban,
              )
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size(double.infinity, 50)),
                icon: const Icon(Icons.timer, color: Colors.white),
                label: const Text("CẤM BÌNH LUẬN 1 TUẦN",
                    style: TextStyle(color: Colors.white)),
                onPressed: _handleBan,
              ),
          ],
        ),
      ),
    );
  }
}
