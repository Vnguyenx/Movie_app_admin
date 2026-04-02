import 'package:flutter/material.dart';
import '../../controllers/movie_controller.dart';
import '../../services/tmdb_service.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/tmdb_search_section.dart';

class AddMovieScreen extends StatefulWidget {
  const AddMovieScreen({super.key});

  @override
  State<AddMovieScreen> createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final MovieController _movieController = MovieController();
  final TMDBService _tmdbService = TMDBService();

  // Các Controller
  final _searchController = TextEditingController();
  final _titleController = TextEditingController();
  final _posterController = TextEditingController();
  final _trailerController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _yearController = TextEditingController();
  final _ratingController = TextEditingController();
  final _categoryController = TextEditingController();

  bool _isSearching = false;
  bool _isSaving = false;
  List<dynamic> _searchResults = [];

  // --- LOGIC ---
  Future<void> _searchTMDB() async {
    if (_searchController.text.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSearching = true);

    final results = await _tmdbService.searchMovies(_searchController.text);
    if (mounted)
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
  }

  Future<void> _selectMovie(Map<String, dynamic> movie) async {
    _titleController.text = movie['title'] ?? '';
    _descriptionController.text = movie['overview'] ?? '';
    _yearController.text =
        (movie['release_date']?.toString().split('-')[0]) ?? '2024';
    _ratingController.text = (movie['vote_average'] ?? 0.0).toString();

    if (movie['poster_path'] != null) {
      _posterController.text =
          "https://image.tmdb.org/t/p/w500${movie['poster_path']}";
    }
    _categoryController.text = _tmdbService.getGenres(movie['genre_ids']);
    _trailerController.text = await _tmdbService.getTrailerUrl(movie['id']);

    setState(() => _searchResults = []); // Ẩn list sau khi chọn
  }

  Future<void> _saveMovie() async {
    if (_titleController.text.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      final data = {
        'movieTitle': _titleController.text,
        'moviePoster': _posterController.text,
        'trailerUrl': _trailerController.text,
        'description': _descriptionController.text,
        'category': _categoryController.text.split(',')[0].trim(),
        'year': int.tryParse(_yearController.text) ?? DateTime.now().year,
        'rating': double.tryParse(_ratingController.text) ?? 0.0,
      };
      await _movieController.addMovie(data);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title:
            const Text("Thêm phim mới", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0F172A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. Component Tìm kiếm
            TMDBSearchSection(
              searchController: _searchController,
              isSearching: _isSearching,
              searchResults: _searchResults,
              onSearch: _searchTMDB,
              onSelect: _selectMovie,
            ),

            // 2. Các ô nhập liệu (Dùng Component CustomInputField)
            CustomInputField(label: "Tên phim", controller: _titleController),
            CustomInputField(
                label: "Link Poster", controller: _posterController),
            CustomInputField(
                label: "Link Trailer", controller: _trailerController),

            Row(children: [
              Expanded(
                  child: CustomInputField(
                      label: "Năm SX",
                      controller: _yearController,
                      keyboardType: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(
                  child: CustomInputField(
                      label: "Điểm (0-10)",
                      controller: _ratingController,
                      keyboardType: TextInputType.number)),
            ]),

            CustomInputField(
                label: "Thể loại", controller: _categoryController),
            CustomInputField(
                label: "Mô tả nội dung",
                controller: _descriptionController,
                maxLines: 4),

            const SizedBox(height: 20),

            // 3. Nút Lưu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveMovie,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("LƯU PHIM VÀO DATA",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
