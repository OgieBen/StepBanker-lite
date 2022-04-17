import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:step_banker_lite/data/model/net/step_request.dart';
import 'package:step_banker_lite/data/model/net/update_step_request.dart';
import 'package:step_banker_lite/data/model/steps/steps.dart';
import 'package:step_banker_lite/data/model/user/user.dart';
import 'package:step_banker_lite/data/repo/step/step_repository.dart';
import 'package:step_banker_lite/data/repo/user_repository.dart';

class HomePageVM {
  HomePageVM(this._repository, this._userRepo);

  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;

  int _bankedSteps = 0;
  int _activeSteps = 0;

  int _previousStepsForTheDay = 0;
  int _currentStepsForTheDay = 0;

  int _lockedInitialStepsSinceMidnight = 0;
  var _resetLockedISSM = false;
  Function? _setState;

  late final StepRepository _repository;
  late final UserRepository _userRepo;
  String _userId = "";

  int get currentStepsForTheDay => _currentStepsForTheDay;

  int get bankedSteps => _bankedSteps;

  setVmUpdate(Function setState) {
    _setState = setState;
  }

  setup() async {
    if (_setState == null) {
      throw FlutterError("Setup ViewModel update method");
    }

    final uid = await _userRepo.initUserId();
    if (uid == null) {
      throw FlutterError("User ID must be initialised");
    }
    _userId = uid;
    _checkPreviousTimeStamp();

    if (!_resetLockedISSM) {
      final activeStepRequest =
          await _repository.fetchUserActiveSteps(StepRequest(User(_userId)));
      _activeSteps = activeStepRequest?.steps ?? 0;
      final bankedStepRequest =
          await _repository.fetchBankedSteps(StepRequest(User(_userId)));
      final totalStepForTheDay =
          await _repository.getTotalStepsForTheDay(StepRequest(User(_userId)));

      _setState!(() {
        _bankedSteps = bankedStepRequest?.steps ?? 0;
        _currentStepsForTheDay = totalStepForTheDay?.steps ?? 0;
        _previousStepsForTheDay = totalStepForTheDay?.steps ?? 0;
      });
    } else {
      final bankedStepRequest =
          await _repository.fetchBankedSteps(StepRequest(User(_userId)));
      _setState!(() {
        _bankedSteps = bankedStepRequest?.steps ?? 0;
      });
    }

    Fimber.d(
        "User ID ----- $_userId --- banked steps: $_bankedSteps ---- Previous Active steps: $_activeSteps Current TSFD: $_currentStepsForTheDay");
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

      if (diff.inDays >= 1 || diff.inHours < 0) {
        Fimber.d(
            "Timestamp is older than one day: Reset total steps for the day");
        _resetLockedISSM = true;
        await resetActiveSteps();
        await resetTotalStepsForTheDay();
        return;
      }

      if (isPastMidnight) {
        Fimber.d("Past midnight: Reset total steps for the day");
        _resetLockedISSM = true;
        await resetActiveSteps();
        await resetTotalStepsForTheDay();
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

  Future<void> resetTotalStepsForTheDay() async {
    _currentStepsForTheDay = 0;
    _previousStepsForTheDay = 0;
    final res = await _repository.resetTotalStepsForTheDay(UpdateStepRequest(
        User(_userId),
        ActiveSteps(
          0,
          "",
        )));

    _setState!(() {
      _currentStepsForTheDay = res?.steps ?? 0;
      _previousStepsForTheDay = 0;
    });
  }

  Future<void> resetActiveSteps() async {
    _activeSteps = 0;
    final res = await _repository.resetUserActiveSteps(UpdateStepRequest(
        User(_userId),
        ActiveSteps(
          0,
          "",
        )));
    _setState!(() {
      _activeSteps = res?.steps ?? 0;
    });
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
      _setState!(() {
        _currentStepsForTheDay = newSteps;
      });
      return;
    }
  }

  Future<void> _onPedestrianStatusChanged(PedestrianStatus event) async {
    if (event.status == "walking") {
      _checkPreviousTimeStamp();
    }

    if (event.status == "stopped") {
      final activeSteps = _currentStepsForTheDay - _previousStepsForTheDay;
      Fimber.d(
          "Active Step Diff: $_currentStepsForTheDay - $_previousStepsForTheDay = $activeSteps");
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
      _setState!(() {
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

  onBankSteps() async {
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
      _setState!(() {
        _bankedSteps = bankedSteps;
        _activeSteps = latestActiveSteps;
      });
    }
  }

  Future<void> initPedometer() async {
    if (await Permission.activityRecognition.request().isGranted) {
      _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
      _pedestrianStatusStream
          .listen(_onPedestrianStatusChanged)
          .onError(_onPedestrianStatusError);
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream.listen(_onStepCount).onError(_onStepCountError);
    }
  }
}
