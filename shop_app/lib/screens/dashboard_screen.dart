import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/custom_appbar.dart';
import 'inventory_screen.dart';
import 'request_screen.dart';
import 'create_manager_screen.dart';

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
    _data = ApiService.getDashboard();
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _loadDashboard();
    });

    await _data;
  }

  Widget buildCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(
                icon,
                color: color,
              ),
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOwner = ApiService.role == "owner";

    return Scaffold(
      appBar: CustomAppBar(
        title: isOwner ? "Owner Dashboard" : "Manager Dashboard",
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 50,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Error: ${snapshot.error}",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadDashboard();
                      });
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data ?? {};

          return RefreshIndicator(
            onRefresh: _refreshDashboard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOwner ? "Business Overview" : "Inventory Overview",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  buildCard(
                    "Total Products",
                    "${data["total_products"] ?? 0}",
                    Icons.inventory_2_outlined,
                    Colors.blue,
                  ),

                  buildCard(
                    "Low Stock",
                    "${data["low_stock"] ?? 0}",
                    Icons.warning_amber_rounded,
                    Colors.orange,
                  ),

                  buildCard(
                    isOwner
                        ? "Pending Manager Requests"
                        : "My Pending Requests",
                    "${data["pending_requests"] ?? 0}",
                    Icons.pending_actions,
                    Colors.red,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // BOTH OWNER AND MANAGER
                  buildButton(
                    "Inventory",
                    Icons.inventory,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InventoryScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // ROLE-SPECIFIC REQUEST BUTTON
                  buildButton(
                    isOwner ? "Manage Requests" : "My Requests",
                    Icons.receipt_long,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RequestScreen(),
                        ),
                      );
                    },
                  ),

                  // OWNER-ONLY ACTIONS
                  if (isOwner) ...[
                    const SizedBox(height: 12),

                    buildButton(
                      "Create Manager",
                      Icons.person_add_alt_1,
                      () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const CreateManagerScreen(),
                          ),
                        );

                        if (mounted) {
                          setState(() {
                            _loadDashboard();
                          });
                        }
                      },
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}