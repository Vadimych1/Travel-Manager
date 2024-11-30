// 14.05.2024 // home.dart // Home page

import 'package:flutter/material.dart';
import 'package:travel_manager_final/model/datatypes.dart';
import 'package:travel_manager_final/views/widgets/interactive.dart';
import 'package:travel_manager_final/views/main/stories/stories.dart';
import 'package:travel_manager_final/main.dart';
import 'package:travel_manager_final/views/auth/login.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late final TabController pageController;
  String username = "";
  List<Travel> travels = [];
  List<Widget> best = [];

  @override
  void initState() {
    super.initState();
    pageController = TabController(length: 4, vsync: this);

    Future.delayed(Duration.zero, () async {
      username = await service.storage.read("name");
      setState(() {});
      travels = (await service.data.getAllTravels()).additionalData ?? [];
      setState(() {});
    });
  }

  void _openTravel(Travel travel) {
    // !!! TODO !!!
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF162125),
        bottomNavigationBar: TabBar(
          indicatorColor: const Color(0xFF659581),
          labelColor: const Color(0xFF659581),
          unselectedLabelColor: const Color(0xFFCDCDCD),
          overlayColor: WidgetStateProperty.all<Color>(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          controller: pageController,
          tabs: const [
            Tab(
              child: Column(
                children: [
                  Icon(Icons.home),
                  Text(
                    "Главная",
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
            Tab(
              child: Column(
                children: [
                  Icon(Icons.search),
                  Text(
                    "Туры",
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
            Tab(
              child: Column(
                children: [
                  Icon(Icons.person),
                  Text(
                    "Истории",
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
            Tab(
              child: Column(
                children: [
                  Icon(Icons.settings),
                  Text(
                    "Настройки",
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: TabBarView(
          controller: pageController,
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // Top bar
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width * (420 / 786),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      image: DecorationImage(
                        image: AssetImage(
                          "assets/home_bg.png",
                        ),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 20,
                          bottom: 50,
                          child: Text(
                            "Привет, $username!",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFFFFFF),
                              shadows: [
                                Shadow(
                                  color: Color(0xFF000000),
                                  blurRadius: 16,
                                )
                              ],
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 20,
                          bottom: 20,
                          child: Text(
                            "Куда отправимся?",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFFFFFF),
                              shadows: [
                                Shadow(
                                  color: Color(0xFF000000),
                                  blurRadius: 16,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Header
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.only(left: 20),
                    child: const Text(
                      "Ваши поездки",
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xFFFFFFFF),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),

                  // Travels slider
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: travels.isNotEmpty
                          ? SideScrollerBlock(
                              children: [
                                for (var travel in travels)
                                  InkWell(
                                    onTap: () => _openTravel(travel),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: 180,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: const Color.fromRGBO(
                                                0,
                                                0,
                                                0,
                                                0.25,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            height: 140,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                60,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  travel.name,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                                Text(
                                                  travel.town
                                                      .split(" ")
                                                      .map((x) =>
                                                          x[0].toUpperCase() +
                                                          x.substring(1))
                                                      .join(" "),
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  "${travel.fromDate.split(" ")[0]} - ${travel.toDate.split(" ")[0]}",
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                              ],
                            )
                          : InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, "/create");
                              },
                              child: const Text(
                                "у вас нет запланированных поездок\nчтобы создать план, нажмите\nна этот текст",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                  color: Color(0xFF737373),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                    ),
                  ),

                  travels.isEmpty
                      ? Container()
                      : InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, "/create");
                          },
                          child: const Text(
                            "нажмите сюда,\nчтобы создать поездку",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF737373),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                  // Header
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(top: 25),
                    padding: const EdgeInsets.only(left: 20),
                    child: const Text(
                      "Лучшие места",
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xFFFFFFFF),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),

                  // Margin
                  const SizedBox(height: 10),

                  // Best places
                  ...best.isNotEmpty
                      ? best
                      : [
                          const Text(
                            "тут пусто, но скоро появятся\nлучшие активности за неделю",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF737373),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],

                  // Header
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(top: 25),
                    padding: const EdgeInsets.only(left: 20),
                    child: const Text(
                      "Информация",
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xFFFFFFFF),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),

                  // Scroller
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: SideScrollerBlock(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xFF689985),
                          ),
                          width: 300,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Подписка",
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Уберите все ограничения с приложения",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                child: const Text(
                                  "Подробнее",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                ),
                                onTap: () {
                                  // TODO: Open link
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Margin
                  const SizedBox(height: 70),
                ],
              ),
            ),
            const Placeholder(), // tours
            const Stories(),
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 170,
                    color: const Color(0xFF273939),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BackButton(
                          color: const Color(0xFFFFFFFF),
                          onPressed: () {
                            pageController
                                .animateTo(pageController.previousIndex);
                          },
                        ),
                        const Text(
                          "  Настройки",
                          style: TextStyle(
                            fontSize: 22,
                            color: Color(0xFFFFFFFF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "ОСНОВНЫЕ",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFA7A7A7),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Blocks
                        InkWell(
                          onTap: () {},
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: Color(0xFFFFFFFF),
                              ),
                              SizedBox(width: 20),
                              Text(
                                "Профиль",
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.arrow_right,
                                size: 30,
                                color: Color(0xFFFFFFFF),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          height: 1,
                          width: MediaQuery.of(context).size.width - 40,
                          color: const Color(0xFFE6E6E6),
                        ),

                        InkWell(
                          onTap: () {},
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                color: Color(0xFFFFFFFF),
                              ),
                              SizedBox(width: 20),
                              Text(
                                "Уведомления",
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.arrow_right,
                                size: 30,
                                color: Color(0xFFFFFFFF),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          height: 1,
                          width: MediaQuery.of(context).size.width - 40,
                          color: const Color(0xFFE6E6E6),
                        ),

                        InkWell(
                          onTap: () {
                            service.auth.logout();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                              (route) => false,
                            );
                          },
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.logout_outlined,
                                color: Color(0xFFFF0000),
                              ),
                              SizedBox(width: 20),
                              Text(
                                "Выйти из аккаунта",
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.arrow_right,
                                size: 30,
                                color: Color(0xFFFFFFFF),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          height: 1,
                          width: MediaQuery.of(context).size.width - 40,
                          color: const Color(0xFFE6E6E6),
                        ),

                        InkWell(
                          onTap: () {},
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: Color(0xFFFF0000),
                              ),
                              SizedBox(width: 20),
                              Text(
                                "Удалить аккаунт",
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.arrow_right,
                                size: 30,
                                color: Color(0xFFFFFFFF),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          height: 1,
                          width: MediaQuery.of(context).size.width - 40,
                          color: const Color(0xFFE6E6E6),
                        ),

                        const SizedBox(height: 20),
                        const Text(
                          "ПОДДЕРЖКА",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFA7A7A7),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Blocks
                        InkWell(
                          onTap: () {},
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bug_report_outlined,
                                color: Color(0xFFFFFFFF),
                              ),
                              SizedBox(width: 20),
                              Text(
                                "Сообщить об ошибке",
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.arrow_right,
                                size: 30,
                                color: Color(0xFFFFFFFF),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          height: 1,
                          width: MediaQuery.of(context).size.width - 40,
                          color: const Color(0xFFE6E6E6),
                        ),

                        InkWell(
                          onTap: () {},
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.help_outline,
                                color: Color(0xFFFFFFFF),
                              ),
                              SizedBox(width: 20),
                              Text(
                                "Написать в поддержку",
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.arrow_right,
                                size: 30,
                                color: Color(0xFFFFFFFF),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          height: 1,
                          width: MediaQuery.of(context).size.width - 40,
                          color: const Color(0xFFE6E6E6),
                        ),

                        const SizedBox(height: 20),
                        const Text(
                          "ПОДПИСКА",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFA7A7A7),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Blocks
                        InkWell(
                          onTap: () {},
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFFFF00),
                              ),
                              SizedBox(width: 20),
                              Text(
                                "Управление подпиской",
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.arrow_right,
                                size: 30,
                                color: Color(0xFFFFFFFF),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          height: 1,
                          width: MediaQuery.of(context).size.width - 40,
                          color: const Color(0xFFE6E6E6),
                        ),

                        InkWell(
                          onTap: () {},
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history,
                                color: Color(0xFFFFFFFF),
                              ),
                              SizedBox(width: 20),
                              Text(
                                "История покупок",
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.arrow_right,
                                size: 30,
                                color: Color(0xFFFFFFFF),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          height: 1,
                          width: MediaQuery.of(context).size.width - 40,
                          color: const Color(0xFFE6E6E6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
