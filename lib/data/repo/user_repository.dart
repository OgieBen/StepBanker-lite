import 'package:fimber/fimber.dart';
import 'package:step_banker_lite/data/local_storage/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserRepository {

  final SharedPreferencesHelper _localStorage;

  UserRepository(this._localStorage);

  Future<String?> initUserId() async {
    final isUserIDPresent = await _localStorage.checkUserId();
    if (!isUserIDPresent) {
      var uuid = const Uuid();
      final id = uuid.v1();
      Fimber.d("ID ------- $id");
      _localStorage.updateUserId(id);
      return await _localStorage.fetchUserId();
    }
    return await _localStorage.fetchUserId();
  }

  Future<String?> fetchUserId() async {
    return await _localStorage.fetchUserId();
  }


}