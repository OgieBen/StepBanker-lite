import 'package:step_banker_lite/data/datasource/data_source.dart';
import 'package:step_banker_lite/data/datasource/local/local_data_source.dart';
import 'package:step_banker_lite/data/model/net/step_request.dart';
import 'package:step_banker_lite/data/model/net/update_step_request.dart';
import 'package:step_banker_lite/data/model/steps/banked_steps.dart';
import 'package:step_banker_lite/data/model/steps/steps.dart';
import 'package:step_banker_lite/data/model/user/user.dart';

class StepRepository {
  final DataSource _localDataSource;
  final DataSource _remoteDataSource;

  StepRepository(this._localDataSource, this._remoteDataSource);

  Future<BankedStep?> fetchBankedSteps(StepRequest payload) async {
    final result = await _localDataSource.getUserBankedSteps(payload);
    return result.bankedStep;
  }

  Future<BankedStep?> updateUserBankedSteps(UpdateStepRequest request) async {
    final result = await _localDataSource.updateUserBankedSteps(request);
    await _remoteDataSource.updateUserBankedSteps(UpdateStepRequest(
        User(request.user.id),
        ActiveSteps(
          result.bankedStep?.steps ?? 0,
          DateTime.now().toIso8601String(),
        )));
    return result.bankedStep;
  }

  Future<ActiveSteps?> fetchUserActiveSteps(StepRequest payload) async {
    final result = await _localDataSource.getUserActiveSteps(payload);
    return result.activeSteps;
  }

  Future<ActiveSteps?> updateUserActiveSteps(UpdateStepRequest steps) async {
    final result = await _localDataSource.updateUserActiveSteps(steps);
    return result.activeSteps;
  }

  Future<ActiveSteps?> resetUserActiveSteps(UpdateStepRequest steps) async {
    final result = await _localDataSource.resetUserActiveSteps(steps);
    return result.activeSteps;
  }

  Future<ActiveSteps?> updateTotalStepsForTheDay(
      UpdateStepRequest steps) async {
    final result = await _localDataSource.updateTotalStepsForTheDay(steps);
    return result.activeSteps;
  }

  recordLastStepTimestamp(String timestamp) {
    (_localDataSource as LocalDataSource).recordLastStepTimestamp(timestamp);
  }

  Future<String?> getLastStepTimestamp() {
    return (_localDataSource as LocalDataSource).getLastStepTimestamp();
  }

  Future<ActiveSteps?> getLockedInitialStepsSinceMidnight(
      StepRequest payload) async {
    final steps =
        await _localDataSource.getLockedInitialStepsSinceMidnight(payload);
    return steps.activeSteps;
  }

  Future<ActiveSteps?> getTotalStepsForTheDay(StepRequest payload) async {
    final steps = await _localDataSource.getTotalStepsForTheDay(payload);
    return steps.activeSteps;
  }

  Future<ActiveSteps?> updateLockedInitialStepsSinceMidnight(
      UpdateStepRequest payload) async {
    final steps =
        await _localDataSource.updateLockedInitialStepsSinceMidnight(payload);
    return steps.activeSteps;
  }

  Future<ActiveSteps?> resetTotalStepsForTheDay(
      UpdateStepRequest payload) async {
    final steps = await _localDataSource.resetTotalStepsForTheDay(payload);
    return steps.activeSteps;
  }
}
