import 'package:flutter/material.dart';
import '../../controllers/movie_controller.dart';
import '../../models/movie_model.dart';
import '../../widgets/movie_list_item.dart';
import '../movies/add_movie_screen.dart';

class MoviesScreen extends StatefulWidget {
  final VoidCallback? onOpenMenu;

  const MoviesScreen({
    super.key,
    this.onOpenMenu,
  });

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final MovieController _controller = MovieController();

  List<MovieModel> _allMovies = [];
  List<MovieModel> _filteredMovies = [];
  bool _isLoading = true;

  String _searchQuery = '';
  String? _selectedCategory;
  int? _selectedYear;

  List<String> _categories = ['Tất cả'];
  List<int> _years = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final movies = await _controller.fetchMovies();

    if (mounted) {
      setState(() {
        _allMovies = movies;
        _categories = _controller.getAvailableCategories(movies);
        _years = _controller.getAvailableYears(movies);
        _applyFilter();
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredMovies = _controller.applyFilters(
        sourceList: _allMovies,
        query: _searchQuery,
        category: _selectedCategory,
        year: _selectedYear,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            if (widget.onOpenMenu != null) {
              widget.onOpenMenu!();
            }
          },
        ),
        title: const Text("Quản lý phim",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.blueAccent),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddMovieScreen(),
                ),
              );

              if (result == true) {
                _loadData();
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          // --- PHẦN TÌM KIẾM & BỘ LỌC ---
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1E293B),
            child: Column(
              children: [
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Tìm tên phim...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _applyFilter();
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        dropdownColor: const Color(0xFF1E293B),
                        isExpanded: true,
                        value: _categories.contains(_selectedCategory)
                            ? _selectedCategory
                            : 'Tất cả',
                        items: _categories.map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          _selectedCategory = (val == 'Tất cả') ? null : val;
                          _applyFilter();
                        },
                        decoration: _filterInputDecoration('Thể loại'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        dropdownColor: const Color(0xFF1E293B),
                        value: _selectedYear,
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text("Tất cả năm",
                                style: TextStyle(color: Colors.white)),
                          ),
                          ..._years.map((y) => DropdownMenuItem(
                                value: y,
                                child: Text(y.toString(),
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ))
                        ],
                        onChanged: (val) {
                          _selectedYear = val;
                          _applyFilter();
                        },
                        decoration: _filterInputDecoration('Năm'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- DANH SÁCH PHIM ---
          Expanded(
            child: _filteredMovies.isEmpty
                ? const Center(
                    child: Text("Không tìm thấy phim nào",
                        style: TextStyle(color: Colors.white54)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredMovies.length,
                    itemBuilder: (context, index) {
                      final movie = _filteredMovies[index];
                      // Sử dụng widget MovieListItem
                      return MovieListItem(
                        movie: movie,
                        onMovieUpdated: _loadData,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  InputDecoration _filterInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF0F172A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }
}
