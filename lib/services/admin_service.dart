import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kreisel_frontend/models/item_model.dart';
import 'package:kreisel_frontend/models/rental_model.dart';
import 'package:kreisel_frontend/models/user_model.dart';

class AdminService {
  static const String baseUrl = 'http://your-api-url/api';
  static const String tokenKey = 'admin_token';

  static Future<Map<String, String>> _getAdminHeaders() async {
    final token = await _getAdminToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<String?> _getAdminToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Admin Items Management
  static Future<List<Item>> getAllItems() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/items'),
      headers: await _getAdminHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Item.fromJson(json)).toList();
    }
    throw Exception('Failed to load items');
  }

  static Future<void> deleteItem(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/items/$id'),
      headers: await _getAdminHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete item');
    }
  }

  static Future<Item> createItem(Item item) async {
    final response = await http.post(
      Uri.parse('$baseUrl/items'),
      headers: await _getAdminHeaders(),
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode == 200) {
      return Item.fromJson(jsonDecode(response.body));
    }
    throw Exception(_handleError(response));
  }

  static Future<Item> updateItem(int id, Item item) async {
    final response = await http.put(
      Uri.parse('$baseUrl/items/$id'),
      headers: await _getAdminHeaders(),
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode == 200) {
      return Item.fromJson(jsonDecode(response.body));
    }
    throw Exception(_handleError(response));
  }

  static Future<Item> getItemById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/items/$id'),
      headers: await _getAdminHeaders(),
    );

    if (response.statusCode == 200) {
      return Item.fromJson(jsonDecode(response.body));
    }
    throw Exception(_handleError(response));
  }

  // Admin Rentals Management
  static Future<List<Rental>> getAllRentals() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/rentals'),
      headers: await _getAdminHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Rental.fromJson(json)).toList();
    }
    throw Exception('Failed to load rentals');
  }
  
  static Future<Rental> getRentalById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/rentals/$id'),
      headers: await _getAdminHeaders(),
    );

    if (response.statusCode == 200) {
      return Rental.fromJson(jsonDecode(response.body));
    }
    throw Exception(_handleError(response));
  }

  // Admin Users Management
  static Future<List<User>> getAllUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/users'),
      headers: await _getAdminHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    }
    throw Exception(_handleError(response));
  }

  // Get active rentals for specific user
  static Future<List<Rental>> getActiveRentalsByUser(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/rentals/user/$userId/active'),
      headers: await _getAdminHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Rental.fromJson(json)).toList();
    }
    throw Exception(_handleError(response));
  }

  // Get rental history for specific user
  static Future<List<Rental>> getHistoricalRentalsByUser(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/rentals/user/$userId/history'),
      headers: await _getAdminHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Rental.fromJson(json)).toList();
    }
    throw Exception(_handleError(response));
  }

  // Error handling helper
  static String _handleError(http.Response response) {
    switch (response.statusCode) {
      case 401:
        return 'Nicht autorisiert - Bitte melden Sie sich als Admin an';
      case 403:
        return 'Keine Berechtigung für diese Aktion';
      case 404:
        return 'Ressource nicht gefunden';
      default:
        return 'Ein Fehler ist aufgetreten (${response.statusCode})';
    }
  }
}
