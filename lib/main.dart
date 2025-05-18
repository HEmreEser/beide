import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my_loans_screen.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const ProviderScope(child: HMSportsgearApp()));
}

class HMSportsgearApp extends ConsumerWidget {
  const HMSportsgearApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return MaterialApp(
      title: 'HM Sportsgear',
      debugShowCheckedModeBanner: false,
      theme: buildAppleDarkTheme(),
      routes: {
        '/': (_) => auth.isLoggedIn ? const HomeScreen() : const LoginScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
        '/myloans': (_) => const MyLoansScreen(),
      },
      initialRoute: '/',
    );
  }
}
