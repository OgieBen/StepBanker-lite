import 'package:step_banker_lite/data/datasource/data_source.dart';
import 'package:step_banker_lite/data/local_storage/shared_preferences.dart';
import 'package:step_banker_lite/data/model/net/step_request.dart';
import 'package:step_banker_lite/data/model/net/step_response.dart';
import 'package:step_banker_lite/data/model/net/update_step_request.dart';
import 'package:step_banker_lite/data/model/steps/banked_steps.dart';
import 'package:step_banker_lite/data/model/steps/steps.dart';

class LocalDataSource implements DataSource {
  final SharedPreferencesHelper _localStorage;

  LocalDataSource(this._localStorage);

  @override
  Future<ActiveStepResponse> getUserActiveSteps(StepRequest payload) async {
    int activeSteps = await _localStorage.fetchActiveSteps();
    return ActiveStepResponse(
        ActiveSteps(activeSteps, ""),
        null,
        null);
  }

  @override
  Future<ActiveStepResponse> updateUserActiveSteps(UpdateStepRequest payload) async {
    final activeSteps = await _localStorage.updateActiveSteps(payload.activeSteps.steps);
    return ActiveStepResponse(
        ActiveSteps(activeSteps, ""),
        null,
        null);
  }

  @override
  Future<StepResponse> getUserBankedSteps(StepRequest payload) async {
    final steps = await _localStorage.fetchBankedSteps();
    return StepResponse(
        BankedStep(steps, ""),
        null,
        null);
  }

  @override
  Future<StepResponse> updateUserBankedSteps(UpdateStepRequest payload) async {
    final steps = await _localStorage.updateBankedSteps(payload.activeSteps.steps);
    // Update remote server.
    return StepResponse(
        BankedStep(steps, ""),
        null,
        null);
  }

  recordLastStepTimestamp(String timestamp) {
    _localStorage.recordTimeStampForLastStepEntry(timestamp);
  }
  Future<String?> getLastStepTimestamp() {
    return _localStorage.fetchTimestampForLastStep();
  }

  @override
  Future<ActiveStepResponse> updateTotalStepsForTheDay(UpdateStepRequest payload) async {
    final steps = await _localStorage.updateTotalStepsForTheDay(payload.activeSteps.steps);
    return ActiveStepResponse(
        ActiveSteps(steps, ""),
        null,
        null);
  }

  @override
  Future<ActiveStepResponse> getLockedInitialStepsSinceMidnight(StepRequest payload) async {
    final steps = await _localStorage.fetchLockedInitialStepsSinceMidnight();
    return ActiveStepResponse(
        ActiveSteps(steps, ""),
        null,
        null);
  }

  @override
  Future<ActiveStepResponse> getTotalStepsForTheDay(StepRequest payload) async {
    final steps = await _localStorage.fetchUserTotalStepsForTheDay();
    return ActiveStepResponse(
        ActiveSteps(steps, ""),
        null,
        null);
  }

  @override
  Future<ActiveStepResponse> updateLockedInitialStepsSinceMidnight(UpdateStepRequest payload) async {
    final steps = await _localStorage.updateLockedInitialStepsSinceMidnight(payload.activeSteps.steps);
    return ActiveStepResponse(
        ActiveSteps(steps, ""),
        null,
        null);
  }

  @override
  Future<ActiveStepResponse> resetUserActiveSteps(UpdateStepRequest payload) async {
    final steps = await _localStorage.restActiveSteps();
    return ActiveStepResponse(
        ActiveSteps(steps, ""),
        null,
        null);
  }

  @override
  Future<ActiveStepResponse> resetTotalStepsForTheDay(UpdateStepRequest payload) async {
    final steps = await _localStorage.resetTotalStepsForTheDay();
    return ActiveStepResponse(
        ActiveSteps(steps, ""),
        null,
        null);
  }
}
