import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// --- 1. Widget lấy tên USER ---
class UserNameFetcher extends StatelessWidget {
  final String userId;
  final TextStyle? style;

  const UserNameFetcher({super.key, required this.userId, this.style});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("...", style: TextStyle(color: Colors.grey));
        }

        // Nếu User không tồn tại (đã bị xóa)
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                "Người dùng đã xóa",
                style: style?.copyWith(
                        color: Colors.grey, fontStyle: FontStyle.italic) ??
                    const TextStyle(
                        color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        String name = data?['displayName'] ?? data?['email'] ?? "Unknown";

        return Text(name, style: style ?? const TextStyle(color: Colors.white));
      },
    );
  }
}

// --- 2. Widget lấy tên PHIM (Movie) ---
class MovieNameFetcher extends StatelessWidget {
  final String movieId;
  final TextStyle? style;

  const MovieNameFetcher({super.key, required this.movieId, this.style});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      // 1. Đảm bảo tên collection là 'movies'
      future:
          FirebaseFirestore.instance.collection('movies').doc(movieId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Đang tải...",
              style: TextStyle(color: Colors.grey, fontSize: 12));
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          // Debug: In ra lỗi nếu không tìm thấy document
          print("Lỗi tìm phim ID: $movieId");
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4)),
            child: const Text("Unknown Movie",
                style: TextStyle(color: Colors.redAccent, fontSize: 12)),
          );
        }

        // Lấy data từ document
        final data = snapshot.data!.data() as Map<String, dynamic>;

        // 🔥 QUAN TRỌNG: Trong database của bạn (Ảnh 2), tên trường là 'movieTitle'
        // Nếu code cũ để là data['title'] hoặc data['name'] thì sẽ bị null -> hiện Unknown
        String title = data['movieTitle'] ?? "Không có tên";

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4)),
          child: Text(
            title,
            style: style ??
                const TextStyle(
                    color: Colors.blueAccent, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}
