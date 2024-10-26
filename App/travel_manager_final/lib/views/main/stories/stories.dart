// 21.09.2024 // stories.dart // Stories page

import 'package:flutter/material.dart';
import 'dart:math' as math;
// import 'package:circular_charts/circular_charts.dart'; // deprecated
// import 'package:circular_chart_flutter/circular_chart_flutter.dart'; // fucking deprecated

const storyColorA = Colors.green;
const storyColorB = Colors.blue;
const storyDivider = Colors.black;

class Stories extends StatefulWidget {
  const Stories({super.key});

  @override
  State<Stories> createState() => _StoriesState();
}

class _StoriesState extends State<Stories> {
  List<FriendStory> fStories = const [];
  List<Widget> fStoriesWidgets = const [];

  Future<void> loadStories() async {
    // TODO: fetch friend new stories and assign to fStories
    fStories = [
      FriendStory(
        userIcon: const Icon(
          Icons.abc,
          color: Colors.black,
        ),
        storyId: "101",
        username: "Vadimych2",
        active: true,
      ),
      FriendStory(
        userIcon: const Icon(
          Icons.access_alarm,
          color: Colors.black,
        ),
        storyId: "789",
        username: "Vadimych3",
        active: false,
      ),
      FriendStory(
        userIcon: const Icon(
          Icons.accessible_forward_rounded,
          color: Colors.black,
        ),
        storyId: "456",
        username: "Vadimych1",
        active: true,
      ),
      FriendStory(
        userIcon: const Icon(
          Icons.accessible_forward_rounded,
          color: Colors.black,
        ),
        storyId: "123",
        username: "Vadimych1",
        active: false,
      ),
    ];
  }

  void generateStories() {
    var fsc = fStories;

    // sort
    fsc.sort(
      (a, b) => a.active && b.active
          ? 0
          : a.active
              ? -1
              : 1,
    );

    Map<String, List<FriendStory>> ls = {};

    for (var i in fsc) {
      if (ls.containsKey(i.username)) {
        ls[i.username]!.add(i);
      } else {
        ls[i.username] = [i];
      }
    }

    fStoriesWidgets = [];
    for (var i in ls.values) {
      fStoriesWidgets.add(
        FriendStoryWidget(
          i,
          onTap: (username, storyId) {
            // TODO: upgrade algorithm
            for (var i = 0; i < fStories.length; i++) {
              if (fStories[i].storyId == storyId &&
                  fStories[i].username == username) {
                fStories[i].active = false;
                setState(() {});
                continue;
              }
            }
          },
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    loadStories().then((r) {
      generateStories();
    });
  }

  @override
  Widget build(BuildContext context) {
    generateStories();

    return Column(
      children: [
        SingleChildScrollView(
          child: Row(
            children: fStoriesWidgets,
          ),
        ),
      ],
    );
  }
}

class FriendStoryWidget extends StatelessWidget {
  const FriendStoryWidget(this.fs, {super.key, required this.onTap});

  final List<FriendStory> fs;
  final void Function(String username, String storyid) onTap;

  List<Color> generateStoryIndicatorGradient(List<FriendStory> fs) {
    List<Color> colors = [];

    if (fs.length == 1) {
      colors = [storyColorA, storyColorB, storyColorA];
    } else {
      for (var i = 0; i < fs.length; i++) {
        colors.addAll(
          fs[i].active
              ? [
                  storyDivider,
                  storyColorA,
                  storyColorB,
                  storyColorA,
                  storyDivider,
                ]
              : [
                  storyDivider,
                  Colors.transparent,
                  Colors.transparent,
                  Colors.transparent,
                  storyDivider,
                ],
        );
      }
    }

    return colors;
  }

  List<double> generateStoryIndicatorColorStops(List<FriendStory> fs) {
    if (fs.length == 1) {
      return [0, 0.5, 1];
    } else {
      List<double> v = [];

      double perStoryIndex = 1 / fs.length;

      for (var i = 0; i < fs.length; i++) {
        v.addAll([
          perStoryIndex * i + perStoryIndex / 100,
          perStoryIndex * i + perStoryIndex / 20,
          perStoryIndex * i + perStoryIndex / 3 * 2,
          perStoryIndex * i + perStoryIndex - perStoryIndex / 100,
          perStoryIndex * i + perStoryIndex,
        ]);
      }

      return v;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 4,
          top: 9,
          child: Container(
            decoration: BoxDecoration(
              gradient: SweepGradient(
                colors: generateStoryIndicatorGradient(fs),
                stops: generateStoryIndicatorColorStops(fs),
                startAngle: math.pi / 2,
                endAngle: math.pi * 5 / 2,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            width: 56,
            height: 56,
          ),
        ),
        InkWell(
          splashFactory: NoSplash.splashFactory,
          onTap: () {
            // TODO: watch story
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 12),
            padding: const EdgeInsets.all(5),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
            ),
            child: fs[0].userIcon,
          ),
        ),
      ],
    );
  }
}

class FriendStory {
  FriendStory({
    required this.userIcon,
    required this.username,
    required this.storyId,
    required this.active,
  });

  final Widget userIcon;
  final String username;
  final String storyId;

  bool active;

  void preload() {
    // TODO: preload
  }
}
