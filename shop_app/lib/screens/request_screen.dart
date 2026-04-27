import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/custom_appbar.dart'; // ✅ NEW

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  late Future<List<dynamic>> _requests;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() {
    setState(() {
      _requests = ApiService.getRequests();
    });
  }

  // 🎨 STATUS COLOR HELPER
  Color getStatusColor(String status) {
    switch (status) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ REPLACED APPBAR
      appBar: const CustomAppBar(title: "Requests"),

      body: FutureBuilder<List<dynamic>>(
        future: _requests,
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

          final requests = snapshot.data ?? [];

          // 📭 EMPTY STATE
          if (requests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No requests yet"),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadRequests();
            },
            child: ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      req["product_name"] ??
                          "Product ID: ${req["product_id"]}",
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Qty: ${req["quantity"]}"),

                        Text(
                          "Status: ${req["status"]}",
                          style: TextStyle(
                            color: getStatusColor(req["status"]),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    // 👑 OWNER ACTIONS
                    trailing: ApiService.role == "owner" &&
                            req["status"] == "pending"
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check,
                                    color: Colors.green),
                                onPressed: () async {
                                  await ApiService.updateRequest(
                                      req["id"], "approved");

                                  if (mounted) _loadRequests();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.red),
                                onPressed: () async {
                                  await ApiService.updateRequest(
                                      req["id"], "rejected");

                                  if (mounted) _loadRequests();
                                },
                              ),
                            ],
                          )
                        : null,
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