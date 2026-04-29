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

  String formatDate(String date) {
    final parsed = DateTime.parse(date);
    return DateFormat('dd MMM, hh:mm a').format(parsed);
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

          final data = snapshot.data!;

          // 📭 Empty
          if (data.isEmpty) {
            return const Center(child: Text("No history found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            itemBuilder: (_, index) {
              final item = data[index];
              final change = item["change"];
              final isPositive = change > 0;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        isPositive ? Colors.green : Colors.red,
                    child: Icon(
                      isPositive ? Icons.add : Icons.remove,
                      color: Colors.white,
                    ),
                  ),

                  title: Text(
                    "${isPositive ? "+" : ""}$change",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item["action"]),
                      if (item["note"] != null)
                        Text(
                          item["note"],
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),

                  trailing: Text(
                    formatDate(item["created_at"]),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}