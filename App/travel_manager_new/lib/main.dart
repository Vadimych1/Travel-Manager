import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_manager_new/pages/uikit/uikit.dart';
import 'pages/auth/login.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'services.dart';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import "package:flutter_secure_storage/flutter_secure_storage.dart";

final Service service = Service(serveraddr: serveraddr);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  service.init();
  service.storage.clear();

  runApp(const MainApp());
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
