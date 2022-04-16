import 'package:fimber/fimber.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  Future<int> fetchBankedSteps() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    return _pref.getInt("bankedSteps") ?? 0;
  }

  Future<int> fetchActiveSteps() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    return _pref.getInt("activeSteps") ?? 0;
  }

  Future<String?> fetchUserId() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    return _pref.getString("userId");
  }

  Future<String?> fetchTimestampForLastStep() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    return _pref.getString("timestampForLastStep");
  }

  Future<int> fetchUserTotalStepsForTheDay() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    return _pref.getInt("dailyTotalSteps") ?? 0;
  }

  Future<int> fetchLockedInitialStepsSinceMidnight() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    return _pref.getInt("lockedInitialStepsSinceMidnight") ?? 0;
  }

  Future<bool> checkUserId() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    return _pref.containsKey("userId");
  }

  updateBankedSteps(int initialSteps) async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    var bankedSteps = _pref.getInt("bankedSteps") ?? 0;
    int sum = bankedSteps + initialSteps;
    await _pref.setInt("bankedSteps", sum);
    Fimber.d("Banked steps update - $sum");
    return _pref.getInt("bankedSteps");
  }

  updateActiveSteps(int newActiveSteps) async {
    SharedPreferences? _pref = await SharedPreferences.getInstance();
    var oldActiveSteps = _pref.getInt("activeSteps") ?? 0;
    int sum = newActiveSteps + oldActiveSteps;
    await _pref.setInt("activeSteps", sum);
    Fimber.d("Active steps update - $sum");
    return _pref.getInt("activeSteps");
  }

  restActiveSteps() async {
    SharedPreferences? _pref = await SharedPreferences.getInstance();
    await _pref.setInt("activeSteps", 0);
    final s = _pref.getInt("activeSteps");
    Fimber.d("Reset active steps for the day $s");
    return s;
  }

  resetTotalStepsForTheDay() async {
    SharedPreferences? _pref = await SharedPreferences.getInstance();
    await _pref.setInt("dailyTotalSteps", 0);
    final v = _pref.getInt("dailyTotalSteps");
    Fimber.d("Reset total steps for the day: $v");
    return v;
  }

  updateTotalStepsForTheDay(int newDailyTotalSteps) async {
    SharedPreferences? _pref = await SharedPreferences.getInstance();
    await _pref.setInt("dailyTotalSteps", newDailyTotalSteps);
    Fimber.d("Updated total steps for the day with - $newDailyTotalSteps steps");
    return _pref.getInt("dailyTotalSteps");
  }

  updateLockedInitialStepsSinceMidnight(int newLockedSteps) async {
    SharedPreferences? _pref = await SharedPreferences.getInstance();
    await _pref.setInt("lockedInitialStepsSinceMidnight", newLockedSteps);
    Fimber.d("Total locked steps for the day is - $newLockedSteps");
    return _pref.getInt("lockedInitialStepsSinceMidnight");
  }


  updateUserId(String id) async {
    SharedPreferences? _pref = await SharedPreferences.getInstance();
    await _pref.setString("userId", id);
    Fimber.d(
        "Checking _pref nullability ---- ${_pref.containsKey("userId")} ---- ${_pref.getString("userId")}");
  }

  recordTimeStampForLastStepEntry(String timestamp) async {
    SharedPreferences? _pref = await SharedPreferences.getInstance();
    await _pref.setString("timestampForLastStep", timestamp);
    Fimber.d("Updated timestamp: ${_pref.getString("timestampForLastStep")}");
  }
}
