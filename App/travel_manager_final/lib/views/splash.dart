// 28.03.2024 // splash.dart // Splash screen

import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed("/login");
    });
    return Scaffold(
      backgroundColor: const Color(0xFF162125),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/logo.svg",
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 25),
              const Text(
                "Travel Manager",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
