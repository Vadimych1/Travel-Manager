import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:http/http.dart";
import 'package:travel_manager_new/pages/uikit/uikit.dart';

class ViewReviewsAndPhotos extends StatefulWidget {
  const ViewReviewsAndPhotos(
      {super.key, required this.placeid, required this.photosAddresses});

  final int placeid;
  final List<String> photosAddresses;

  @override
  State<ViewReviewsAndPhotos> createState() => _ViewReviewsAndPhotosState();
}

class _ViewReviewsAndPhotosState extends State<ViewReviewsAndPhotos> {
  final storage = const FlutterSecureStorage();
  var reviews = <Widget>[];
  var photos = <Widget>[];

  var idVas = <int>[];

  @override
  Widget build(BuildContext context) {
    storage.read(key: "username").then(
      (usr) {
        storage.read(key: "password").then(
          (pwd) {
            get(
              Uri.http(
                serveraddr,
                "api/v1/get_reviews",
                {
                  "username": usr,
                  "password": pwd,
                  "placeid": widget.placeid.toString()
                },
              ),
            ).then(
              (req) {
                if (req.statusCode == 200) {
                  try {
                    var j = jsonDecode(req.body);

                    j.forEach(
                      (r) {
                        print(r);

                        var rText = r["text"] ?? "";
                        var rStars = r["stars"] ?? 0;
                        var rOwner = r["owner"] ?? "";

                        get(
                          Uri.http(
                            serveraddr,
                            "api/v1/get_username",
                            {
                              "username": rOwner,
                            },
                          ),
                        ).then((req) {
                          if (req.statusCode == 200) {
                            var j = jsonDecode(req.body);
                            var rUsername = j["username"] ?? "";

                            if (!idVas.contains(r["id"])) {
                              idVas.add(r["id"]);

                              setState(
                                () {
                                  reviews.add(
                                    Container(
                                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.black54,
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            rUsername,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            rText,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              for (int i = 0; i < rStars; i++)
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                              for (int i = 0;
                                                  i < 5 - rStars;
                                                  i++)
                                                const Icon(
                                                  Icons.star_border,
                                                  color: Colors.amber,
                                                ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          }
                        });
                      },
                    );
                  } catch (e) {
                    null;
                  }
                }
              },
            );
          },
        );
      },
    );

    for (var addr in widget.photosAddresses) {
      setState(
        () {
          photos.add(
            Image.network(addr),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF333333),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 110,
                padding: const EdgeInsets.only(
                  top: 60,
                  left: 30,
                  bottom: 10,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF101010),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: const Row(
                  children: [
                    BackButton(color: Colors.white),
                    Text(
                      "Отзывы и фотографии",
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontFamily: "Inter",
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Photos
              Container(
                width: MediaQuery.of(context).size.width - 20,
                height: 240,
                padding: const EdgeInsets.all(
                  10,
                ),
                margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF101010),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: photos.isNotEmpty
                        ? photos
                        : [
                            Container(
                              margin: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width / 2 -
                                      120),
                              child: const Text(
                                "Фотографий нет\nЛибо они еще загружаются",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          ],
                  ),
                ),
              ),

              // Reviews
              Container(
                width: MediaQuery.of(context).size.width - 20,
                height: 300,
                padding: const EdgeInsets.all(
                  10,
                ),
                margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF101010),
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: reviews.isNotEmpty
                        ? reviews
                        : [
                            const Text(
                              "Отзывов пока нет",
                            ),
                          ],
                  ),
                ),
              ),
            ],
          ),
          const BackButton(
            color: Color(
              0xFFFFFFFF,
            ),
          ),
        ],
      ),
    );
  }
}
