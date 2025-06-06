import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kreisel_frontend/pages/login_page.dart';
import 'package:kreisel_frontend/services/audio_service.dart';
import 'package:kreisel_frontend/services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // AudioService().initBackgroundMusic();  // Disabled background music
  runApp(KreiselApp());
}

class KreiselApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HM Sportsgear',
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFF007AFF),
        scaffoldBackgroundColor: Colors.black,
        cardColor: Color(0xFF1C1C1E),
        dividerColor: Color(0xFF38383A),
        // Add these to ensure text is visible
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
        ),
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
