import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../controllers/chat_controller.dart';
import '../models/chat_model.dart';
import '../models/chat_room_model.dart';
import '../views/chats/chat_detail_screen.dart';

class ItemChatList extends StatelessWidget {
  final ChatRoom room;
  final ChatController controller;

  const ItemChatList({
    super.key,
    required this.room,
    required this.controller,
  });

  // Hàm xác nhận xóa
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title:
            const Text("Xóa hội thoại?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Tin nhắn sẽ bị xóa vĩnh viễn.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.deleteChatRoom(room.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã xóa cuộc trò chuyện")),
                );
              }
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasUnread = room.unreadCount > 0;

    return Container(
      decoration: BoxDecoration(
        color: hasUnread
            ? const Color(0xFF334155) // Màu sáng hơn chút nếu chưa đọc
            : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: hasUnread
            ? Border.all(color: Colors.blueAccent.withOpacity(0.5))
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        // 1. AVATAR USER (Lấy realtime từ collection users)
        leading: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(room.id) // room.id chính là userId
              .snapshots(),
          builder: (context, snapshot) {
            String? photoUrl;
            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              photoUrl = data['photoURL'];
            }

            return CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blueAccent,
              backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                  ? NetworkImage(photoUrl)
                  : null,
              child: (photoUrl == null || photoUrl.isEmpty)
                  ? Text(
                      room.userEmail.isNotEmpty
                          ? room.userEmail[0].toUpperCase()
                          : "?",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  : null,
            );
          },
        ),

        // 2. THÔNG TIN USER & TIN NHẮN CUỐI
        title: Text(
          room.userEmail,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            "${hasUnread ? '● ' : ''}${room.lastMessage}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: hasUnread ? Colors.white : Colors.white70,
              fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),

        // 3. CỘT CHỨA: BADGE (TRÊN) & THÙNG RÁC (DƯỚI)
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // A. BADGE SỐ LƯỢNG (Chỉ hiện nếu > 0)
            if (hasUnread)
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  room.unreadCount > 99 ? "99+" : "${room.unreadCount}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              const SizedBox(height: 4), // Giữ chỗ cho căn chỉnh

            // B. NÚT XÓA
            InkWell(
              onTap: () => _confirmDelete(context),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.white54, // Màu nhạt hơn chút cho đỡ chói
                size: 20,
              ),
            ),
          ],
        ),

        // 4. SỰ KIỆN CLICK VÀO ITEM
        onTap: () {
          // A. Đánh dấu đã đọc ngay lập tức
          controller.markAsRead(room.id);

          // B. Chuyển màn hình
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailScreen(
                userId: room.id,
                userEmail: room.userEmail,
              ),
            ),
          );
        },
      ),
    );
  }
}
