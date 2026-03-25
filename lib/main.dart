import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

// sqflite ffi for desktop platforms
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:guardian/app.dart';

// Import Database
import 'package:guardian/core/database/database_helper.dart';

// Commented out - fixing build errors, can enable later
// import 'package:guardian/core/constants/api_constants.dart';
// import 'package:guardian/core/network/api_client.dart';
// import 'package:guardian/features/admin/data/datasource/admin_local_datasource.dart';
// import 'package:guardian/features/admin/data/datasource/admin_remote_datasource.dart';
// import 'package:guardian/features/admin/data/repositories/admin_repository_impl.dart';

// Commented out - fixing build errors, can enable later
// import 'package:guardian/features/product/data/datasource/product_local_datasource.dart';
// import 'package:guardian/features/product/data/repositories/product_repository_impl.dart';
// import 'package:guardian/features/product/presentation/bloc/product_bloc.dart';
// import 'package:guardian/features/product/presentation/bloc/product_event.dart';

// Import Farmer Feature
import 'package:guardian/repositories/farmer_repository.dart';
import 'package:guardian/controllers/farmer_controller.dart';

void main() async {
  // Đảm bảo Flutter binding được khởi tạo trước khi gọi native code (SQLite)
  WidgetsFlutterBinding.ensureInitialized();

  // Only desktop platforms should use sqflite_common_ffi.
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 1. Khởi tạo Database Services
  final dbProvider = DatabaseProvider(config: databaseConfig);
  final dbService = DatabaseService(dbProvider);
  
  // Commented out - fixing build errors, can enable later
  // final domainQueries = DomainQueries(dbService);
  // final adminLocalDS = AdminLocalDataSourceImpl(dbService);
  // final apiConstants = ApiConstants.dev();
  // final apiClient = ApiClient(constants: apiConstants);
  // final adminRemoteDS = AdminRemoteDataSourceImpl(
  //   client: apiClient,
  //   constants: apiConstants,
  // );
  // final adminRepository = AdminRepositoryImpl(
  //   localDataSource: adminLocalDS,
  //   remoteDataSource: adminRemoteDS,
  // );

  // Commented out - fixing build errors, can enable later
  // final productLocalDS = ProductLocalDataSourceImpl(dbService, domainQueries);
  // final productRepo = ProductRepositoryImpl(productLocalDS);

  // 3. Khởi tạo Farmer Repository và Controller
  final farmerRepository = FarmerRepository(dbService: dbService);
  final farmerController = FarmerController(repository: farmerRepository);

  // 4. Chạy App kèm MultiProvider (focused on Farmer features only for now)
  runApp(
    MultiProvider(
      providers: [
        // Commented out - fixing build errors, can enable later
        // BlocProvider<ProductBloc>(
        //   create: (context) => ProductBloc(repository: productRepo)..add(LoadProducts()),
        // ),
        ChangeNotifierProvider<FarmerController>(
          create: (context) => farmerController,
        ),
      ],
      child: GuardianApp(
        farmerController: farmerController,
      ),
    ),
  );
}
