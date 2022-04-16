import 'package:step_banker_lite/data/local_storage/sql.dart';

class BankedStepModel {
  int? id;
  int? steps;
  String? userId;
  String? timestampISO8601;


  BankedStepModel(this.id, this.steps, this.userId, this.timestampISO8601);

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      BankedStepsTableProps.USER_ID: userId,
      BankedStepsTableProps.STEPS: steps,
      BankedStepsTableProps.TIMESTAMP: timestampISO8601
    };

    if (id != null) {
      map[BankedStepsTableProps.PRIMARY_KEY] = id;
    }
    return map;
  }

  BankedStepModel.fromMap(Map<dynamic, dynamic> map) {
    id = map[BankedStepsTableProps.PRIMARY_KEY] as int?;
    steps = map[BankedStepsTableProps.STEPS] as int?;
    userId = map[BankedStepsTableProps.USER_ID] as String?;
    timestampISO8601 = map[BankedStepsTableProps.TIMESTAMP] as String?;
  }
}
