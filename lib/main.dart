import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:step_banker_lite/data/datasource/local/local_data_source.dart';
import 'package:step_banker_lite/data/datasource/remote/remote_data_source.dart';
import 'package:step_banker_lite/data/local_storage/shared_preferences.dart';
import 'package:step_banker_lite/data/model/net/step_request.dart';
import 'package:step_banker_lite/data/model/net/update_step_request.dart';
import 'package:step_banker_lite/data/model/steps/steps.dart';
import 'package:step_banker_lite/data/model/user/user.dart';
import 'package:step_banker_lite/data/repo/step/step_repository.dart';
import 'package:step_banker_lite/data/repo/user_repository.dart';
import 'package:step_banker_lite/ui/widgets/rounded_button_widget.dart';

var myDebugTree = DebugTree();

void main() {
  Fimber.plantTree(myDebugTree);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StepBanker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'StepBanker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  int _bankedSteps = 0;
  int _activeSteps = 0;

  int _previousStepsForTheDay = 0;
  int _currentStepsForTheDay = 0;
  int _lockedInitialStepsSinceMidnight = 0;
  var _resetLockedISSM = false;

  late StepRepository _repository;
  late SharedPreferencesHelper _pref;
  late String _userId;

  @override
  void initState() {
    super.initState();
    _setup();
    _initPedometer();
  }

  _checkPreviousTimeStamp() async {
    final timestamp = await _repository.getLastStepTimestamp();
    // final timestamp = "2022-04-12T21:50:12.636411";
    Fimber.d("Timestamp for last entry: $timestamp");
    if (timestamp != null) {
      final currentTime = DateTime.now();
      final oldTimeStamp = DateTime.parse(timestamp);
      final diff = currentTime.difference(oldTimeStamp);
      final hoursToMN = 24 - oldTimeStamp.hour;
      final isPastMidnight = diff.inHours >= hoursToMN;

      Fimber.d(
          "Timestamp Log: OldTS: ${oldTimeStamp.hour} Diff: ${diff.inHours} HoursToMidnight: $hoursToMN Current hour: ${currentTime.hour}");

      if (diff.inDays >= 1) {
        Fimber.d(
            "Timestamp is older than one day: Reset total steps for the day");
        _resetLockedISSM = true;
        await _resetActiveSteps();
        await _resetTotalStepsForTheDay();
        return;
      }

      if (isPastMidnight) {
        Fimber.d("Past midnight: Reset total steps for the day");
        _resetLockedISSM = true;
        await _resetActiveSteps();
        await _resetTotalStepsForTheDay();
        return;
      }

      final lockedSteps = await _repository
          .getLockedInitialStepsSinceMidnight(StepRequest(User(_userId)));
      _lockedInitialStepsSinceMidnight = lockedSteps?.steps ?? -1;
      Fimber.d("Fetch lockstep: $_lockedInitialStepsSinceMidnight");
      return;
    }
    Fimber.d("No timestamp found: Reset total steps for the day");
    _resetLockedISSM = true;
  }

  Future<void> _resetTotalStepsForTheDay() async {
    final res = await _repository.resetTotalStepsForTheDay(UpdateStepRequest(
        User(_userId),
        ActiveSteps(
          0,
          "",
        )));

    setState(() {
      _currentStepsForTheDay = res?.steps ?? 0;
    });
  }

  Future<void> _resetActiveSteps() async {
    final res = await _repository.resetUserActiveSteps(UpdateStepRequest(
        User(_userId),
        ActiveSteps(
          0,
          "",
        )));
    setState(() {
      _activeSteps = res?.steps ?? 0;
    });
  }

  _setup() async {
    _pref = SharedPreferencesHelper();
    final userRepo = UserRepository(_pref);
    final uid = await userRepo.initUserId();
    if (uid == null) {
      throw FlutterError("User ID must be initialised");
    }
    _userId = uid;
    _repository = StepRepository(LocalDataSource(_pref), RemoteDataSource());

    _checkPreviousTimeStamp();

    final activeStepRequest =
        await _repository.fetchUserActiveSteps(StepRequest(User(_userId)));
    _activeSteps = activeStepRequest?.steps ?? 0;
    final bankedStepRequest =
        await _repository.fetchBankedSteps(StepRequest(User(_userId)));
    final totalStepForTheDay =
        await _repository.getTotalStepsForTheDay(StepRequest(User(_userId)));

    setState(() {
      _bankedSteps = bankedStepRequest?.steps ?? 0;
      _currentStepsForTheDay = totalStepForTheDay?.steps ?? 0;
    });
    Fimber.d(
        "User ID ----- $_userId --- banked steps: $_bankedSteps ---- Previous Active steps: $_activeSteps Current TSFD: $_currentStepsForTheDay");
  }

  void _onStepCount(StepCount event) {
    if (_resetLockedISSM) {
      _lockedInitialStepsSinceMidnight = event.steps;
      _repository.updateLockedInitialStepsSinceMidnight(UpdateStepRequest(
          User(_userId),
          ActiveSteps(
            _lockedInitialStepsSinceMidnight,
            "",
          )));
      Fimber.d("New lockedStep created: $_lockedInitialStepsSinceMidnight");
      _resetLockedISSM = false;
    }

    Fimber.d("Locked steps:  $_lockedInitialStepsSinceMidnight");
    // Update _currentStepsForTheDay when the user starts walking.
    if (event.steps > _lockedInitialStepsSinceMidnight) {
      final newSteps = event.steps - _lockedInitialStepsSinceMidnight;
      Fimber.d(
          "Newly generated steps: $newSteps/ Total steps: ${event.steps} / Locked steps:  $_lockedInitialStepsSinceMidnight");
      setState(() {
        _currentStepsForTheDay = newSteps;
      });
      return;
    }
  }

  Future<void> _onPedestrianStatusChanged(PedestrianStatus event) async {
    if (event.status == "stopped") {
      final activeSteps = _currentStepsForTheDay - _previousStepsForTheDay;
      final res = await _repository.updateUserActiveSteps(UpdateStepRequest(
          User(_userId),
          ActiveSteps(
            activeSteps,
            "",
          )));
      final updatedActiveValue = res?.steps ?? -1;
      _previousStepsForTheDay = _currentStepsForTheDay;

      _repository.updateTotalStepsForTheDay(UpdateStepRequest(
          User(_userId),
          ActiveSteps(
            _currentStepsForTheDay,
            "",
          )));
      _repository.recordLastStepTimestamp(event.timeStamp.toIso8601String());
      setState(() {
        _activeSteps = updatedActiveValue;
      });
    }
    Fimber.d("$event");
  }

  void _onPedestrianStatusError(error) {
    Fimber.d('onPedestrianStatusError: $error');
  }

  void _onStepCountError(error) {
    Fimber.d('onStepCountError: $error');
  }

  Future<void> _initPedometer() async {
    if (await Permission.activityRecognition.request().isGranted) {
      _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
      _pedestrianStatusStream
          .listen(_onPedestrianStatusChanged)
          .onError(_onPedestrianStatusError);
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream.listen(_onStepCount).onError(_onStepCountError);
    }

    if (!mounted) return;
  }

  @override
  void dispose() {
    super.dispose();
    Fimber.unplantTree(myDebugTree);
  }

  _onBankSteps() async {
    // The active steps and initial steps should be the same values after every active step update
    // Whe this button is clicked, the active step should be emptied into the banked step and reset to zero.
    final activeStepReq =
        await _repository.fetchUserActiveSteps(StepRequest(User(_userId)));
    final activeSteps = activeStepReq?.steps ?? -1;

    if (_activeSteps <= 0) {
      return;
    }
    final bankedStepsUpdateRes =
        await _repository.updateUserBankedSteps(UpdateStepRequest(
            User(_userId),
            ActiveSteps(
              _activeSteps,
              "",
            )));
    final bankedSteps = bankedStepsUpdateRes?.steps ?? -1;

    final activeStepUpdate =
        await _repository.resetUserActiveSteps(UpdateStepRequest(
            User(_userId),
            ActiveSteps(
              0,
              "",
            )));
    final latestActiveSteps = activeStepUpdate?.steps ?? -1;
    if (latestActiveSteps == -1) {
      return;
    }

    Fimber.d(
        "Current steps ---------- Initial Active Steps: $activeSteps  - Banked steps: $bankedSteps - Current Active steps: $latestActiveSteps");
    if (_bankedSteps != -1) {
      setState(() {
        _bankedSteps = bankedSteps;
        _activeSteps = latestActiveSteps;
      });
    }
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
              onTap: _onBankSteps,
              currentStepsForTheDay: _currentStepsForTheDay,
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
              "$_bankedSteps",
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
