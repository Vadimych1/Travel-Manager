import 'package:flutter/material.dart';
import '../../uikit/uikit.dart';
import "dart:convert";
import "package:http/http.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";

class ExpenseItem extends StatelessWidget {
  const ExpenseItem(
      {super.key,
      required this.expense,
      required this.delete_,
      required this.after});

  final Map<dynamic, dynamic> expense;
  final void Function(Map<dynamic, dynamic>) delete_;
  final void Function() after;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 230,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(expense["name"].toString().toUpperCase()),
                Text("${expense["cost"]} руб."),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              delete_(expense);
              after();
            },
          ),
        ],
      ),
      onPressed: () {
        showDialog(
          builder: (context) => AlertDialog(
            title: Text(expense["name"]),
            content: Text(expense["cost"] + " руб."),
          ),
          context: context,
        );
      },
    );
  }
}

class ExpenseView extends StatefulWidget {
  const ExpenseView({super.key, required this.travel});

  final Map<dynamic, dynamic> travel;

  @override
  State<ExpenseView> createState() => _ExpenseViewState();
}

class _ExpenseViewState extends State<ExpenseView> {
  List<ExpenseItem> expenses = [];
  List expensesj = [];
  int sum = 0;

  @override
  void initState() {
    super.initState();
    try {
      expensesj = widget.travel["expenses"];
    } catch (e) {
      expensesj = jsonDecode(widget.travel["expenses"]);
    }

    for (var e in expensesj) {
      sum += int.tryParse(e["cost"]) ?? 0;
      expenses.add(
        ExpenseItem(
          expense: e,
          after: () {
            sum = 0;
            for (var e in expensesj) {
              setState(
                () {
                  sum += int.parse(
                    e["cost"],
                  );
                },
              );
            }
          },
          delete_: (exp) {
            setState(
              () {
                var i = expensesj.indexOf(exp);
                expensesj.remove(exp);
                expenses.removeAt(i);
              },
            );
          },
        ),
      );
    }
  }

  TextEditingController name = TextEditingController();
  TextEditingController cost = TextEditingController();
  TextEditingController category = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          SizedBox(
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(top: 30, left: 50),
                  child: const Text(
                    "Расходы",
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 20,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: 307,
                  // height: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 307,
                        height: 180,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: expenses.isNotEmpty
                                ? [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    ...expenses
                                  ]
                                : [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Text(
                                      "Пусто",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(
                                          0xFF777777,
                                        ),
                                      ),
                                    )
                                  ],
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.only(top: 15, left: 20),
                        child: Text(
                          "Всего: $sum руб.",
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Container(
                        width: 307,
                        height: 230,
                        margin: const EdgeInsets.only(left: 15, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 200,
                              height: 40,
                              child: TextField(
                                controller: name,
                                decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.only(left: 10),
                                  filled: true,
                                  fillColor: const Color(0xFFFFFFFF),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(
                                        0xFF000000,
                                      ),
                                    ),
                                  ),
                                  hintText: "Название расхода",
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              height: 40,
                              child: TextField(
                                controller: cost,
                                decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.only(left: 10),
                                  filled: true,
                                  fillColor: const Color(0xFFFFFFFF),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(
                                        0xFF000000,
                                      ),
                                    ),
                                  ),
                                  hintText: "Сумма расхода",
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              height: 70,
                              child: DropdownMenu(
                                onSelected: (v) {
                                  category.text = v;
                                },
                                width: 200,
                                menuHeight: 200,
                                hintText: "Категория",
                                dropdownMenuEntries: const <DropdownMenuEntry>[
                                  DropdownMenuEntry(
                                    value: "food",
                                    label: "Еда",
                                  ),
                                  DropdownMenuEntry(
                                    value: "shops",
                                    label: "Магазины",
                                  ),
                                ],
                              ),
                            ),
                            BlackButton(
                              text: "Добавить",
                              onPressed: () {
                                if (name.text != "" &&
                                    cost.text != "" &&
                                    category.text != "") {
                                  expenses.add(
                                    ExpenseItem(
                                      key: Key(
                                          "${name.text} ${cost.text} ${category.text}"),
                                      expense: {
                                        "name": name.text,
                                        "cost": cost.text,
                                        "category": category.text
                                      },
                                      delete_: (m) {
                                        expensesj.remove(m);

                                        for (var element in expenses) {
                                          if (element.key ==
                                              Key("${m["name"]} ${m["cost"]} ${m["category"]}")) {
                                            expenses.remove(element);
                                            setState(() {});
                                          }
                                        }
                                      },
                                      after: () {
                                        setState(
                                          () {},
                                        );
                                      },
                                    ),
                                  );
                                  expensesj.add(
                                    {
                                      "name": name.text,
                                      "cost": cost.text,
                                      "category": category.text
                                    },
                                  );
                                  setState(() {});
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 10,
            child: BackButton(
              onPressed: () {
                var exp = jsonEncode(expensesj);
                var tr = widget.travel;

                var storage = const FlutterSecureStorage();

                storage.read(key: "username").then(
                  (usr) {
                    storage.read(key: "password").then(
                      (pwd) {
                        get(
                          Uri.http(
                            serveraddr,
                            "api/v1/edit_travel",
                            {
                              "username": usr,
                              "password": pwd,
                              "id": tr["id"].toString(),
                              "plan_name": tr["plan_name"],
                              "activities": jsonEncode(tr["activities"]),
                              "from_date": tr["from_date"],
                              "to_date": tr["to_date"],
                              "budget": tr["budget"].toString(),
                              "live_place": tr["live_place"],
                              "expenses": exp,
                              "meta": jsonEncode(tr["meta"]),
                              "people_count": tr["people_count"],
                              "town": tr["town"],
                            },
                          ),
                        ).then(
                          (r) {
                            if (r.statusCode == 200 &&
                                jsonDecode(r.body)["status"] == "success") {
                              Navigator.of(context).pop();
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text(
                                      "При сохранении произошла ошибка",
                                    ),
                                    content: Column(
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            "Все равно выйти",
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            "Остаться",
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                );
              },
              color: const Color(0xFFFFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}
