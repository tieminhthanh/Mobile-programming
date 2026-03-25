import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:guardian/app.dart';
import 'package:guardian/core/database/database_helper.dart';
import 'package:guardian/repositories/machine_repository.dart';
import 'package:guardian/controllers/machine_controller.dart';
import 'package:guardian/controllers/session_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await SessionController.instance.init();

  final dbProvider = DatabaseProvider(config: databaseConfig);
  final dbService = DatabaseService(dbProvider);
  final machineRepo = MachineRepository(dbService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MachineController(machineRepo)),
      ],
      child: const GuardianApp(),
    ),
  );
}
