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

// Login Page
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  bool _isRegistering = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Title
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Color(0xFF007AFF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  CupertinoIcons.cube_box,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 32),
              Text(
                'HM Sportsgear',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'HM Equipment Verleih',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 48),

              // Form Fields
              if (_isRegistering)
                _buildTextField(
                  controller: _fullNameController,
                  placeholder: 'Vollständiger Name',
                  icon: CupertinoIcons.person,
                ),
              _buildTextField(
                controller: _emailController,
                placeholder: 'E-Mail (@hm.edu)',
                icon: CupertinoIcons.mail,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                controller: _passwordController,
                placeholder: 'Passwort',
                icon: CupertinoIcons.lock,
                isPassword: true,
              ),

              SizedBox(height: 32),

              // Action Button
              Container(
                width: double.infinity,
                height: 54,
                child: CupertinoButton(
                  color: Color(0xFF007AFF),
                  borderRadius: BorderRadius.circular(16),
                  onPressed: _isLoading ? null : _handleAuth,
                  child:
                      _isLoading
                          ? CupertinoActivityIndicator(color: Colors.white)
                          : Text(
                            _isRegistering ? 'Registrieren' : 'Anmelden',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),

              SizedBox(height: 16),

              // Toggle Button
              CupertinoButton(
                onPressed: () {
                  setState(() {
                    _isRegistering = !_isRegistering;
                  });
                },
                child: Text(
                  _isRegistering
                      ? 'Bereits registriert? Anmelden'
                      : 'Noch kein Account? Registrieren',
                  style: TextStyle(color: Color(0xFF007AFF)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(20),
        ),
      ),
    );
  }

  void _handleAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showAlert('Fehler', 'Bitte alle Felder ausfüllen');
      return;
    }

    if (!_emailController.text.endsWith('@hm.edu')) {
      _showAlert('Fehler', 'Nur HM E-Mail-Adressen sind erlaubt');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isRegistering) {
        if (_fullNameController.text.isEmpty) {
          _showAlert('Fehler', 'Name ist erforderlich');
          return;
        }
        await ApiService.register(
          _fullNameController.text,
          _emailController.text,
          _passwordController.text,
        );
      } else {
        await ApiService.login(_emailController.text, _passwordController.text);
      }

      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => LocationSelectionPage()),
      );
    } catch (e) {
      _showAlert('Fehler', e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

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
}

// Location Selection Page
class LocationSelectionPage extends StatelessWidget {
  final List<Map<String, dynamic>> locations = [
    {
      'name': 'PASING',
      'displayName': 'Campus Pasing',
      'icon': CupertinoIcons.building_2_fill,
      'color': Color(0xFF007AFF),
    },
    {
      'name': 'LOTHSTRASSE',
      'displayName': 'Campus Lothstraße',
      'icon': CupertinoIcons.location_fill,
      'color': Color(0xFF32D74B),
    },
    {
      'name': 'KARLSTRASSE',
      'displayName': 'Campus Karlstraße',
      'icon': CupertinoIcons.map_fill,
      'color': Color(0xFFFF9500),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            children: [
              SizedBox(height: 40),
              Text(
                'Standort wählen',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Wähle deinen Campus aus',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 48),
              Expanded(
                child: ListView.builder(
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    final location = locations[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder:
                                  (context) => HomePage(
                                    selectedLocation: location['name'],
                                    locationDisplayName:
                                        location['displayName'],
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Color(0xFF1C1C1E),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: location['color'].withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: location['color'].withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  location['icon'],
                                  color: location['color'],
                                  size: 30,
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                  location['displayName'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Icon(
                                CupertinoIcons.chevron_right,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
