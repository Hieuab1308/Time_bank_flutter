import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/app/app_shell.dart';
import 'package:time_bank_flutter/features/auth/ui/login_page.dart';
import 'package:time_bank_flutter/features/auth/providers/auth_providers.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final authState = ref.watch(authControllerProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Time Bank',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8FAFC),
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
        ),
        cardTheme: const CardTheme(
          color: Color(0xFFFFFFFF),
          surfaceTintColor: Colors.transparent,
          elevation: 1,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF020617),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF020617),
          foregroundColor: Color(0xFFF8FAFC),
          elevation: 0,
        ),
        cardTheme: const CardTheme(
          color: Color(0xFF0F172A),
          surfaceTintColor: Colors.transparent,
          elevation: 1,
        ),
      ),
      themeMode: ThemeMode.system,
      home: authState.authenticated
          ? const  AppShell()   // Nếu đã đăng nhập -> vào AppShell
          : const  LoginPage(),   // Nếu chưa (hoặc đã logout) -> về LoginPage

      routes: {
      },
    );
  }
}