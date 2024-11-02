// 28.03.2024 // splash.dart // Splash screen

import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:travel_manager_final/main.dart";
import "package:travel_manager_final/model/datatypes.dart";

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () async {
      try {
        AuthResult<Map<dynamic, dynamic>> r =
            (await service.auth.verifySession());
        if (r.success) {
          Navigator.of(context).pushReplacementNamed("/home");
        } else {
          Navigator.of(context).pushReplacementNamed("/login");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(r.message),
            ),
          );
        }
      } catch (e) {
        print(e);

        Navigator.of(context).pushReplacementNamed("/login");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Не удалось проверить сессию. Войдите заново или попробуйте перезайти в приложение",
            ),
          ),
        );
      }
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
