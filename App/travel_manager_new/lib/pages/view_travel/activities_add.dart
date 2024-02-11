import 'package:flutter/material.dart';
import '../../uikit/uikit.dart';

class ViewTravelChooseActivities extends StatefulWidget {
  const ViewTravelChooseActivities({
    super.key,
    required this.travel,
    required this.parent,
    required this.actBridge,
  });

  final Map travel;
  final State parent;
  final ListBridge<SelectedActivity> actBridge;

  @override
  State<ViewTravelChooseActivities> createState() =>
      _ViewTravelChooseActivitiesState();
}

class _ViewTravelChooseActivitiesState
    extends State<ViewTravelChooseActivities> {
  Activities activs = Activities(
    town: "",
    bridge: ListBridge(
      value: [],
    ),
  );

  @override
  void initState() {
    super.initState();

    var bridge = widget.actBridge;

    activs = Activities(
      town: widget.travel["town"],
      bridge: bridge,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF333333),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: activs,
                ),
              ],
            ),
          ),
          Positioned(
            child: BackButton(
              color: const Color(
                0xFFFFFFFF,
              ),
              onPressed: () {
                Navigator.pop(context, activs.bridge.value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
