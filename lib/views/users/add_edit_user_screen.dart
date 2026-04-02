import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../controllers/user_controller.dart';

class AddEditUserScreen extends StatefulWidget {
  final UserModel? user; // Null = Thêm, Có data = Sửa

  const AddEditUserScreen({super.key, this.user});

  @override
  State<AddEditUserScreen> createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserController _controller = UserController();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _photoController;
  String _role = 'user';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.user?.displayName ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _photoController = TextEditingController(text: widget.user?.photoURL ?? '');
    _role = widget.user?.role ?? 'user';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final data = {
        'displayName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'photoURL': _photoController.text.trim(),
        'role': _role,
        if (widget.user == null) 'createdAt': DateTime.now(),
      };

      if (widget.user == null) {
        await _controller.addUser(data);
      } else {
        await _controller.updateUser(widget.user!.id, data);
      }

      if (mounted) Navigator.pop(context, true); // Trả về true để reload
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(widget.user == null ? "Thêm User" : "Sửa User",
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0F172A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Tên hiển thị", _nameController),
              const SizedBox(height: 15),
              _buildTextField("Email", _emailController),
              const SizedBox(height: 15),
              _buildTextField("Avatar URL", _photoController),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _role,
                dropdownColor: const Color(0xFF1E293B),
                items: ['user', 'admin']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role.toUpperCase(),
                              style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _role = val!),
                decoration: InputDecoration(
                  labelText: "Vai trò",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent),
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const CircularProgressIndicator()
                      : const Text("LƯU",
                          style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Hàm buildTextField (giống cũ, viết gọn lại)
  Widget _buildTextField(String label, TextEditingController c) {
    return TextFormField(
      controller: c,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1E293B),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    );
  }
}
