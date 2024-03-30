// 28.03.2024 // main.dart // Main project file

import 'package:flutter/material.dart';
import 'package:travel_manager_final/views/splash.dart';
import "package:travel_manager_final/views/auth/login.dart";
import "package:travel_manager_final/views/auth/register.dart";
import "package:travel_manager_final/views/auth/confirm_email.dart";

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
        "/confirm_email": (context) => const ConfirmEmailPage(),
      },
      theme: ThemeData(
        fontFamily: "Pro",
        colorScheme: const ColorScheme.light(
          background: Color(0xFFFFFFFF),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
