import 'package:flutter/material.dart';
import '../../controllers/user_controller.dart';
import '../../models/user_model.dart';
import '../../widgets/user_list_item.dart';
import '../users/add_edit_user_screen.dart';

class UserManageTab extends StatefulWidget {
  final VoidCallback? onOpenMenu; // Để mở Menu Drawer

  const UserManageTab({super.key, this.onOpenMenu});

  @override
  State<UserManageTab> createState() => _UserManageTabState();
}

class _UserManageTabState extends State<UserManageTab> {
  final UserController _controller = UserController();

  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedRole; // Lọc theo Admin/User

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final users = await _controller.fetchUsers();
    if (mounted) {
      setState(() {
        _allUsers = users;
        _applyFilter();
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredUsers = _controller.applyFilters(
        sourceList: _allUsers,
        query: _searchQuery,
        roleFilter: _selectedRole,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: widget.onOpenMenu, // Mở Drawer
        ),
        title: const Text("Quản lý người dùng",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0F172A),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.blueAccent),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditUserScreen()),
              );
              if (result == true) _loadData();
            },
          )
        ],
      ),
      body: Column(
        children: [
          // --- THANH TÌM KIẾM & BỘ LỌC ---
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1E293B),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Tìm tên, email...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onChanged: (val) {
                      _searchQuery = val;
                      _applyFilter();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String?>(
                    dropdownColor: const Color(0xFF1E293B),
                    value: _selectedRole,
                    items: const [
                      DropdownMenuItem(
                          value: null,
                          child: Text("Tất cả",
                              style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(
                          value: "user",
                          child: Text("User",
                              style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(
                          value: "admin",
                          child: Text("Admin",
                              style: TextStyle(color: Colors.white))),
                    ],
                    onChanged: (val) {
                      _selectedRole = val;
                      _applyFilter();
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- DANH SÁCH USER ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(
                        child: Text("Không tìm thấy user",
                            style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          // Sử dụng widget UserListItem
                          return UserListItem(
                            user: user,
                            onUserUpdated: _loadData,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
