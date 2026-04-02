import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // File này sinh ra khi bạn chạy lệnh 'flutterfire configure'
import 'routes/app_routes.dart';

void main() async {
  // Đảm bảo các plugin của Flutter đã được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase với cấu hình mặc định cho từng nền tảng
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie Admin CMS',

      // Cấu hình Theme tối (Dark Mode) khớp với ảnh thiết kế
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF2563EB), // Xanh dương làm chủ đạo
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Nền xanh đen sâu

        // Cấu hình font chữ và các thành phần khác cho đồng bộ
        textTheme: const TextTheme(
          displayLarge:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Colors.white70),
        ),

        // Tùy chỉnh màu sắc cho các thẻ Card và Sidebar
        cardColor: const Color(0xFF1E293B),
        dividerColor: Colors.white10,
      ),

      // Sử dụng hệ thống Routing đã định nghĩa trong AppRoutes
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
