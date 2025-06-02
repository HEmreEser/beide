import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kreisel_frontend/models/user_model.dart';
import 'package:kreisel_frontend/models/item_model.dart';
import 'package:kreisel_frontend/models/rental_model.dart';
import 'package:kreisel_frontend/pages/login_page.dart';
import 'package:kreisel_frontend/pages/home_page.dart';
import 'package:kreisel_frontend/pages/my_rentals_page.dart';
import 'package:kreisel_frontend/services/api_service.dart';

// API Service
class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';
  static User? currentUser;

  static Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final user = User.fromJson(jsonDecode(response.body));
      currentUser = user;
      return user;
    } else {
      throw Exception('Login fehlgeschlagen');
    }
  }

  static Future<User> register(
    String fullName,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final user = User.fromJson(jsonDecode(response.body));
      currentUser = user;
      return user;
    } else {
      throw Exception('Registrierung fehlgeschlagen');
    }
  }

  static Future<List<Item>> getItems({
    required String location,
    bool? available,
    String? searchQuery,
    String? gender,
    String? category,
    String? subcategory,
    String? size,
  }) async {
    var params = {'location': location};
    if (available != null) params['available'] = available.toString();
    if (searchQuery != null && searchQuery.isNotEmpty)
      params['searchQuery'] = searchQuery;
    if (gender != null) params['gender'] = gender;
    if (category != null) params['category'] = category;
    if (subcategory != null) params['subcategory'] = subcategory;
    if (size != null) params['size'] = size;

    final uri = Uri.parse('$baseUrl/items').replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Fehler beim Laden der Items');
    }
  }
}

class ApiServiceExtension {
  static Future<void> rentItem(int itemId, String formattedDate) async {
    final userId = ApiService.currentUser?.userId;
    if (userId == null) {
      throw Exception('Benutzer nicht angemeldet.');
    }

    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/rentals/user/$userId/rent'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'itemId': itemId, 'endDate': formattedDate}),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Ausleihe fehlgeschlagen');
    }
  }

  static Future<List<Rental>> getUserRentals() async {
    final response = await http.get(
      Uri.parse(
        '${ApiService.baseUrl}/rentals/user/${ApiService.currentUser?.userId}',
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Rental.fromJson(json)).toList();
    } else {
      throw Exception('Fehler beim Laden der Ausleihen');
    }
  }

  static Future<void> returnItem(int rentalId) async {
    final response = await http.put(
      Uri.parse('${ApiService.baseUrl}/rentals/$rentalId/return'),
    );

    if (response.statusCode != 200) {
      throw Exception('Rückgabe fehlgeschlagen');
    }
  }

  static Future<void> extendRental(int rentalId, DateTime newEndDate) async {
    final formattedDate =
        "${newEndDate.year}-${newEndDate.month.toString().padLeft(2, '0')}-${newEndDate.day.toString().padLeft(2, '0')}";

    final response = await http.put(
      Uri.parse('${ApiService.baseUrl}/rentals/$rentalId/extend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'newEndDate': formattedDate}),
    );

    if (response.statusCode != 200) {
      throw Exception('Verlängerung fehlgeschlagen');
    }
  }
}

class RentItemDialog extends StatefulWidget {
  final Item item;
  final VoidCallback onRented;

  RentItemDialog({required this.item, required this.onRented});

  @override
  _RentItemDialogState createState() => _RentItemDialogState();
}

class _RentItemDialogState extends State<RentItemDialog> {
  int selectedMonths = 1; // Standard: 1 Monat
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final returnDate = _calculateReturnDate();
    final formattedDate =
        "${returnDate.year}-${returnDate.month.toString().padLeft(2, '0')}-${returnDate.day.toString().padLeft(2, '0')}";

    return CupertinoAlertDialog(
      title: Text('${widget.item.name} ausleihen'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16),
          if (widget.item.brand != null)
            Text(
              'Marke: ${widget.item.brand}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          if (widget.item.size != null)
            Text(
              'Größe: ${widget.item.size}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          SizedBox(height: 16),
          Text('Ausleihdauer wählen:'),
          SizedBox(height: 16),
          CupertinoSegmentedControl<int>(
            groupValue: selectedMonths,
            children: {
              1: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('1 Month'),
              ),
              2: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('2 Months'),
              ),
              3: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('3 Months'),
              ),
            },
            onValueChanged: (int value) {
              setState(() {
                selectedMonths = value;
              });
            },
          ),
          SizedBox(height: 16),
          Text(
            'Rückgabedatum: $formattedDate',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          child: Text('Abbrechen'),
          onPressed: () => Navigator.pop(context),
        ),
        CupertinoDialogAction(
          child:
              isLoading
                  ? CupertinoActivityIndicator()
                  : Text(
                    'Jetzt ausleihen',
                    style: TextStyle(color: Colors.white),
                  ),
          onPressed: isLoading ? null : _rentItem,
        ),
      ],
    );
  }

  DateTime _calculateReturnDate() {
    return DateTime.now().add(Duration(days: 30 * selectedMonths));
  }

  void _rentItem() async {
    setState(() => isLoading = true);

    try {
      final returnDate = _calculateReturnDate();
      final formattedDate =
          "${returnDate.year}-${returnDate.month.toString().padLeft(2, '0')}-${returnDate.day.toString().padLeft(2, '0')}";

      await ApiServiceExtension.rentItem(widget.item.id, formattedDate);
      Navigator.pop(context);
      widget.onRented();

      showCupertinoDialog(
        context: context,
        builder:
            (context) => CupertinoAlertDialog(
              title: Text('Erfolgreich ausgeliehen'),
              content: Text(
                '${widget.item.name} wurde bis zum $formattedDate reserviert.',
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
    } catch (e) {
      print('Fehler beim Ausleihen: $e');
      showCupertinoDialog(
        context: context,
        builder:
            (context) => CupertinoAlertDialog(
              title: Text('Fehler beim Ausleihen'),
              content: Text(e.toString()),
              actions: [
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
