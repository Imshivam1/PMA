import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/inventory_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const ShopPOSApp());
}

class ShopPOSApp extends StatelessWidget {
  const ShopPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),

      
      home: FutureBuilder(
        future: ApiService.loadAuth(),
        builder: (context, snapshot) {
          // ⏳ Show loader while checking token
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final isLoggedIn = snapshot.data ?? false;

          // 🔐 Auto navigation
          return isLoggedIn
              ? const InventoryScreen()
              : const LoginScreen();
        },
      ),
    );
  }
}