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
  List<Widget> expenses = [];
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
      sum += int.parse(e["cost"]);
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
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
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
                      SizedBox(
                        height: 180,
                        child: SingleChildScrollView(
                          child: Column(
                            children: expenses,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: BlackButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                TextEditingController nameC =
                                    TextEditingController();
                                TextEditingController costC =
                                    TextEditingController();

                                var prevCost = "";

                                return AlertDialog(
                                  title: const Text(
                                    "Добавление расходов",
                                  ),
                                  content: Column(
                                    children: [
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Input(
                                          controller: nameC,
                                          placeholder: "Наименование",
                                          onChanged: (s) {},
                                        ),
                                      ),
                                      SizedBox(
                                        child: Input(
                                          controller: costC,
                                          placeholder: "Затраты",
                                          onChanged: (s) {
                                            if (s.length > prevCost.length) {
                                              try {
                                                int.parse(s);
                                                prevCost = s;
                                              } catch (e) {
                                                costC.text = prevCost;
                                              }
                                            } else {
                                              prevCost = s;
                                            }
                                          },
                                          inputType: TextInputType.number,
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 10,
                                          top: 10,
                                        ),
                                        alignment: Alignment.bottomCenter,
                                        child: Row(
                                          children: [
                                            TextButton(
                                              child: const Text("Отмена"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text("Добавить"),
                                              onPressed: () {
                                                setState(
                                                  () {
                                                    expensesj.add(
                                                      {
                                                        "name": nameC.text,
                                                        "cost": costC.text,
                                                      },
                                                    );

                                                    expenses = [];
                                                    sum = 0;
                                                    for (var e in expensesj) {
                                                      setState(
                                                        () {
                                                          sum += int.parse(
                                                              e["cost"]);
                                                        },
                                                      );

                                                      expenses.add(
                                                        ExpenseItem(
                                                          expense: e,
                                                          after: () {
                                                            sum = 0;
                                                            for (var e
                                                                in expensesj) {
                                                              setState(
                                                                () {
                                                                  sum +=
                                                                      int.parse(
                                                                    e["cost"],
                                                                  );
                                                                },
                                                              );
                                                            }
                                                          },
                                                          delete_: (exp) {
                                                            setState(
                                                              () {
                                                                var i = expensesj
                                                                    .indexOf(
                                                                        exp);
                                                                expensesj
                                                                    .remove(
                                                                        exp);
                                                                expenses
                                                                    .removeAt(
                                                                        i);
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    }

                                                    Navigator.of(context).pop();
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          text: "Добавить",
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

                tr["expenses"] = exp;

                var storage = const FlutterSecureStorage();

                storage.read(key: "username").then(
                  (usr) {
                    storage.read(key: "password").then(
                      (pwd) {
                        get(
                          Uri.https(
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
