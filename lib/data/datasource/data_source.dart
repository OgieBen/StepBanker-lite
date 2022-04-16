import 'package:step_banker_lite/data/model/net/step_request.dart';
import 'package:step_banker_lite/data/model/net/step_response.dart';
import 'package:step_banker_lite/data/model/net/update_step_request.dart';

abstract class DataSource {
  Future<ActiveStepResponse> getUserActiveSteps(StepRequest payload) ;
  Future<StepResponse> getUserBankedSteps(StepRequest payload);
  Future<ActiveStepResponse> updateUserActiveSteps(UpdateStepRequest payload);
  Future<ActiveStepResponse> resetUserActiveSteps(UpdateStepRequest payload);
  Future<ActiveStepResponse> resetTotalStepsForTheDay(UpdateStepRequest payload);
  Future<StepResponse> updateUserBankedSteps(UpdateStepRequest payload);
  Future<ActiveStepResponse> updateTotalStepsForTheDay(UpdateStepRequest payload);
  Future<ActiveStepResponse> updateLockedInitialStepsSinceMidnight(UpdateStepRequest payload);
  Future<ActiveStepResponse> getTotalStepsForTheDay(StepRequest payload);
  Future<ActiveStepResponse> getLockedInitialStepsSinceMidnight(StepRequest payload);

}