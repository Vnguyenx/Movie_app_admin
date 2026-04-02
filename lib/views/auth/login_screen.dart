import 'package:flutter/material.dart';
import '../../widgets/custom_textfield.dart';
import '../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import 'forgot_password_screen.dart'; // Kết nối với bộ não xử lý

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Khai báo Controller để lấy dữ liệu từ UI
    final emailController = TextEditingController();
    final passController = TextEditingController();

    // Khởi tạo AuthController (MVC)
    final AuthController _authController = AuthController();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Màu xanh đen đậm
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Đăng Nhập",
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 40),

            // Ô nhập Email/Username
            CustomTextField(
                hint: "Email",
                icon: Icons.email_outlined,
                controller: emailController),

            // Ô nhập Password
            CustomTextField(
                hint: "Mật Khẩu",
                icon: Icons.lock_outline,
                isPassword: true,
                controller: passController),

            const SizedBox(height: 10),

            // Link quên mật khẩu (như trong ảnh mẫu)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text("Quên Mật Khẩu?",
                      style: TextStyle(color: Colors.white54))),
            ),

            const SizedBox(height: 20),

            // Nút Login hiệu ứng Gradient
            Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFF2563EB)]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  // Gửi dữ liệu sang Controller xử lý
                  String? error = await _authController.handleLogin(
                      emailController.text.trim(), passController.text.trim());

                  if (error == null) {
                    // Đăng nhập đúng -> Vào thẳng trang Admin
                    Navigator.pushReplacementNamed(
                        context, AppRoutes.adminMain);
                  } else {
                    // Sai thông tin -> Hiện thông báo lỗi
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(error), backgroundColor: Colors.red),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent),
                child: const Text("Đăng Nhập",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 10),

            // Chuyển sang trang Đăng ký
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
              child: const Text("Bạn chưa có tài khoản? Đăng ký",
                  style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
}
