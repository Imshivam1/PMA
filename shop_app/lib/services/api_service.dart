import '../models/product.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // =========================
  // 🌐 BASE CONFIG
  // =========================
  static const String baseUrl = "http://127.0.0.1:8000";

  static String? token;
  static String? role;

  // =========================
  // 🔐 AUTH STORAGE (SAVE)
  // =========================
  static Future<void> saveAuth(
    String tokenValue,
    String roleValue,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("token", tokenValue);
    await prefs.setString("role", roleValue);

    token = tokenValue;
    role = roleValue;
  }

  // =========================
  // 🔄 AUTH LOAD (AUTO LOGIN)
  // =========================
  static Future<bool> loadAuth() async {
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString("token");
    role = prefs.getString("role");

    return token != null;
  }

  // =========================
  // 🚪 LOGOUT (CLEAR STORAGE)
  // =========================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    token = null;
    role = null;
  }

  // =========================
  // 🔐 LOGIN
  // =========================
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // ✅ Persist token + role
      await saveAuth(
        data["access_token"],
        data["role"],
      );

      return data;
    } else {
      throw Exception("Login failed");
    }
  }

  // =========================
  // 🆕 REGISTER USER
  // =========================
  static Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "role": role,
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception("Registration failed");
    }
  }

  // =========================
  // 📦 PRODUCTS (GET)
  // =========================
  static Future<List<Product>> getProducts() async {
    if (token == null) {
      throw Exception("Not authenticated");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/products/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .map((item) => Product.fromJson(item))
          .toList();
    } else {
      throw Exception("Failed to load products");
    }
  }

  // =========================
  // ➕ ADD PRODUCT
  // =========================
  static Future<void> addProduct({
    required String name,
    required int price,
    required int stock,
  }) async {
    if (token == null) {
      throw Exception("Not authenticated");
    }

    final response = await http.post(
      Uri.parse('$baseUrl/products/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "name": name,
        "price": price,
        "stock": stock,
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception("Failed to add product");
    }
  }

  // =========================
  // 📩 CREATE REQUEST
  // =========================
  static Future<void> createRequest({
    required int productId,
    required int quantity,
  }) async {
    if (token == null) {
      throw Exception("Not authenticated");
    }

    final response = await http.post(
      Uri.parse(
        '$baseUrl/requests/?product_id=$productId&quantity=$quantity',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception("Failed to create request");
    }
  }

  // =========================
  // 📋 GET ALL REQUESTS
  // =========================
  static Future<List<dynamic>> getRequests() async {
    if (token == null) {
      throw Exception("Not authenticated");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/requests/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load requests");
    }
  }

  // =========================
  // ✅ UPDATE REQUEST STATUS
  // =========================
  static Future<void> updateRequest(
    int id,
    String status,
  ) async {
    if (token == null) {
      throw Exception("Not authenticated");
    }

    final response = await http.put(
      Uri.parse('$baseUrl/requests/$id?status=$status'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update request");
    }
  }
}