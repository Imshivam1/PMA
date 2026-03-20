import '../models/product.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000";

  // GET PRODUCTS
  static Future<List<Product>> getProducts() async {
  final response = await http.get(
    Uri.parse('$baseUrl/products/'),
  );

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Product.fromJson(json)).toList();
  } else {
    throw Exception("Failed to load products");
  }
}

  // ADD PRODUCT
  static Future<void> addProduct({
    required String name,
    required int price,
    required int stock,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "price": price,
        "stock": stock,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to add product");
    }
  }
}
