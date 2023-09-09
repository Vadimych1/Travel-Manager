import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import '../socketclient.dart';
import 'package:tcp_socket_connection/tcp_socket_connection.dart';
import '../mainpages/mainpage.dart';
import 'package:translit/translit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool checkEmail() {
    bool email = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(
      _email.text,
    );

    return email;
  }

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
                    "Регистрация",
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
              // Name
              SizedBox(
                width: 300,
                height: 41,
                child: TextField(
                  controller: _name,
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
                    hintText: "имя",
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
                width: 284,
                height: 44,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextButton(
                  onPressed: () async {
                    // Check email & password
                    if (_password.text.trim() == _password.text &&
                        _email.text.isNotEmpty &&
                        _password.text.isNotEmpty &&
                        _name.text.isNotEmpty &&
                        checkEmail() &&
                        _password.text.length > 7) {
                      // Create socket connection
                      TcpSocketConnection s = createConnection(
                        "127.0.0.1",
                        2020,
                      );

                      // Data to bytes
                      var codeBytes = ByteData(8);
                      codeBytes.setInt32(0, 1.toInt(), Endian.big);

                      Uint8List codeBytes_ = codeBytes.buffer.asUint8List();
                      codeBytes_ = codeBytes_.sublist(0, codeBytes_.length - 4);

                      var dS = json.encode(
                        {
                          "name":
                              Translit().toTranslit(source: _name.text.trim()),
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

                            const storage = FlutterSecureStorage();

                            // write jwt
                            storage.write(
                              key: "jwt",
                              value: data[1],
                            );

                            // write username
                            storage.write(
                              key: "username",
                              value: _email.text.toLowerCase(),
                            );

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MainPage(
                                    subto: json_["subto"], name: json_["name"]),
                              ),
                            );
                          } else {
                            const alert = SnackBar(
                              content: Text(
                                "Аккаунт уже существует. Попробуйте войти в него.",
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
                          "Вы не ввели пароль/email/имя, либо они введены некорректно.",
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
                    "Зарегестрироваться",
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
          )
        ],
      ),
    );
  }
}