import 'package:flutter/material.dart';
import '../../widgets/profile_text_field.dart';
import '../../controllers/profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController _controller = ProfileController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _avatarUrlController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _controller.currentUser;
    if (user == null) return;

    // Load từ Auth trước
    _nameController.text = user.displayName ?? "";
    _emailController.text = user.email ?? "";

    try {
      final data = await _controller.getUserData();

      if (data != null) {
        setState(() {
          _phoneController.text = data['phone'] ?? '';

          String dbImage =
              data['photoUrl'] ?? data['photoURL'] ?? data['img'] ?? '';

          if (dbImage.isNotEmpty) {
            _avatarUrlController.text = dbImage;
          } else {
            _avatarUrlController.text = user.photoURL ?? '';
          }
        });
      }
    } catch (e) {
      debugPrint("Lỗi load data: $e");
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    try {
      await _controller.updateProfile(
        displayName: _nameController.text,
        photoUrl: _avatarUrlController.text,
        phone: _phoneController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã lưu hồ sơ!"),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _controller.currentUser;

    String previewImage = _avatarUrlController.text.trim();
    if (previewImage.isEmpty) {
      previewImage = user?.photoURL ??
          "https://ui-avatars.com/api/?name=${user?.email}&background=random";
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          "Hồ sơ cá nhân",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F172A),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blueAccent, width: 2),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(previewImage),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            ProfileTextField(
              label: "Email (Không thể sửa)",
              controller: _emailController,
              readOnly: true,
            ),

            const SizedBox(height: 16),

            ProfileTextField(
              label: "Tên hiển thị",
              controller: _nameController,
            ),

            const SizedBox(height: 16),

            ProfileTextField(
              label: "Số điện thoại",
              controller: _phoneController,
              hint: "Nhập số điện thoại...",
              inputType: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            ProfileTextField(
              label: "Link ảnh đại diện (URL)",
              controller: _avatarUrlController,
              hint: "https://imgur.com/anh.jpg",
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Lưu thay đổi",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
