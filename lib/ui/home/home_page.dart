import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:step_banker_lite/data/repo/step/step_repository.dart';
import 'package:step_banker_lite/data/repo/user_repository.dart';
import 'package:step_banker_lite/main.dart';
import 'package:step_banker_lite/ui/home/home_page_vm.dart';
import 'package:step_banker_lite/ui/widgets/rounded_button_widget.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage(
      {Key? key,
      required this.title,
      required this.stepRepository,
      required this.userRepository})
      : super(key: key);
  final String title;
  final StepRepository stepRepository;
  final UserRepository userRepository;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late HomePageVM _homePageVM;

  @override
  void initState() {
    super.initState();
    _homePageVM = HomePageVM(widget.stepRepository, widget.userRepository);
    _homePageVM.setVmUpdate(setState);
    _homePageVM.setup();
    _homePageVM.initPedometer();
  }

  @override
  void dispose() {
    super.dispose();
    Fimber.unplantTree(myDebugTree);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(flex: 1),
            const Text("StepBanker-lite",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400)),
            const Spacer(
              flex: 2,
            ),
            RoundedButton(
              onTap: _homePageVM.onBankSteps,
              currentStepsForTheDay: _homePageVM.currentStepsForTheDay,
            ),
            const Spacer(
              flex: 2,
            ),
            const Text(
              "Banked Steps",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
            ),
            Text(
              "${_homePageVM.bankedSteps}",
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
            ),
            const Spacer(
              flex: 2,
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
