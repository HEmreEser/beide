import 'package:dio/dio.dart';

class ApiService {
  static final Dio _dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:8080/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    )
    ..interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) {
          print('=== API Error ===');
          print('Request URL: ${e.requestOptions.uri}');
          print('Request Method: ${e.requestOptions.method}');
          print('Request Data: ${e.requestOptions.data}');
          print('Response Status: ${e.response?.statusCode}');
          print('Response Data: ${e.response?.data}');
          print('Error Message: ${e.message}');
          print('================');
          return handler.next(e);
        },
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
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final res = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return res.data;
  }

  static Future<Map<String, dynamic>> register(
    String email,
    String password,
  ) async {
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

  // Equipment Management (Admin)
  static Future<Map<String, dynamic>> createEquipment({
    required String name,
    required String description,
    required String category,
    required bool available,
  }) async {
    final res = await _dio.post(
      '/equipment',
      data: {
        'name': name,
        'description': description,
        'category': category,
        'available': available,
      },
    );
    return res.data;
  }

  static Future<void> deleteEquipment(int equipmentId) async {
    await _dio.delete('/equipment/$equipmentId');
  }

  // Rentals
  static Future<List<dynamic>> getMyRentals() async {
    try {
      final res = await _dio.get('/rentals/user');
      return res.data;
    } catch (e) {
      print('Error getting rentals: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createRental(
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

  static Future<Map<String, dynamic>> returnRental(int rentalId) async {
    final res = await _dio.post('/rentals/$rentalId/return');
    return res.data;
  }

  // Reviews
  static Future<List<dynamic>> getReviews(int equipmentId) async {
    final res = await _dio.get('/equipment/$equipmentId/reviews');
    return res.data;
  }

  static Future<Map<String, dynamic>> createReview({
    required int equipmentId,
    required int rating,
    required String comment,
  }) async {
    final res = await _dio.post(
      '/equipment/$equipmentId/reviews',
      data: {'rating': rating, 'comment': comment},
    );
    return res.data;
  }
}
