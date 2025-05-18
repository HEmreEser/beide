import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  String? token;

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      token = json.decode(response.body)['token']; // falls JWT zurückkommt
      return true;
    }
    return false;
  }
}
