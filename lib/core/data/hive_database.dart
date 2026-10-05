import 'package:hive_flutter/hive_flutter.dart';

class HiveDatabase {
  static const String settingsBoxName = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(settingsBoxName);
  }
}
