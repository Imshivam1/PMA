import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
    _requests = ApiService.getRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Requests (${ApiService.role})"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _requests,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];

              return Card(
                child: ListTile(
                  title: Text("Product ID: ${req["product_id"]}"),
                  subtitle: Text(
                    "Qty: ${req["quantity"]} | Status: ${req["status"]}",
                  ),

                  // 🔥 Owner Controls
                  trailing: ApiService.role == "owner" &&
                          req["status"] == "pending"
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () async {
                                await ApiService.updateRequest(
                                    req["id"], "approved");
                                setState(_loadRequests);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () async {
                                await ApiService.updateRequest(
                                    req["id"], "rejected");
                                setState(_loadRequests);
                              },
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}