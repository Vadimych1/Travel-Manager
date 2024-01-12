import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:http/http.dart";
import "package:travel_manager_new/uikit/uikit.dart";

class ViewReviewsAndPhotos extends StatefulWidget {
  const ViewReviewsAndPhotos({super.key, required this.placeid});

  final int placeid;

  @override
  State<ViewReviewsAndPhotos> createState() => _ViewReviewsAndPhotosState();
}

class _ViewReviewsAndPhotosState extends State<ViewReviewsAndPhotos> {
  final storage = const FlutterSecureStorage();

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

                    j.forEach((r) {
                      var rText = r["title"] ?? "";
                      var rStars = r["stars"] ?? 0;
                      var rOwner = r["owner"] ?? "";

                      
                    });
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

    return const Scaffold(
      body: Column(
        children: [],
      ),
    );
  }
}
