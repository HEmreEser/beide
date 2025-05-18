import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';

class AuthState {
  final String? token;
  final String? email;
  bool get isLoggedIn => token != null;
  const AuthState({this.token, this.email});
  AuthState copyWith({String? token, String? email}) =>
      AuthState(token: token ?? this.token, email: email ?? this.email);
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _load();
  }

  void _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final email = prefs.getString('email');
      if (token != null) {
        ApiService.setToken(token);
        state = AuthState(token: token, email: email);
      }
    } catch (e) {
      print('Error loading auth state: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      print('Attempting login with email: $email');
      final res = await ApiService.login(email, password);
      print('Login response: $res');

      final token = res['token'];
      if (token == null) {
        print('No token in response');
        return false;
      }

      state = AuthState(token: token, email: email);
      ApiService.setToken(token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('email', email);

      return true;
    } catch (e) {
      print('Login error details:');
      if (e is DioException) {
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
        print('Error type: ${e.type}');
      }
      print(e);
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      print('Attempting registration with email: $email');
      final res = await ApiService.register(email, password);
      print('Registration successful: $res');
      return true;
    } catch (e) {
      print('Registration error details:');
      if (e is DioException) {
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
        print('Error type: ${e.type}');
      }
      print(e);
      return false;
    }
  }

  void logout() async {
    try {
      state = const AuthState();
      ApiService.setToken(null);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('email');
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
