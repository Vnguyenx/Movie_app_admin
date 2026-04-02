import 'package:flutter/material.dart';
import '../../models/movie_model.dart';
import '../../controllers/movie_controller.dart';

class EditMovieScreen extends StatefulWidget {
  final MovieModel movie; // Nhận model phim cần sửa
  const EditMovieScreen({super.key, required this.movie});

  @override
  State<EditMovieScreen> createState() => _EditMovieScreenState();
}

class _EditMovieScreenState extends State<EditMovieScreen> {
  final MovieController _controller = MovieController();

  late TextEditingController _titleController;
  late TextEditingController _posterController;
  late TextEditingController _trailerController;
  late TextEditingController _descController;
  late TextEditingController _yearController;
  late TextEditingController _ratingController;
  late TextEditingController _categoryController;

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    // Đổ dữ liệu cũ vào controller
    _titleController = TextEditingController(text: widget.movie.movieTitle);
    _posterController = TextEditingController(text: widget.movie.moviePoster);
    _trailerController = TextEditingController(text: widget.movie.trailerUrl);
    _descController = TextEditingController(text: widget.movie.description);
    _yearController = TextEditingController(text: widget.movie.year.toString());
    _ratingController =
        TextEditingController(text: widget.movie.rating.toString());
    _categoryController = TextEditingController(text: widget.movie.category);
  }

  Future<void> _updateMovie() async {
    setState(() => _isUpdating = true);

    final updatedData = {
      'movieTitle': _titleController.text,
      'moviePoster': _posterController.text,
      'trailerUrl': _trailerController.text,
      'description': _descController.text,
      'category': _categoryController.text,
      'year': int.tryParse(_yearController.text) ?? 2024,
      'rating': double.tryParse(_ratingController.text) ?? 0.0,
      'searchKeywords': _titleController.text.toLowerCase().split(' '),
    };

    await _controller.updateMovie(widget.movie.id, updatedData);

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Cập nhật thành công!")));
      Navigator.pop(context, true); // Trả về true để màn hình trước reload
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
          title: const Text("Chỉnh sửa phim"),
          backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInput("Tên phim", _titleController),
            _buildInput("Link Poster", _posterController),
            _buildInput("Link Trailer", _trailerController),
            Row(children: [
              Expanded(child: _buildInput("Năm", _yearController)),
              const SizedBox(width: 10),
              Expanded(child: _buildInput("Rating", _ratingController)),
            ]),
            _buildInput("Thể loại", _categoryController),
            _buildInput("Mô tả", _descController, lines: 5),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUpdating ? null : _updateMovie,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50)),
              child: _isUpdating
                  ? const CircularProgressIndicator()
                  : const Text("CẬP NHẬT THAY ĐỔI",
                      style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController c, {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: lines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: const Color(0xFF1E293B)),
      ),
    );
  }
}
