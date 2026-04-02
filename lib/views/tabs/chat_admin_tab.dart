import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../controllers/chat_controller.dart';
import '../../models/chat_model.dart';
import '../../models/chat_room_model.dart';
import '../../widgets/chat_list_item.dart';
import '../chats/chat_detail_screen.dart';

class ChatAdminTab extends StatelessWidget {
  final VoidCallback onOpenMenu;
  final ChatController _controller = ChatController();

  ChatAdminTab({super.key, required this.onOpenMenu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: onOpenMenu,
        ),
        // Hiển thị tổng số tin nhắn chưa đọc trên tiêu đề
        title: StreamBuilder<int>(
          stream: _controller.getUnreadMessagesCount(),
          builder: (context, snapshot) {
            int count = snapshot.data ?? 0;
            return Row(
              children: [
                const Text(
                  "Hỗ trợ khách hàng",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "$count",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                ]
              ],
            );
          },
        ),
      ),
      body: StreamBuilder<List<ChatRoom>>(
        stream: _controller.getChatRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.chat_bubble_outline,
                      size: 60, color: Colors.white24),
                  SizedBox(height: 16),
                  Text(
                    "Chưa có tin nhắn hỗ trợ nào",
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            );
          }

          final chatRooms = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: chatRooms.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final room = chatRooms[index];

              // Gọi Widget item đã tách riêng
              return ItemChatList(
                room: room,
                controller: _controller,
              );
            },
          );
        },
      ),
    );
  }
}
