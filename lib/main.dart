import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart'; // Thay thế BLoC bằng Provider

// sqflite ffi cho các nền tảng desktop
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:guardian/app.dart';
import 'package:guardian/core/database/database_helper.dart';

// ĐÃ MỞ COMMENT IMPORT CỦA MODULE MACHINE
import 'package:guardian/repositories/machine_repository.dart';
import 'package:guardian/controllers/machine_controller.dart';

// Tạm thời ẩn Product của bạn Thanh chờ code xong
// import 'package:guardian/repositories/product_repository.dart';
// import 'package:guardian/controllers/product_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 1. Khởi tạo Database Services (Core)
  final dbProvider = DatabaseProvider(config: databaseConfig);
  final dbService = DatabaseService(dbProvider);
  final domainQueries = DomainQueries(dbService);

  // 2. Khởi tạo các Repositories (Truyền dbService vào để móc data)
  // ĐÃ MỞ COMMENT CHO MACHINE REPOSITORY
  final machineRepo = MachineRepository(dbService);

  // final productRepo = ProductRepository(dbService);

  // 3. Chạy App kèm MultiProvider
  runApp(
    MultiProvider(
      providers: [
        // ĐÃ MỞ COMMENT ĐỂ KHỞI TẠO MACHINE CONTROLLER VÀO HỆ THỐNG
        ChangeNotifierProvider(create: (_) => MachineController(machineRepo)),

        // ChangeNotifierProvider(create: (_) => ProductController(productRepo)),
      ],
      child: const GuardianApp(),
    ),
  );
}
