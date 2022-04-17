import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:step_banker_lite/data/datasource/local/local_data_source.dart';
import 'package:step_banker_lite/data/datasource/remote/remote_data_source.dart';
import 'package:step_banker_lite/data/local_storage/shared_preferences.dart';
import 'package:step_banker_lite/data/repo/step/step_repository.dart';
import 'package:step_banker_lite/data/repo/user_repository.dart';
import 'package:step_banker_lite/ui/home/home_page.dart';

var myDebugTree = DebugTree();

void main() {
  Fimber.plantTree(myDebugTree);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pref = SharedPreferencesHelper();
    return MaterialApp(
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
    );
  }
}
