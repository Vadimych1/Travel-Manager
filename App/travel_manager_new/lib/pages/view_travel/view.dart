import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
// import "../../uikit/uikit.dart";
import "package:flutter_svg/flutter_svg.dart";
import "../main/main_travels.dart";
import "package:http/http.dart";

class ViewTravel extends StatefulWidget {
  const ViewTravel({super.key, required this.travelId});

  final int travelId;

  @override
  State<ViewTravel> createState() => _ViewTravelState();
}

class _ViewTravelState extends State<ViewTravel> {
  List<Widget> content = [];

  @override
  void initState() {
    super.initState();

    var s = const FlutterSecureStorage();

    s.read(key: "username").then(
      (usr) {
        s.read(key: "password").then(
          (pwd) {
            get(
              Uri.https(
                "x1f9tspp-80.euw.devtunnels.ms",
                "get_travel",
                {
                  "username": usr,
                  "password": pwd,
                  "id": widget.travelId.toString(),
                },
              ),
            ).then((r) {
              try {
                var resp = jsonDecode(Uri.decodeComponent(r.body)
                    .replaceAll("\"[{", "[{")
                    .replaceAll("}]\"", "}]")
                    .replaceAll("+", " "));
                print(resp);

                if (resp["status"] == "success") {
                  print("Successful get travel.");
                  var travel = resp["content"];

                  content = [
                    Container(
                      margin: const EdgeInsets.only(top: 40),
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Text(
                            "${travel["plan_name"]}",
                            style: const TextStyle(
                              fontFamily: "Pro",
                              fontSize: 16,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                          Text("${travel["fromDate"]}",)
                        ],
                      ),
                    ),
                  ];
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "Произошла ошибка. Попробуйте выйти из режима просмотра и повторить попытку"),
                    ),
                  );
                }
              } catch (e) {
                print("Error");
                print(e);
              }
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BG
          Container(
            color: const Color(0xFF005E72),
          ),

          // Unfocus
          GestureDetector(
            onTap: () {
              FocusScopeNode focus = FocusScope.of(context);
              if (focus.hasFocus || focus.hasPrimaryFocus) {
                focus.unfocus();
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
            ),
          ),

          // Back button
          Container(
            margin: const EdgeInsets.only(
              top: 57,
              left: 0,
            ),
            child: TextButton(
              child: SvgPicture.asset(
                "assets/images/svg/arrow_back.svg",
                color: const Color(
                  0xFFFFFFFF,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const MainTravels()));
              },
            ),
          ),

          // Content
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(
              top: 30,
            ),
            child: Column(
              children: [
                const Text(
                  "Просмотр поездки",
                  style: TextStyle(
                    fontFamily: "Pro",
                    color: Color(0xFFFFFFFF),
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                Column(
                  children: content,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
