import 'package:flutter/material.dart';
import 'login/login.dart';
import 'register/register.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../socketclient.dart';
import 'package:tcp_socket_connection/tcp_socket_connection.dart';
import 'mainpages/mainpage.dart';
import 'dart:convert';
import 'dart:typed_data';

// import 'socketclient.dart';
// import 'package:tcp_socket_connection/tcp_socket_connection.dart';

class GreetingPage extends StatefulWidget {
  GreetingPage({super.key});

  State<GreetingPage> createState() => GreetingPageState();
}

class GreetingPageState extends State<GreetingPage> {
  final storage = const FlutterSecureStorage();

  Future<String> getToken() async {
    final token = await storage.read(key: "jwt");
    if (token == null) {
      return "";
    }
    return token;
  }

  Future<String> getUsername() async {
    final username = await storage.read(key: "username");
    if (username == null) {
      return "";
    }
    return username;
  }

  @override
  void initState() {
    super.initState();
    getToken().then(
      (token) {
        getUsername().then((username) {
          if (token != "" && username != "") {
            print("Logging in");
            // Autorization with JWT
            void a() async {
              // Create socket connection
              TcpSocketConnection s = createConnection("127.0.0.1", 2020);

              // Data to bytes
              var codeBytes = ByteData(8);
              codeBytes.setInt32(0, 2.toInt(), Endian.big);

              Uint8List codeBytes_ = codeBytes.buffer.asUint8List();
              codeBytes_ = codeBytes_.sublist(0, codeBytes_.length - 4);

              var dS = "$username|$token";

              var data = utf8.encode(dS);

              var lenBytes = ByteData(8);
              lenBytes.setInt32(0, data.length.toInt(), Endian.big);

              Uint8List lenBytes_ = lenBytes.buffer.asUint8List();
              lenBytes_ = lenBytes_.sublist(0, lenBytes_.length - 4);

              if (await s.canConnect(5000, attempts: 3)) {
                s.enableConsolePrint(true);
                await s.connect(5000, (data) {
                  data = data.split("|");

                  if (data[0] == "ok") {
                    var json_ = jsonDecode(data[2]);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MainPage(
                          subto: json_["subto"],
                          name: json_["name"],
                        ),
                      ),
                    );
                  }
                });
                s.sendMessage(
                  String.fromCharCodes(codeBytes_) +
                      String.fromCharCodes(lenBytes_) +
                      String.fromCharCodes(data),
                );
              } else {
                const alert = SnackBar(
                  content: Text(
                    "Произошла ошибка: невозможно подключиться к серверу. Подключитесь к сети и повторите попытку.",
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(alert);
              }

              s.disconnect();
            }

            a();
          }
        });
      },
    );
  }

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
