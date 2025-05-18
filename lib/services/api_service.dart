import 'package:dio/dio.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8080/api', // CHANGE TO YOUR BACKEND URL
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static void setToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  // Auth
  static Future login(String email, String password) async {
    final res = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return res.data;
  }

  static Future register(String email, String password) async {
    final res = await _dio.post(
      '/auth/register',
      data: {'email': email, 'password': password},
    );
    return res.data;
  }

  // Equipment
  static Future<List<dynamic>> getEquipment({
    String? category,
    String? location,
  }) async {
    String endpoint = '/equipment';
    if (category != null) {
      endpoint = '/equipment/category/$category';
    } else if (location != null) {
      endpoint = '/equipment/location/$location';
    }
    final res = await _dio.get(endpoint);
    return res.data;
  }

  // Rentals
  static Future<List<dynamic>> getMyRentals() async {
    final res = await _dio.get('/rentals/user');
    return res.data;
  }

  static Future<dynamic> createRental(
    int equipmentId,
    String startDate,
    String endDate,
  ) async {
    final res = await _dio.post(
      '/rentals',
      data: {
        'equipmentId': equipmentId,
        'startDate': startDate,
        'endDate': endDate,
      },
    );
    return res.data;
  }

  static Future<dynamic> returnRental(int rentalId) async {
    final res = await _dio.post('/rentals/$rentalId/return');
    return res.data;
  }
}
