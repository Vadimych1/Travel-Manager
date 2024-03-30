import "package:flutter/material.dart";
import '../uikit/uikit.dart';
import 'package:http/http.dart';
import "dart:convert";
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ViewTravelAddReview extends StatefulWidget {
  const ViewTravelAddReview({super.key, required this.travelId});

  final int travelId;

  @override
  State<ViewTravelAddReview> createState() => _ViewTravelAddReviewState();
}

class _ViewTravelAddReviewState extends State<ViewTravelAddReview> {
  TextEditingController reviewTextController = TextEditingController();

  List<bool> starsActive = [false, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 50, bottom: 5),
            decoration: const BoxDecoration(
              color: Color(0xFF222222),
            ),
            child: const Row(
              children: [
                BackButton(
                  color: Color(0xFFFFFFFF),
                ),
                Text(
                  "Оставить отзыв",
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                Container(
                  width: 300,
                  child: TextField(
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                    ),
                    controller: reviewTextController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF333333),
                      hintText: "Текст отзыва",
                      hintStyle: const TextStyle(
                        color: Color(0xFFFFFFFF),
                      ),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.all(15),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ),

                // Stars
                Container(
                  width: 320,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        child: TextButton(
                          child: Icon(
                            starsActive[0] ? Icons.star : Icons.star_border,
                            fill: starsActive[0] ? 1 : 0,
                            size: 30,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(
                              () {
                                starsActive[0] = true;
                                starsActive[1] = false;
                                starsActive[2] = false;
                                starsActive[3] = false;
                                starsActive[4] = false;
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        child: TextButton(
                          child: Icon(
                            starsActive[1] ? Icons.star : Icons.star_border,
                            fill: starsActive[1] ? 1 : 0,
                            size: 30,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(
                              () {
                                starsActive[0] = true;
                                starsActive[1] = true;
                                starsActive[2] = false;
                                starsActive[3] = false;
                                starsActive[4] = false;
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        child: TextButton(
                          child: Icon(
                            starsActive[2] ? Icons.star : Icons.star_border,
                            fill: starsActive[2] ? 1 : 0,
                            size: 30,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(
                              () {
                                starsActive[0] = true;
                                starsActive[1] = true;
                                starsActive[2] = true;
                                starsActive[3] = false;
                                starsActive[4] = false;
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        child: TextButton(
                          child: Icon(
                            starsActive[3] ? Icons.star : Icons.star_border,
                            size: 30,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(
                              () {
                                starsActive[0] = true;
                                starsActive[1] = true;
                                starsActive[2] = true;
                                starsActive[3] = true;
                                starsActive[4] = false;
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        child: TextButton(
                          child: Icon(
                            starsActive[4] ? Icons.star : Icons.star_border,
                            fill: starsActive[4] ? 1 : 0,
                            size: 30,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(
                              () {
                                starsActive[0] = true;
                                starsActive[1] = true;
                                starsActive[2] = true;
                                starsActive[3] = true;
                                starsActive[4] = true;
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  const Color(0xFF00aa11),
                ),
              ),
              onPressed: () {
                var storage = const FlutterSecureStorage();
                storage.read(key: "username").then(
                  (usr) {
                    storage.read(key: "password").then(
                      (pwd) {
                        var starsCount = 0;
                        for (int i = 0; i < starsActive.length; i++) {
                          if (starsActive[i]) {
                            starsCount = i + 1;
                          }
                        }

                        get(
                          Uri.http(
                            serveraddr,
                            "api/v1/add_review",
                            {
                              "username": usr,
                              "password": pwd,
                              "text": reviewTextController.text,
                              "id": widget.travelId.toString(),
                              "stars": starsCount.toString(),
                            },
                          ),
                        ).then(
                          (r) {
                            print(r.body);

                            if (r.body == "success") {
                              Navigator.of(context).pop();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Произошла ошибка. Повторите попытку",
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                );
              },
              child: const Text(
                "Отправить",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
