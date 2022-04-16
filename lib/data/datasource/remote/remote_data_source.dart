import 'package:fimber/fimber.dart';
import 'package:step_banker_lite/data/datasource/data_source.dart';
import 'package:step_banker_lite/data/model/net/step_request.dart';
import 'package:step_banker_lite/data/model/net/step_response.dart';
import 'package:step_banker_lite/data/model/net/update_step_request.dart';
import 'package:step_banker_lite/data/model/steps/banked_steps.dart';
import 'package:step_banker_lite/net/api.dart';
import 'package:step_banker_lite/net/env.dart';

class RemoteDataSource implements DataSource {
  @override
  Future<ActiveStepResponse> getUserActiveSteps(StepRequest payload) {
    // TODO: implement getUserActiveSteps
    throw UnimplementedError();
  }

  @override
  Future<StepResponse> getUserBankedSteps(StepRequest payload) {
    // TODO: implement getUserBankedSteps
    throw UnimplementedError();
  }

  @override
  Future<ActiveStepResponse> updateUserActiveSteps(UpdateStepRequest payload) {
    // TODO: implement updateUserActiveSteps
    throw UnimplementedError();
  }

  @override
  Future<StepResponse> updateUserBankedSteps(UpdateStepRequest payload) {
    final httpClient = HttpClient();
    final _payload = {
      "id": "",
      "userId": payload.user.id,
      "steps": payload.activeSteps.steps,
      "timestamp": payload.activeSteps.timestampISO8601
    };
    httpClient.post("$BASE_URL/api/v1/users/steps", _payload);
    return Future.value(StepResponse(BankedStep(0, ""), null, null));
  }

  @override
  Future<ActiveStepResponse> updateTotalStepsForTheDay(
      UpdateStepRequest payload) {
    // TODO: implement updateTotalStepsForTheDay
    throw UnimplementedError();
  }

  @override
  Future<ActiveStepResponse> getLockedInitialStepsSinceMidnight(
      StepRequest payload) {
    // TODO: implement getLockedInitialStepsSinceMidnight
    throw UnimplementedError();
  }

  @override
  Future<ActiveStepResponse> getTotalStepsForTheDay(StepRequest payload) {
    // TODO: implement getTotalStepsForTheDay
    throw UnimplementedError();
  }

  @override
  Future<ActiveStepResponse> updateLockedInitialStepsSinceMidnight(
      UpdateStepRequest payload) {
    // TODO: implement updateLockedInitialStepsSinceMidnight
    throw UnimplementedError();
  }

  @override
  Future<ActiveStepResponse> resetUserActiveSteps(UpdateStepRequest payload) {
    // TODO: implement resetUserActiveSteps
    throw UnimplementedError();
  }

  @override
  Future<ActiveStepResponse> resetTotalStepsForTheDay(
      UpdateStepRequest payload) {
    // TODO: implement resetTotalStepsForTheDay
    throw UnimplementedError();
  }
}
