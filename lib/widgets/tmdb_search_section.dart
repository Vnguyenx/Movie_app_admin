import 'package:flutter/material.dart';

class TMDBSearchSection extends StatelessWidget {
  final TextEditingController searchController;
  final bool isSearching;
  final List<dynamic> searchResults;
  final VoidCallback onSearch; // Hàm gọi khi bấm tìm
  final Function(Map<String, dynamic>) onSelect; // Hàm gọi khi chọn phim

  const TMDBSearchSection({
    super.key,
    required this.searchController,
    required this.isSearching,
    required this.searchResults,
    required this.onSearch,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Khung tìm kiếm
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Tự động điền từ TMDB:",
                  style: TextStyle(
                      color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                onSubmitted: (_) => onSearch(),
                decoration: InputDecoration(
                  hintText: "Nhập tên phim (VD: Avengers)...",
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  suffixIcon: IconButton(
                    icon: isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.search, color: Colors.blue),
                    onPressed: onSearch,
                  ),
                ),
              ),
            ],
          ),
        ),

        // List kết quả ngang (chỉ hiện khi có kết quả)
        if (searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: searchResults.length,
              itemBuilder: (ctx, i) {
                final movie = searchResults[i];
                return GestureDetector(
                  onTap: () => onSelect(movie), // Gọi callback về cha
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 10),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              "https://image.tmdb.org/t/p/w200${movie['poster_path'] ?? ''}",
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey,
                                  child: const Icon(Icons.error)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          movie['title'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        const Divider(color: Colors.white24, height: 40),
      ],
    );
  }
}
