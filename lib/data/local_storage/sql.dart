

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:step_banker_lite/data/model/steps/banked_steps_model.dart';

class SqlHelper {

  late Database _db;

  _getDbPath() async {
    var databasesPath = await getDatabasesPath();
    return join(databasesPath, DBProps.DB_FILE_NAME);
  }

  deleteLocalDatabase() async {
    final path = await _getDbPath();
    await deleteDatabase(path);
  }

  createDatabase() async {
    String path = _getDbPath();
     _db = await openDatabase(path, version: DBProps.DATABASE_VERSION,
        onCreate: (Database db, int version) async {
          await db.execute('CREATE TABLE ${BankedStepsTableProps.TABLE_NAME} (${BankedStepsTableProps.PRIMARY_KEY} INTEGER PRIMARY KEY, ${BankedStepsTableProps.STEPS} INTEGER, ${BankedStepsTableProps.USER_ID} Text, ${BankedStepsTableProps.TIMESTAMP} TEXT)');
        });
  }

  Future<BankedStepModel> insertBankedSteps(BankedStepModel model) async {
    model.id = await _db.insert(BankedStepsTableProps.TABLE_NAME, model.toMap());
    return model;
  }

  Future<List<BankedStepModel>?> getBankedStepsFromTimeStamp(int timestamp) async {
    List<Map> maps = await _db.query(BankedStepsTableProps.TABLE_NAME,
        columns: [BankedStepsTableProps.PRIMARY_KEY, BankedStepsTableProps.STEPS, BankedStepsTableProps.TIMESTAMP, BankedStepsTableProps.USER_ID],
        where: '${BankedStepsTableProps.TIMESTAMP} > ?',
        whereArgs: [timestamp]);
    if (maps.isNotEmpty) {
      final convertedMap = maps.map((map) => BankedStepModel.fromMap(map));
      return convertedMap.toList();
    }
    return null;
  }

}

abstract class DBProps {
  static const DB_FILE_NAME = "step_banker_lite.db";
  static const DATABASE_VERSION = 1;
}

abstract class BankedStepsTableProps {
  static const TABLE_NAME = "BankedSteps";
  static const PRIMARY_KEY = "id";
  static const STEPS = "steps";
  static const USER_ID = "user_id";
  static const TIMESTAMP = "timestampISO8601";
}