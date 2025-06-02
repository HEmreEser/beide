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

class MyRentalsPage extends StatefulWidget {
  // UserId wird hier fix auf 3 gesetzt
  final int userId = 3;

  @override
  _MyRentalsPageState createState() => _MyRentalsPageState();
}

class _MyRentalsPageState extends State<MyRentalsPage> {
  List<Rental> _rentals = [];
  bool _isLoading = true;

  void _showAlert(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadRentals();
  }

  Future<void> _loadRentals() async {
    try {
      final rentals = await ApiServiceExtension.getUserRentals();
      setState(() {
        _rentals = rentals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showAlert('Fehler', 'Ausleihen konnten nicht geladen werden');
    }
  }

  Future<void> _returnItem(Rental rental) async {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: Text('Item zurückgeben'),
            content: Text(
              'Möchten Sie "${rental.itemName}" wirklich zurückgeben?',
            ),
            actions: [
              CupertinoDialogAction(
                child: Text('Abbrechen'),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text('Zurückgeben'),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await ApiServiceExtension.returnItem(rental.id);
                    _showAlert('Erfolgreich', 'Item wurde zurückgegeben!');
                    _loadRentals();
                  } catch (e) {
                    _showAlert(
                      'Fehler',
                      'Rückgabe fehlgeschlagen: ${e.toString()}',
                    );
                  }
                },
              ),
            ],
          ),
    );
  }

  Future<void> _extendRental(Rental rental) async {
    DateTime selectedDate = rental.endDate.add(Duration(days: 7));
    final maxDate = DateTime.now().add(Duration(days: 60));

    showCupertinoDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              return CupertinoAlertDialog(
                title: Text('Ausleihe verlängern'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 16),
                    Text('${rental.itemName}'),
                    SizedBox(height: 16),
                    Text('Neues Rückgabedatum:'),
                    SizedBox(height: 16),
                    Container(
                      height: 200,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: selectedDate,
                        minimumDate: rental.endDate.add(Duration(days: 1)),
                        maximumDate: maxDate,
                        onDateTimeChanged: (DateTime date) {
                          setDialogState(() {
                            selectedDate = date;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                actions: [
                  CupertinoDialogAction(
                    child: Text('Abbrechen'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoDialogAction(
                    child: Text('Verlängern'),
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        await ApiServiceExtension.extendRental(
                          rental.id,
                          selectedDate,
                        );
                        _showAlert('Erfolgreich', 'Ausleihe wurde verlängert!');
                        _loadRentals();
                      } catch (e) {
                        _showAlert(
                          'Fehler',
                          'Verlängerung fehlgeschlagen: ${e.toString()}',
                        );
                      }
                    },
                  ),
                ],
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeRentals = _rentals.where((r) => r.status == 'ACTIVE').toList();
    final pastRentals = _rentals.where((r) => r.status != 'ACTIVE').toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(24),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Icon(CupertinoIcons.back, color: Color(0xFF007AFF)),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Meine Ausleien',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child:
                  _isLoading
                      ? Center(child: CupertinoActivityIndicator())
                      : RefreshIndicator(
                        onRefresh: _loadRentals,
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Aktuelle Ausleihen
                              Text(
                                'Aktuelle Ausleihen (${activeRentals.length})',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 16),
                              if (activeRentals.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1C1C1E),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'Keine aktiven Ausleihen',
                                    style: TextStyle(color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              else
                                ...activeRentals.map(
                                  (rental) => _buildActiveRentalCard(rental),
                                ),

                              SizedBox(height: 32),

                              // Vergangene Ausleihen
                              Text(
                                'Vergangene Ausleihen (${pastRentals.length})',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 16),
                              if (pastRentals.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1C1C1E),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'Keine vergangenen Ausleihen',
                                    style: TextStyle(color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              else
                                ...pastRentals.map(
                                  (rental) => _buildPastRentalCard(rental),
                                ),
                            ],
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveRentalCard(Rental rental) {
    final isOverdue = rental.endDate.isBefore(DateTime.now());
    final daysUntilDue = rental.endDate.difference(DateTime.now()).inDays;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isOverdue
                  ? Color(0xFFFF453A)
                  : daysUntilDue <= 3
                  ? Color(0xFFFF9500)
                  : Color(0xFF32D74B),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    rental.itemName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        isOverdue
                            ? Color(0xFFFF453A)
                            : daysUntilDue <= 3
                            ? Color(0xFFFF9500)
                            : Color(0xFF32D74B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isOverdue
                        ? 'Überfällig'
                        : daysUntilDue <= 3
                        ? 'Bald fällig'
                        : 'Aktiv',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            if (rental.itemBrand != null)
              Text(
                rental.itemBrand!,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            if (rental.itemSize != null)
              Text(
                'Größe: ${rental.itemSize}',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),

            SizedBox(height: 12),

            Row(
              children: [
                Icon(CupertinoIcons.calendar, color: Colors.grey, size: 16),
                SizedBox(width: 8),
                Text(
                  'Bis: ${_formatDate(rental.endDate)}',
                  style: TextStyle(
                    color: isOverdue ? Color(0xFFFF453A) : Colors.white70,
                    fontSize: 14,
                    fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),

            if (isOverdue)
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  '${DateTime.now().difference(rental.endDate).inDays} Tage überfällig',
                  style: TextStyle(
                    color: Color(0xFFFF453A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (daysUntilDue <= 7)
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  daysUntilDue == 0
                      ? 'Heute fällig'
                      : daysUntilDue == 1
                      ? 'Morgen fällig'
                      : 'In $daysUntilDue Tagen fällig',
                  style: TextStyle(
                    color:
                        daysUntilDue <= 3 ? Color(0xFFFF9500) : Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    color: Color(0xFF007AFF),
                    borderRadius: BorderRadius.circular(12),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Verlängern'),
                    onPressed: () => _extendRental(rental),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: CupertinoButton(
                    color: Color(0xFFFF453A),
                    borderRadius: BorderRadius.circular(12),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Zurückgeben'),
                    onPressed: () => _returnItem(rental),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastRentalCard(Rental rental) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rental.itemName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (rental.itemBrand != null)
            Text(
              rental.itemBrand!,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          if (rental.itemSize != null)
            Text(
              'Größe: ${rental.itemSize}',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(CupertinoIcons.calendar, color: Colors.grey, size: 16),
              SizedBox(width: 8),
              Text(
                'Bis: ${_formatDate(rental.endDate)}',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
