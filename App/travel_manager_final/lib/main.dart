// 28.03.2024 // main.dart // Main project file

import 'package:flutter/material.dart';
import 'package:travel_manager_final/domain/service.dart';
import 'package:travel_manager_final/views/splash.dart';
import "package:travel_manager_final/views/auth/login.dart";
import "package:travel_manager_final/views/auth/register.dart";
import "package:travel_manager_final/views/auth/confirm_email.dart";
import "package:travel_manager_final/views/auth/reset_password.dart";
import 'package:travel_manager_final/views/main/home.dart';
import 'package:travel_manager_final/views/main/create_travel/main_data.dart';

final service = Service(serveraddr: "4pj9zgm4-80.euw.devtunnels.ms");

void main() {
  service.init();

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
        "/reset_password": (context) => const ResetPasswordPage(),
        "/home": (context) => const Home(),
        "/create": (context) => const CreateTravelMainData(),
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
