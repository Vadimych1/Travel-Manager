import "package:flutter/material.dart";
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_manager_new/main.dart';
import 'package:travel_manager_new/pages/main/main_home.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Добавьте эту строку

  testWidgets(
    'Login test',
    (WidgetTester tester) async {
      // Сбросить состояние теста
      await tester.pumpWidget(const MainApp());

      // Найти TextField по ключу и ввести текст
      final loginInputFinder = find.byKey(const Key('loginKey'));
      await tester.enterText(loginInputFinder, 'debug');
      await Future.delayed(const Duration(seconds: 2));

      final passwordInputFinder = find.byKey(const Key('passwordKey'));
      await tester.enterText(passwordInputFinder, 'debug');
      await Future.delayed(const Duration(seconds: 2));

      // await tester.tap(find.byType(Scaffold).first);
      // await Future.delayed(const Duration(seconds: 2));

      // await tester.tapAt(const Offset(0, 0));
      // await tester.pump();

      FocusManager.instance.primaryFocus?.unfocus();
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));

      // Найти кнопку по тексту и нажать на нее
      final buttonFinder = find.byKey(const Key('loginButtonKey'));
      await tester.tap(buttonFinder.first);
      await tester.pumpAndSettle();

      expect(loginInputFinder, findsOneWidget);
      expect(passwordInputFinder, findsOneWidget);
      expect(buttonFinder, findsOneWidget);
    },
  );

  testWidgets("Testing main page", (WidgetTester tester) async {
    var sStorage = const FlutterSecureStorage();
    sStorage.write(key: "username", value: "debug");
    sStorage.write(key: "password", value: "debug");

    await tester.pumpWidget(const MaterialApp(home: MainHome()));
    // Waiting load
    await Future.delayed(const Duration(seconds: 10));

    expect(find.byType(MainHome), findsOneWidget);
    expect(find.text("© 2023. Travel Manager"), findsOneWidget);
  });
}
