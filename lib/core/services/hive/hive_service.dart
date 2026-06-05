import 'package:hive_flutter/hive_flutter.dart';
import 'package:uni_sphere/features/auth/data/models/auth_hive_model.dart';

class HiveService {
  static const _authBox = 'auth_box';
  late Box<AuthHiveModel> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AuthHiveModelAdapter());
    _box = await Hive.openBox<AuthHiveModel>(_authBox);
  }

  Future<void> registerUser(AuthHiveModel user) async {
    await _box.put(user.email, user);
  }

  AuthHiveModel? getUser(String email) {
    return _box.get(email);
  }

  Future<void> deleteUser(String email) async {
    await _box.delete(email);
  }

  List<AuthHiveModel> getAllUsers() {
    return _box.values.toList();
  }
}
