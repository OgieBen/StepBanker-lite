// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_banker_lite/data/datasource/local/local_data_source.dart';
import 'package:step_banker_lite/data/datasource/remote/remote_data_source.dart';
import 'package:step_banker_lite/data/local_storage/shared_preferences.dart';
import 'package:step_banker_lite/data/repo/step/step_repository.dart';
import 'package:step_banker_lite/data/repo/user_repository.dart';

import 'package:step_banker_lite/main.dart';

void main() {
  testWidgets('Render smoke test for the UI', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final pref = SharedPreferencesHelper();
    await tester.pumpWidget(MaterialApp(
      title: 'StepBanker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(
        title: 'StepBanker',
        userRepository: UserRepository(pref),
        stepRepository:
            StepRepository(LocalDataSource(pref), RemoteDataSource()),
      ),
    ));

    // Verify that our UI is rendered correctly.
    expect(find.text('StepBanker-lite'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2));
    expect(find.text('Steps'), findsOneWidget);
    expect(find.text('Banked Steps'), findsOneWidget);

    // Tap the 'RoundedButton'
    await tester.tap(find.byType(InkWell));
    await tester.pump();
  });
}
