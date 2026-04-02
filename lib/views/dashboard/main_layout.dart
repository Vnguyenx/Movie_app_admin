import 'package:flutter/material.dart';
import '../tabs/chat_admin_tab.dart';
import '../tabs/interaction_tab.dart';
import '../tabs/user_manage_tab.dart';
import 'sidebar_drawer.dart';
import '../dashboard/dashboard_tab.dart';
import '../tabs/movies_tab.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // 1. TẠO CÁI CHÌA KHÓA (GlobalKey)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _goToMoviesTab() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 2. HÀM MỞ DRAWER (Sẽ truyền xuống con)
  void _openMainDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      // 3. TRUYỀN HÀM MỞ DRAWER XUỐNG DASHBOARD
      DashboardScreen(
        onSwitchToMovies: _goToMoviesTab,
        onOpenMenu: _openMainDrawer, // <-- Truyền cái này
      ),

      // Truyền tương tự cho MoviesScreen
      MoviesScreen(onOpenMenu: _openMainDrawer),

      UserManageTab(onOpenMenu: _openMainDrawer),

      ReviewManageTab(onOpenMenu: _openMainDrawer),

      ChatAdminTab(onOpenMenu: _openMainDrawer),
    ];

    return Scaffold(
      // 4. GẮN CHÌA KHÓA VÀO SCAFFOLD CHA
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0F172A),

      drawer: SidebarDrawer(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),

      body: screens[_selectedIndex],
    );
  }
}
