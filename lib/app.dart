import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/layout/main_layout.dart';

class KreiselApp extends StatelessWidget {
  const KreiselApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kreisel Sportverleih',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const MainLayout(),
    );
  }
}
