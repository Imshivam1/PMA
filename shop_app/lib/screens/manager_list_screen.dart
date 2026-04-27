import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/custom_appbar.dart';

class ManagerListScreen extends StatefulWidget {
  const ManagerListScreen({super.key});

  @override
  State<ManagerListScreen> createState() => _ManagerListScreenState();
}

class _ManagerListScreenState extends State<ManagerListScreen> {
  late Future<List<dynamic>> _managers;

  @override
  void initState() {
    super.initState();
    _loadManagers();
  }

  void _loadManagers() {
    setState(() {
      _managers = ApiService.getManagers();
    });
  }

  // 🔥 DELETE WITH CONFIRMATION
  void _confirmDelete(int id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Manager"),
        content: Text("Are you sure you want to delete $name?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog

              await ApiService.deleteManager(id);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Manager deleted")),
                );
                _loadManagers();
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ GLOBAL APP BAR
      appBar: const CustomAppBar(title: "Managers"),

      body: FutureBuilder<List<dynamic>>(
        future: _managers,
        builder: (context, snapshot) {
          // ⏳ LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ ERROR
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          final managers = snapshot.data ?? [];

          // 📭 EMPTY STATE (IMPROVED)
          if (managers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_off, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No managers found"),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadManagers();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: managers.length,
              itemBuilder: (context, index) {
                final manager = managers[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),

                    title: Text(
                      manager["name"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Text(manager["email"]),

                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _confirmDelete(manager["id"], manager["name"]),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}