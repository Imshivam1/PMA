import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../screens/request_screen.dart';
import '../screens/create_manager_screen.dart';
import '../screens/manager_list_screen.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        // 📊 DASHBOARD (avoid stacking + hide if already here)
        if (title != "Dashboard")
          IconButton(
            icon: const Icon(Icons.dashboard),
            tooltip: "Dashboard",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const DashboardScreen(),
                ),
              );
            },
          ),

        // 📋 REQUESTS
        if (ApiService.role == "owner" && title != "Requests")
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: "Requests",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const RequestScreen(),
                ),
              );
            },
          ),

        // 👤➕ CREATE MANAGER
        if (ApiService.role == "owner" && title != "Create Manager")
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: "Create Manager",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateManagerScreen(),
                ),
              );
            },
          ),

        // 👥 MANAGERS LIST
        if (ApiService.role == "owner" && title != "Managers")
          IconButton(
            icon: const Icon(Icons.group),
            tooltip: "Managers",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManagerListScreen(),
                ),
              );
            },
          ),

        // 🚪 LOGOUT (always visible)
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: "Logout",
          onPressed: () async {
            await ApiService.logout();

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}