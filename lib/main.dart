import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart'; // Thay thế BLoC bằng Provider

// sqflite ffi for desktop platforms
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:guardian/app.dart';
import 'package:guardian/core/database/database_helper.dart';

// --- SAU NÀY BẠN SẼ IMPORT CÁC REPOSITORY & CONTROLLER VÀO ĐÂY ---
// import 'package:guardian/repositories/machine_repository.dart';
// import 'package:guardian/controllers/machine_controller.dart';
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

  // 1. Khởi tạo Database Services (Giữ nguyên vì nằm trong core - Cực kỳ chuẩn)
  final dbProvider = DatabaseProvider(config: databaseConfig);
  final dbService = DatabaseService(dbProvider);
  final domainQueries = DomainQueries(dbService);

  // 2. Khởi tạo các Repositories (Dùng chung 1 dbService)
  // final machineRepo = MachineRepository(dbService);
  // final productRepo = ProductRepository(dbService);

  // 3. Chạy App kèm MultiProvider (Quản lý các Controller)
  runApp(
    MultiProvider(
      providers: [
        // Khai báo các Controller ở đây để toàn app có thể dùng được
        // ChangeNotifierProvider(create: (_) => MachineController(machineRepo)),
        // ChangeNotifierProvider(create: (_) => ProductController(productRepo)),
      ],
      // Gọi GuardianApp cực kỳ sạch sẽ, không cần nhồi nhét Repository vào đây nữa
      child: const GuardianApp(),
    ),
  );
}
