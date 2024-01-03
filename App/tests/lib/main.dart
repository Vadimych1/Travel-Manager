import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void initTZ() {
  tz.initializeTimeZones();
}

void main() {
  initTZ();

  runApp(const MainApp());

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  flutterLocalNotificationsPlugin
      .zonedSchedule(
        0,
        "Hello",
        "This is test message",
        tz.TZDateTime.now(tz.local).add(
          const Duration(seconds: 30),
        ),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'TRAVELMANAGER',
            'Reminder',
            channelDescription: 'Reminder for Travel Manager',
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      )
      .then(
        (val) => {
          print("ADDED NOTIFICATION"),
        },
      );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
