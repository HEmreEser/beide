import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final email = prefs.getString('email');
    if (token != null) {
      ApiService.setToken(token);
      state = AuthState(token: token, email: email);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final res = await ApiService.login(email, password);
      // If you get a proper token from backend, adjust this line:
      final token = res['token'] ?? "dummy_token";
      state = AuthState(token: token, email: email);
      ApiService.setToken(token);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token);
      prefs.setString('email', email);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      await ApiService.register(email, password);
      return true;
    } catch (_) {
      return false;
    }
  }

  void logout() async {
    state = const AuthState();
    ApiService.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('email');
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
