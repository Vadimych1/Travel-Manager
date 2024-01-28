import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/auth/login.dart';
import 'package:timezone/data/latest.dart' as tz;
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import "package:flutter_secure_storage/flutter_secure_storage.dart";

void main() {
  runApp(const MainApp());
  // SystemChrome.setEnabledSystemUIMode(
  //   SystemUiMode.immersiveSticky,
  // );
  tz.initializeTimeZones();
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<StatefulWidget> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    // var storage = FlutterSecureStorage();
    // storage.deleteAll();

    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: LoginPage(),
          ),
        ),
      ),
    );
  }
}
