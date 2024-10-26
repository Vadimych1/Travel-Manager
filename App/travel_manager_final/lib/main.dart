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
import 'package:travel_manager_final/views/main/create_travel/select_activities.dart';
import 'package:travel_manager_final/views/main/create_travel/select_town.dart';

final service = Service(serveraddr: "k9cwr7rf-80.euw.devtunnels.ms");

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
        "/create/select_town": (context) => const CreateTravelSelectTown(),
        "/create/select_activities": (context) =>
            const CreateTravelSelectActivities(),
      },
      theme: ThemeData(
        fontFamily: "Pro",
        colorScheme: const ColorScheme.light(
          surface: Color(0xFFFFFFFF),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
