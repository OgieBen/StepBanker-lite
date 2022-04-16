import 'package:step_banker_lite/data/model/abstract/res.dart';
import 'package:step_banker_lite/data/model/steps/banked_steps.dart';
import 'package:step_banker_lite/data/model/steps/steps.dart';

class StepResponse implements Response {
  final BankedStep? bankedStep;

  @override
  final String? errMsg;
  @override
  final String? errorCode;

  StepResponse(this.bankedStep, this.errMsg, this.errorCode);
}

class ActiveStepResponse implements Response {
  final ActiveSteps? activeSteps;

  @override
  final String? errMsg;
  @override
  final String? errorCode;

  ActiveStepResponse(this.activeSteps, this.errMsg, this.errorCode);
}