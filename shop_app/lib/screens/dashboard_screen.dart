import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/custom_appbar.dart'; // ✅ NEW
import 'inventory_screen.dart';
import 'request_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _data;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    setState(() {
      _data = ApiService.getDashboard();
    });
  }

  // 📊 CARD UI (IMPROVED)
  Widget buildCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // 🔘 BUTTON UI (UNCHANGED BUT CLEAN)
  Widget buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ GLOBAL APPBAR
      appBar: const CustomAppBar(title: "Dashboard"),

      body: FutureBuilder<Map<String, dynamic>>(
        future: _data,
        builder: (context, snapshot) {
          // ⏳ LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ ERROR
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data ?? {};

          return RefreshIndicator(
            onRefresh: () async {
              _loadDashboard();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📊 OVERVIEW
                  const Text(
                    "Overview",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  buildCard(
                    "Total Products",
                    "${data["total_products"] ?? 0}",
                    Icons.inventory,
                    Colors.blue,
                  ),

                  buildCard(
                    "Low Stock",
                    "${data["low_stock"] ?? 0}",
                    Icons.warning,
                    Colors.orange,
                  ),

                  buildCard(
                    "Pending Requests",
                    "${data["pending_requests"] ?? 0}",
                    Icons.pending_actions,
                    Colors.red,
                  ),

                  const SizedBox(height: 24),

                  // ⚡ QUICK ACTIONS
                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  buildButton("📦 Inventory", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InventoryScreen(),
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  buildButton("🧾 View Requests", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RequestScreen(),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}