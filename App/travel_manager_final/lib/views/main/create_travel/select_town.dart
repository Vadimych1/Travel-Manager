// 14.05.2024 // main_data.dart // Create travel main data

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travel_manager_final/views/widgets/interactive.dart';
import 'package:travel_manager_final/main.dart';

class CreateTravelSelectTown extends StatefulWidget {
  const CreateTravelSelectTown({super.key});

  @override
  State<CreateTravelSelectTown> createState() => CreateTravelSelectTownState();
}

class _TownItem extends StatelessWidget {
  final Map<String, dynamic> town;
  final void Function(String, String) onTap;

  const _TownItem({required this.town, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(town["name"], town["display_name"]),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: town["type"] == "beautiful"
                    ? const Color(0xFF659581)
                    : town["type"] == "plain"
                        ? const Color.fromARGB(255, 101, 122, 149)
                        : town["type"] == "regional_center"
                            ? const Color.fromARGB(255, 138, 101, 149)
                            : const Color.fromARGB(255, 149, 101, 101),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(5),
              child: SvgPicture.asset(
                town["type"] == "beautiful"
                    ? "assets/beautiful_town.svg"
                    : town["type"] == "plain"
                        ? "assets/plain_town.svg"
                        : town["type"] == "regional_center"
                            ? "assets/regional_center.svg"
                            : "assets/resort_town.svg",
                // ignore: deprecated_member_use
                color: const Color(0xFFFFFFFF),
                width: 27,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  town["display_name"],
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 16,
                  ),
                ),
                Text(
                  town["type"] == "beautiful"
                      ? "Знаменитый город"
                      : town["type"] == "plain"
                          ? "Обычный город"
                          : town["type"] == "regional_center"
                              ? "Региональный центр"
                              : "Курортный город",
                  style: const TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontSize: 12,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CreateTravelSelectTownState extends State<CreateTravelSelectTown> {
  TextEditingController townC = TextEditingController();
  String selectedTown = "";
  String selectedTownName = "";
  List<Map<String, dynamic>> towns = [];

  void _search(String q) async {
    if (q.isEmpty) {
      towns = await service.data.searchTowns("%");
      setState(() {});
      return;
    }

    try {
      towns = await service.data.searchTowns(q);
      setState(() {});
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _search("");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF162125),
        appBar: AppBar(
          backgroundColor: const Color(0xFF162125),
          leading: const BackButton(
            color: Color(0xFFFFFFFF),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(width: MediaQuery.of(context).size.width), // width fix

            // Header
            Text(
              selectedTown.isEmpty ? "Куда отправимся?" : "Пункт назначения",
              style: TextStyle(
                color: const Color(0xFFFFFFFF),
                fontSize: selectedTown.isEmpty ? 20 : 16,
              ),
              textAlign: TextAlign.center,
            ),
            selectedTown.isEmpty
                ? const Text("")
                : Text(
                    selectedTownName,
                    style: const TextStyle(
                      color: Color(0xFF659581),
                      fontSize: 18,
                    ),
                  ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Input(
                controller: townC,
                label: "",
                placeholder: "начните ввод и выберите",
                validator: (s) {
                  return true;
                },
                initialValid: true,
                onChanged: _search,
                onValidChanged: (v) {},
                labelColor: const Color(0xFFFFFFFF),
                bgColor: const Color(0xFFFFFFFF),
              ),
            ),

            const SizedBox(height: 30),

            towns.isNotEmpty
                ? Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          for (var t in towns)
                            _TownItem(
                              town: t,
                              onTap: (s, n) {
                                selectedTown = s;
                                selectedTownName = n;
                                setState(() {});
                              },
                            )
                        ],
                      ),
                    ),
                  )
                : const Expanded(
                    child: Text(
                      "К сожалению, по вашему запросу\nничего не найдено",
                      style: TextStyle(color: Color(0xFFAAAAAA)),
                      textAlign: TextAlign.center,
                    ),
                  ),

            // const Spacer(),

            Button(
              onPressed: () {
                if (selectedTown.isEmpty) {
                  return;
                }

                var args = ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
                args["town"] = selectedTown;

                // print(args);

                Navigator.of(context).pushNamed(
                  "/create/select_activities",
                  arguments: args,
                );
              },
              text: "К выбору активностей",
              enabled: selectedTown.isNotEmpty,
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
