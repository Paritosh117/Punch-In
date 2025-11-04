import 'package:hive_flutter/hive_flutter.dart';
import 'PunchesModel.dart';

class EmployeeDatabase{

  static Future<void> initEmployeeBox() async {
    await Hive.initFlutter(); // Initialize Hive

    // Register adapter once
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PunchesModelAdapter());
    }

    // Open the employee box
    final box = await Hive.openBox<PunchesModel>('Employee');
    print("Employee Box initialized: ${box.name}");
  }

  static Future<void> verifyBox() async {
    if (!Hive.isBoxOpen('Employee')) {
      await Hive.openBox<PunchesModel>('Employee');
      print("Employee Box opened");
    } else {
      print("Employee Box already open");
    }
  }

  static Future<void> savePunch(PunchesModel punch) async {
    final box = await Hive.openBox<PunchesModel>('Employee'); // Opens if not already open
    await box.add(punch);
    print("Punch saved: ${punch.time}");
  }

  static Future<List<PunchesModel>> getPunches() async {
    final box = await Hive.openBox<PunchesModel>('Employee  '); // Opens if not open
    final punches = box.values.toList();
    print("Total punches: ${punches.length}");
    return punches;
  }

  static Future<void> clearPunches() async {
    final box = await Hive.openBox<PunchesModel>('Employee'); // Opens if not open
    await box.clear();
    print("All punches cleared");
  }
}