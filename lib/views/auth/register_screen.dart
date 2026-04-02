import 'package:flutter/material.dart';
import '../../widgets/custom_textfield.dart';
import '../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = TextEditingController();
    final passController = TextEditingController();
    final rePassController = TextEditingController();
    final emailController = TextEditingController();
    final AuthController _authController = AuthController();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      // Bọc SingleChildScrollView để tránh lỗi tràn màn hình (Overflow)
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 60.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50), // Tạo khoảng cách phía trên
              const Text("Đăng Ký",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 40),
              CustomTextField(
                  hint: "Email",
                  icon: Icons.email,
                  controller: emailController),
              CustomTextField(
                  hint: "Username",
                  icon: Icons.person,
                  controller: userController),
              CustomTextField(
                  hint: "Mật Khẩu",
                  icon: Icons.lock,
                  isPassword: true,
                  controller: passController),
              CustomTextField(
                  hint: "Nhập Lại Mật Khẩu",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  controller: rePassController),
              const SizedBox(height: 30),

              // Nút Register
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFF2563EB)]),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    String? error = await _authController.handleRegister(
                      email: emailController.text.trim(),
                      password: passController.text.trim(),
                      confirmPassword: rePassController.text.trim(),
                      username: userController.text.trim(),
                    );

                    if (error == null) {
                      Navigator.pushReplacementNamed(
                          context, AppRoutes.adminMain);
                    } else {
                      // SnackBar thật sự sẽ hiện ở đây
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent),
                  child: const Text("Đăng ký",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Đã có tài khoản? Đăng Nhập",
                    style: TextStyle(color: Colors.white70)),
              ),
              // ĐẢM BẢO KHÔNG CÓ BẤT KỲ CONTAINER NÀO Ở DƯỚI NÀY
            ],
          ),
        ),
      ),
    );
  }
}
