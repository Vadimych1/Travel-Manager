import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import '../socketclient.dart';
import 'package:tcp_socket_connection/tcp_socket_connection.dart';
import '../mainpages/mainpage.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  // bool checkEmailAndPassword() {
  //   bool email = RegExp(
  //     r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  //   ).hasMatch(
  //     _email.text,
  //   );

  //   bool password = _password.text.length > 7;

  //   return email && password;
  // }

  var responce = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height - 220,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 220,
                child: Image.asset(
                  "assets/images/backgrounds/login_back.png",
                  fit: BoxFit.fill,
                ),
              ),
            ],
          ),

          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Margin
              const SizedBox(
                height: 80,
              ),
              // Center text
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Вход",
                    style: TextStyle(
                      fontSize: 40,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              // Margin
              const SizedBox(
                height: 28,
              ),
              // Inputs
              // Email
              SizedBox(
                width: 300,
                height: 41,
                child: TextField(
                  controller: _email,
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color.fromRGBO(225, 225, 225, 1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color.fromRGBO(225, 225, 225, 1),
                      ),
                    ),
                    hintText: "email",
                    hintStyle: const TextStyle(
                      color: Color.fromRGBO(130, 130, 130, 1),
                      fontSize: 26,
                      fontWeight: FontWeight.w300,
                    ),
                    contentPadding: const EdgeInsets.only(top: 0, left: 10),
                  ),
                  textAlign: TextAlign.left,
                ),
              ),

              // Margin
              const SizedBox(
                height: 28,
              ),

              // Password
              SizedBox(
                width: 300,
                height: 41,
                child: TextField(
                  controller: _password,
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color.fromRGBO(225, 225, 225, 1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color.fromRGBO(225, 225, 225, 1),
                      ),
                    ),
                    hintText: "пароль",
                    hintStyle: const TextStyle(
                      color: Color.fromRGBO(130, 130, 130, 1),
                      fontSize: 26,
                      fontWeight: FontWeight.w300,
                    ),
                    contentPadding: const EdgeInsets.only(top: 0, left: 10),
                  ),
                  textAlign: TextAlign.left,
                ),
              ),

              // Margin
              const SizedBox(
                height: 78,
              ),

              // Send button
              Container(
                width: 169,
                height: 44,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextButton(
                  onPressed: () async {
                    // Check email & password
                    if (_email.text.trim() == _email.text &&
                        _password.text.trim() == _password.text &&
                        _email.text.isNotEmpty &&
                        _password.text.isNotEmpty) {
                      // Create socket connection
                      TcpSocketConnection s =
                          createConnection("127.0.0.1", 2020);

                      // Data to bytes
                      var codeBytes = ByteData(8);
                      codeBytes.setInt32(0, 0.toInt(), Endian.big);

                      Uint8List codeBytes_ = codeBytes.buffer.asUint8List();
                      codeBytes_ = codeBytes_.sublist(0, codeBytes_.length - 4);

                      var dS = json.encode(
                        {
                          "email": _email.text.trim(),
                          "password": sha256
                              .convert(utf8.encode(_password.text))
                              .toString(),
                        },
                      );

                      var data = utf8.encode(dS);

                      var lenBytes = ByteData(8);
                      lenBytes.setInt32(0, data.length.toInt(), Endian.big);

                      Uint8List lenBytes_ = lenBytes.buffer.asUint8List();
                      lenBytes_ = lenBytes_.sublist(0, lenBytes_.length - 4);

                      if (await s.canConnect(5000, attempts: 3)) {
                        s.enableConsolePrint(true);
                        await s.connect(5000, (data) {
                          responce = data.toString();

                          data = data.split("|");

                          if (data[0] == "ok") {
                            var json_ = jsonDecode(data[2]);

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MainPage(
                                    subto: json_["subto"], name: json_["name"]),
                              ),
                            );
                          } else {
                            const alert = SnackBar(
                              content: Text(
                                "Аккаунт не существует или пароль указан неверно.",
                              ),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(alert);
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
                            "Произошла ошибка: невозможно подключиться к серверу. Попробуйте ещё раз.",
                          ),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(alert);
                      }

                      s.disconnect();
                    } else {
                      const alert = SnackBar(
                        content: Text(
                          "Вы не ввели пароль/email, либо они введены некорректно.",
                        ),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(alert);
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.white,
                    ),
                  ),
                  child: const Text(
                    "Войти",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Back button
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "Назад",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                color: Colors.black,
              ),
            ),
          ),

          // DEBUG LOGIN
          Container(
            margin: const EdgeInsets.only(left: 100),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MainPage(
                      subto: "notsub",
                      name: "Imya",
                    ),
                  ),
                );
              },
              child: const Text(
                "Debug",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
