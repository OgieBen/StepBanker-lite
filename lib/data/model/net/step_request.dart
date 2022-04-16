import 'package:step_banker_lite/data/model/abstract/req.dart';
import 'package:step_banker_lite/data/model/user/user.dart';

class StepRequest implements Request {
  @override
  final User user;
  StepRequest(this.user);
}