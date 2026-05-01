import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  final int productId;

  const HistoryScreen({super.key, required this.productId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<dynamic>> _history;

  @override
  void initState() {
    super.initState();
    _history = ApiService.getProductHistory(widget.productId);
  }

  // 📅 Format Date
  String formatDate(String date) {
    final parsed = DateTime.parse(date);
    return DateFormat('dd MMM, hh:mm a').format(parsed);
  }

  // 🧠 Smart Action Labels
  String actionLabel(String action) {
    switch (action.toLowerCase()) {
      case "add":
        return "Stock Added";
      case "remove":
        return "Stock Removed";
      case "update":
        return "Stock Updated";
      default:
        return action;
    }
  }

  // 🔄 Refresh Function
  Future<void> _refresh() async {
    setState(() {
      _history = ApiService.getProductHistory(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stock History")),
      body: FutureBuilder<List<dynamic>>(
        future: _history,
        builder: (context, snapshot) {
          // 🔄 Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Error
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // ✅ Safe Data Handling
          final data = snapshot.data ?? [];

          // 📭 Empty State UI
          if (data.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No history yet"),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: data.length,
              itemBuilder: (_, index) {
                final item = data[index];
                final change = item["change"] ?? 0;
                final isPositive = change > 0;

                final note = item["note"];
                final action = item["action"] ?? "";

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),

                    // 🟢🔴 ICON
                    leading: CircleAvatar(
                      backgroundColor:
                          isPositive ? Colors.green : Colors.red,
                      child: Icon(
                        isPositive ? Icons.add : Icons.remove,
                        color: Colors.white,
                      ),
                    ),

                    // 🔥 TITLE
                    title: Text(
                      "${isPositive ? "+" : ""}$change units",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color:
                            isPositive ? Colors.green : Colors.red,
                      ),
                    ),

                    // 🧠 SUBTITLE (Smart Handling)
                    subtitle: Text(
                      (note != null && note.toString().isNotEmpty)
                          ? "${actionLabel(action)} • $note"
                          : actionLabel(action),
                      style: const TextStyle(fontSize: 13),
                    ),

                    // 🕒 DATE
                    trailing: Text(
                      formatDate(item["created_at"]),
                      style: const TextStyle(fontSize: 12),
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