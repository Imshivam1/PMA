import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class ApiService {
  // =========================
  // 🌐 BASE CONFIG
  // =========================
  static const String baseUrl = "http://localhost:8000";

  static String? _token;
  static String? _role;

  // 🔥 FIX: expose role for UI
  static String? role;

  static String? getRole() => _role;

  // =========================
  // 🔐 HEADERS
  // =========================
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static void _ensureAuth() {
    if (_token == null) throw Exception("User not authenticated");
  }

  // =========================
  // 💾 AUTH STORAGE
  // =========================
  static Future<void> saveAuth(String token, String roleValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
    await prefs.setString("role", roleValue);

    _token = token;
    _role = roleValue;
    role = roleValue; // ✅ FIX
  }

  static Future<bool> loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("token");
    _role = prefs.getString("role");

    role = _role; // ✅ FIX

    return _token != null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _token = null;
    _role = null;
    role = null; // ✅ FIX
  }

  // =========================
  // 🌍 GENERIC REQUEST HANDLER
  // =========================
  static Future<dynamic> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool authRequired = true,
  }) async {
    if (authRequired) _ensureAuth();

    final uri = Uri.parse('$baseUrl$endpoint');

    http.Response response;

    switch (method) {
      case "GET":
        response = await http.get(uri, headers: _headers);
        break;
      case "POST":
        response = await http.post(
          uri,
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case "PUT":
        response = await http.put(
          uri,
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case "DELETE":
        response = await http.delete(uri, headers: _headers);
        break;
      default:
        throw Exception("Invalid HTTP method");
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } else {
      throw Exception("API Error (${response.statusCode}): ${response.body}");
    }
  }

  // =========================
  // 🔐 AUTH APIs
  // =========================
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final data = await _request(
      "POST",
      "/auth/login",
      body: {
        "email": email,
        "password": password,
      },
      authRequired: false,
    );

    await saveAuth(data["access_token"], data["role"]);
    return data;
  }

  static Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    await _request(
      "POST",
      "/auth/register",
      body: {
        "name": name,
        "email": email,
        "password": password,
        "role": role,
      },
      authRequired: false,
    );
  }

  // =========================
  // 📦 PRODUCT APIs
  // =========================
  static Future<List<Product>> getProducts() async {
    final data = await _request("GET", "/products/");
    return (data as List).map((e) => Product.fromJson(e)).toList();
  }

  static Future<Map<String, dynamic>> addProduct({
    required String name,
    required String brand,
    required int price,
    required int stock,
  }) async {
    return await _request(
      "POST",
      "/products/",
      body: {
        "name": name,
        "brand": brand,
        "price": price,
        "stock": stock,
      },
    );
  }

  static Future<Map<String, dynamic>> updateProduct({
    required int id,
    required String name,
    required String brand,
    required int price,
    required int stock,
  }) async {
    return await _request(
      "PUT",
      "/products/$id",
      body: {
        "name": name,
        "brand": brand,
        "price": price,
        "stock": stock,
      },
    );
  }

  static Future<void> deleteProduct(int id) async {
    await _request("DELETE", "/products/$id");
  }

  static Future<List<dynamic>> searchProducts(String query) async {
    return await _request("GET", "/products/search?query=$query");
  }

  static Future<void> sellProduct(int productId, int quantity) async {
    await _request(
      "POST",
      "/products/sell/$productId?quantity=$quantity",
    );
  }

  // 🔥 FIXED HISTORY API
  static Future<List<dynamic>> getProductHistory(int productId) async {
    return await _request("GET", "/products/$productId/history");
  }

  // =========================
  // 📩 STOCK REQUEST APIs
  // =========================
  static Future<void> createRequest({
    required int productId,
    required int quantity,
  }) async {
    await _request(
      "POST",
      "/requests/",
      body: {
        "product_id": productId,
        "quantity": quantity,
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getRequests() async {
    final data = await _request("GET", "/requests/");
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> updateRequest(int id, String status) async {
    await _request("PUT", "/requests/$id?status=$status");
  }

  // =========================
  // 👥 MANAGER APIs
  // =========================
  static Future<void> createManager({
    required String name,
    required String email,
    required String password,
  }) async {
    await _request(
      "POST",
      "/auth/create-user",
      body: {
        "name": name,
        "email": email,
        "password": password,
        "role": "manager",
      },
    );
  }

  static Future<List<dynamic>> getManagers() async {
    return await _request("GET", "/auth/managers");
  }

  static Future<void> deleteManager(int id) async {
    await _request("DELETE", "/auth/managers/$id");
  }

  // =========================
  // 📊 DASHBOARD
  // =========================
  static Future<Map<String, dynamic>> getDashboard() async {
    return await _request("GET", "/reports/summary");
  }
}