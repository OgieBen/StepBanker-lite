import 'package:step_banker_lite/data/model/abstract/req.dart';
import 'package:step_banker_lite/data/model/steps/steps.dart';
import 'package:step_banker_lite/data/model/user/user.dart';

class UpdateStepRequest implements Request {
  @override
  final User user;
  final ActiveSteps activeSteps;

  UpdateStepRequest(this.user, this.activeSteps);
}