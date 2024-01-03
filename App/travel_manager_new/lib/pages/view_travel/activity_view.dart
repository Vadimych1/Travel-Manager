import "./../../uikit/uikit.dart";
import "package:flutter/material.dart";

class ActivityView extends StatefulWidget {
  const ActivityView({super.key, required this.activity});

  final Map activity;

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Name
          Container(
            padding: const EdgeInsets.only(top: 40, left: 20),
            width: MediaQuery.of(context).size.width,
            height: 120,
            decoration: const BoxDecoration(
              color: Color(0xFF222222),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Активность",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 20,
                  ),
                ),
                Text(
                  widget.activity["name"],
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Info
          Container(
            padding: const EdgeInsets.all(15),
            width: 307,
            child: Column(
              children: [
                Text(
                  widget.activity.keys.toString(),
                ),
                Text(
                  widget.activity["address"] ?? "err",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
