import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:guardian/core/database/database_helper.dart';
import 'package:guardian/repositories/commerce_repository.dart';
import 'package:guardian/repositories/machine_repository.dart';
import 'package:guardian/controllers/product_controller.dart';
import 'package:guardian/controllers/cart_controller.dart';
import 'package:guardian/controllers/machine_controller.dart';
import 'package:guardian/controllers/session_controller.dart';
import 'package:guardian/app.dart';

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

  // Initialize database and repositories
  final dbProvider = DatabaseProvider(config: databaseConfig);
  final dbService = DatabaseService(dbProvider);
  final machineRepo = MachineRepository(dbService);
  final commerceRepository = CommerceRepository(dbService);

  runApp(
    MultiProvider(
      providers: [
        // Machine rental feature
        ChangeNotifierProvider(create: (_) => MachineController(machineRepo)),

        // Marketplace feature
        Provider<CommerceRepository>.value(value: commerceRepository),
        ChangeNotifierProvider<ProductController>(
          create: (_) => ProductController(
            repository: commerceRepository,
          ),
        ),
        ChangeNotifierProvider<CartController>(
          create: (_) => CartController(
            repository: commerceRepository,
          ),
        ),
      ],
      child: const GuardianApp(),
    ),
  );
}
