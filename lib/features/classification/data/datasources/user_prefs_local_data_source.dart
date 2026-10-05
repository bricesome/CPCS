import 'package:hive/hive.dart';

import '../../../../core/data/hive_database.dart';

abstract class UserPrefsLocalDataSource {
  List<String> readList(String key);
  Future<void> writeList(String key, List<String> values);
  bool readBool(String key, {required bool fallback});
  Future<void> writeBool(String key, bool value);
}

class HiveUserPrefsLocalDataSource implements UserPrefsLocalDataSource {
  Box get _box => Hive.box(HiveDatabase.settingsBoxName);

  @override
  List<String> readList(String key) =>
      (_box.get(key) as List?)?.cast<String>() ?? <String>[];

  @override
  Future<void> writeList(String key, List<String> values) =>
      _box.put(key, values);

  @override
  bool readBool(String key, {required bool fallback}) =>
      _box.get(key, defaultValue: fallback) as bool;

  @override
  Future<void> writeBool(String key, bool value) => _box.put(key, value);
}

class InMemoryUserPrefsLocalDataSource implements UserPrefsLocalDataSource {
  final Map<String, Object> _store = {};

  @override
  List<String> readList(String key) =>
      List<String>.from(_store[key] as List? ?? const []);

  @override
  Future<void> writeList(String key, List<String> values) async =>
      _store[key] = List<String>.from(values);

  @override
  bool readBool(String key, {required bool fallback}) =>
      _store[key] as bool? ?? fallback;

  @override
  Future<void> writeBool(String key, bool value) async => _store[key] = value;
}
