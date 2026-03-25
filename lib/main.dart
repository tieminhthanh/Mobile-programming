import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:guardian/core/database/database_helper.dart';
import 'package:guardian/repositories/commerce_repository.dart';
import 'package:guardian/controllers/product_controller.dart';
import 'package:guardian/controllers/cart_controller.dart';
import 'package:guardian/repositories/farmer_repository.dart';
import 'package:guardian/controllers/farmer_controller.dart';
import 'package:guardian/models/user_model.dart';
import 'package:guardian/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // =========================
  // INIT SQLITE FOR DESKTOP
  // =========================
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // =========================
  // DATABASE
  // =========================
  final dbProvider = DatabaseProvider(config: databaseConfig);
  final dbService = DatabaseService(dbProvider);

  // =========================
  // REPOSITORIES
  // =========================
  final farmerRepository = FarmerRepository(dbService: dbService);
  final commerceRepository = CommerceRepository(dbService);

  // =========================
  // DEFAULT USER (for testing/initial state)
  // =========================
  final defaultUser = UserModel(
    userId: 1,
    phoneNumber: '0123456789',
    roleType: 'FARMER',
    displayName: 'Test User',
  );

  // =========================
  // CONTROLLERS
  // =========================
  final farmerController = FarmerController(repository: farmerRepository);
  final productController = ProductController(
    repository: commerceRepository,
    currentUser: defaultUser,
  );
  final cartController = CartController(
    repository: commerceRepository,
    currentUser: defaultUser,
  );

  // =========================
  // RUN APP
  // =========================
  runApp(
    MultiProvider(
      providers: [
        // Farmer feature
        ChangeNotifierProvider<FarmerController>(
          create: (_) => farmerController,
        ),

        // Product feature
        ChangeNotifierProvider<ProductController>(
          create: (_) => productController,
        ),

        // Cart feature
        ChangeNotifierProvider<CartController>(
          create: (_) => cartController,
        ),
      ],
        child: GuardianApp(
        farmerController: farmerController,
      ),
    ),
  );
}