import 'package:flutter/material.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/dashboard/main_layout.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String adminMain = '/adminMain';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _fadeRoute(const LoginScreen());
      case register:
        return _fadeRoute(const RegisterScreen());
      case adminMain:
        return _fadeRoute(const MainLayout());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
              body:
                  Center(child: Text('No route defined for ${settings.name}'))),
        );
    }
  }

  // Hàm tạo hiệu ứng chuyển trang mượt mà
  static PageRouteBuilder _fadeRoute(Widget child) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 500), // Độ mượt 0.5s
    );
  }
}
