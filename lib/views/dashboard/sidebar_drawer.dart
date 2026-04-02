import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/chat_controller.dart';
import '../../routes/app_routes.dart';
import '../profile/profile_screen.dart';
import '../../models/user_model.dart';

class SidebarDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  final ChatController _chatController = ChatController();

  SidebarDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: const Color(0xFF0F172A),
      child: Column(
        children: [
          // ==============================
          // 1. HEADER (Thông tin Admin)
          // ==============================
          StreamBuilder<DocumentSnapshot>(
            stream: (currentUser != null)
                ? FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser.uid)
                    .snapshots()
                : null,
            builder: (context, snapshot) {
              String displayName = currentUser?.displayName ?? "Admin";
              String email = currentUser?.email ?? "";
              String? photoUrl = currentUser?.photoURL;
              String shortName =
                  (displayName.isNotEmpty) ? displayName[0].toUpperCase() : "A";

              if (snapshot.hasData && snapshot.data!.exists) {
                // Parse dữ liệu an toàn
                try {
                  UserModel userModel = UserModel.fromSnapshot(snapshot.data!);
                  displayName = userModel.safeName;
                  photoUrl = userModel.photoURL;
                  if (displayName.isNotEmpty) {
                    shortName = displayName[0].toUpperCase();
                  }
                } catch (e) {
                  debugPrint("Lỗi parse user model: $e");
                }
              }

              // 🔥 LOGIC KIỂM TRA ẢNH ĐỂ TRÁNH CRASH 🔥
              bool hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

              return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFF1E293B)),
                accountName: Text(
                  displayName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                accountEmail: Text(email),
                currentAccountPicture: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfileScreen()));
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFF2563EB),

                    // 1. Chỉ load ảnh nếu có URL
                    backgroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,

                    // 2. Quan trọng: Chỉ gắn hàm lỗi nếu đang load ảnh
                    // Nếu không có ảnh (backgroundImage = null) mà để hàm này sẽ bị Crash
                    onBackgroundImageError: hasPhoto
                        ? (_, __) => debugPrint("Lỗi tải ảnh drawer")
                        : null,

                    // 3. Nếu không có ảnh, hiển thị chữ cái đầu hoặc Icon
                    child: !hasPhoto
                        ? Text(
                            shortName,
                            style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )
                        : null,
                  ),
                ),
              );
            },
          ),

          // ==============================
          // 2. MENU ITEMS
          // ==============================
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(context, 0, "Tổng quan", Icons.dashboard),
                _buildMenuItem(context, 1, "Phim", Icons.movie),
                _buildMenuItem(context, 2, "Người dùng", Icons.people),
                _buildMenuItem(
                    context, 3, "Bình luận & Đánh giá", Icons.comment),

                // 🔥 MỤC TIN NHẮN (CÓ BADGE ĐẾM SỐ)
                StreamBuilder<int>(
                  stream: _chatController.getUnreadMessagesCount(),
                  initialData: 0,
                  builder: (context, snapshot) {
                    final int count = snapshot.data ?? 0;
                    return _buildMenuItem(
                      context,
                      4,
                      "Tin Nhắn",
                      Icons.chat_bubble,
                      badgeCount: count,
                    );
                  },
                ),

                const Divider(color: Colors.white10),

                // Nút Đăng xuất
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text("Đăng xuất",
                      style: TextStyle(color: Colors.redAccent)),
                  onTap: () async {
                    bool confirm = await showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: const Color(0xFF1E293B),
                            title: const Text("Đăng xuất?",
                                style: TextStyle(color: Colors.white)),
                            content: const Text(
                                "Bạn có chắc chắn muốn đăng xuất không?",
                                style: TextStyle(color: Colors.white70)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text("Hủy"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text("Đồng ý",
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ) ??
                        false;

                    if (confirm) {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(
                          context, AppRoutes.login, (route) => false);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================
  // HÀM HỖ TRỢ XÂY DỰNG ITEM
  // ==============================
  Widget _buildMenuItem(
      BuildContext context, int index, String title, IconData icon,
      {int badgeCount = 0}) {
    final isSelected = selectedIndex == index;

    Widget iconWidget =
        Icon(icon, color: isSelected ? Colors.white : Colors.white70);

    if (badgeCount > 0) {
      iconWidget = Badge(
        label: Text(
          badgeCount > 99 ? '99+' : badgeCount.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        backgroundColor: Colors.redAccent,
        child: iconWidget,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)])
            : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: iconWidget,
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          onItemTapped(index);
          Navigator.pop(context);
        },
      ),
    );
  }
}
