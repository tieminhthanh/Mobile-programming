import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:guardian/core/database/database_helper.dart';
import 'package:guardian/repositories/commerce_repository.dart';
import 'package:guardian/controllers/product_controller.dart';
import 'package:guardian/controllers/cart_controller.dart';
// Đảm bảo bạn đã có file user_model.dart trong thư mục models
import 'package:guardian/models/user_model.dart';
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

  // 1. Khởi tạo Database
  final dbProvider = DatabaseProvider(config: databaseConfig);
  final dbService = DatabaseService(dbProvider);
  final commerceRepository = CommerceRepository(dbService);

  // =============================================================
  // 2. CẤU HÌNH TÀI KHOẢN GIẢ LẬP (MOCK USER)
  // Chọn 1 trong 3 tài khoản dưới đây để test phân quyền
  // =============================================================

  // --- OPTION A: SME (Người bán - HTX Nông Nghiệp Xanh) ---
  // final currentUser = UserModel(
  //   userId: 5,
  //   phoneNumber: '0911000001',
  //   roleType: 'SME',
  //   displayName: 'HTX Nông Nghiệp Xanh',
  // );

  //  --- OPTION B: ADMIN (Quản trị viên hệ thống) ---
  final currentUser = UserModel(
    userId: 9, 
    phoneNumber: '0888000001',
    roleType: 'ADMIN', 
    displayName: 'Admin Vận Hành',
  );
  

  /*
  // --- OPTION C: FARMER (Khách mua hàng - Nguyễn Văn Tèo) ---
  final currentUser = UserModel(
    userId: 1, 
    phoneNumber: '0901000001',
    roleType: 'FARMER', 
    displayName: 'Nguyễn Văn Tèo',
  );
  */
  runApp(
    MultiProvider(
      providers: [
        // THÊM DÒNG NÀY ĐỂ MY ORDERS SCREEN ĐỌC ĐƯỢC REPO:
        Provider<CommerceRepository>.value(value: commerceRepository),

        ChangeNotifierProvider<ProductController>(
          create: (_) => ProductController(
            repository: commerceRepository,
            currentUser: currentUser,
          ),
        ),
        ChangeNotifierProvider<CartController>(
          // Truyền thêm currentUser vào CartController ở đây
          create: (_) => CartController(
            repository: commerceRepository,
            currentUser: currentUser,
          ),
        ),
      ],
      child: const GuardianApp(),
    ),
  );
}
