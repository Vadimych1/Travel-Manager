import 'package:flutter/material.dart';
import 'login/login.dart';
import 'register/register.dart';

// import 'socketclient.dart';
// import 'package:tcp_socket_connection/tcp_socket_connection.dart';

class GreetingPage extends StatelessWidget {
  GreetingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background images

          Positioned.fill(
            child: Column(
              children: [
                Image.asset(
                  "assets/images/backgrounds/greetingpage_sun.png",
                  alignment: Alignment.topCenter,
                  fit: BoxFit.fitWidth,
                ),
              ],
            ),
          ),

          Positioned.fill(
            child: Image.asset(
              "assets/images/backgrounds/greetingpage_mountains.png",
              alignment: Alignment.bottomCenter,
              fit: BoxFit.fitWidth,
            ),
          ),

          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Margin
              const SizedBox(
                height: 80,
              ),

              // Autorization text
              const Text(
                "Авторизация",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w200),
              ),

              // Margin
              const SizedBox(
                height: 178,
              ),

              // Buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Login
                  Container(
                    width: 130,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.white,
                        ),
                      ),
                      child: const Text(
                        "Вход",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                  // Margin
                  const SizedBox(
                    width: 10,
                  ),

                  // Register
                  Container(
                    width: 230,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromRGBO(80, 79, 79, 1),
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromRGBO(80, 79, 79, 1),
                        ),
                      ),
                      child: const Text(
                        "Регистрация",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
