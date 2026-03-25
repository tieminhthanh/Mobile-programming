import 'package:flutter/material.dart';
import 'package:guardian/models/farmer.dart';
import 'package:provider/provider.dart';

// Commented out - fixing build errors, can enable later
// import 'features/admin/domain/repositories/admin_repository.dart';
// import 'features/admin/presentation/pages/admin_dashboard_page.dart';
// import 'features/product/domain/entities/product.dart';
// import 'features/product/presentation/pages/home_page.dart';
// import 'features/product/presentation/pages/product_add_edit_page.dart';
// import 'features/product/presentation/pages/product_detail_page.dart';
// import 'features/product/presentation/pages/product_list_page.dart';
// import 'features/routes/app_routes.dart';

import 'controllers/farmer_controller.dart';
import 'screens/farm/farm_test_home_screen.dart';
import 'screens/farm/farmer_list_screen.dart';
import 'screens/farm/farmer_detail_screen.dart';
import 'screens/farm/farm_list_screen.dart';
import 'screens/farm/farm_detail_screen.dart';
import 'screens/farm/farm_image_screen.dart';
// Import AppRoutes separately to avoid product/admin dependencies
import 'features/routes/app_routes.dart';

class GuardianApp extends StatelessWidget {
  const GuardianApp({
    super.key,
    required this.farmerController,
  });

  final FarmerController farmerController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian Farm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F5C45)),
        useMaterial3: true,
      ),
      initialRoute: '/farm-home',
      routes: {
        // Farm Home - Main screen for farmer features
        '/farm-home': (context) => const FarmTestHomeScreen(),
        
        // Commented out - product and admin routes (fixing build errors, can enable later)
        // AppRoutes.home: (context) => const HomePage(),
        // AppRoutes.products: (context) => const ProductListPage(),
        // AppRoutes.productAdd: (context) => const ProductAddEditPage(),
        // AppRoutes.adminDashboard: (context) => AdminDashboardPage(
        //       adminRepository: adminRepository,
        //       initialTabIndex:
        //           (ModalRoute.of(context)?.settings.arguments as int?) ?? 0,
        //     ),
        // AppRoutes.productDetail: (context) {
        //   final args = ModalRoute.of(context)?.settings.arguments as Product?;
        //   if (args != null) {
        //     return ProductDetailPage(product: args, images: const []);
        //   }
        //   return const SizedBox.shrink();
        // },
        // AppRoutes.productEdit: (context) {
        //   final args = ModalRoute.of(context)?.settings.arguments as Product?;
        //   return ProductAddEditPage(product: args);
        // },
        
        // Farmer Management routes - for task functionalities
        AppRoutes.farmerList: (context) => const FarmerListScreen(),
       AppRoutes.farmerDetail: (context) {
          final farmer = ModalRoute.of(context)!.settings.arguments as Farmer?;
          return FarmerDetailScreen(farmer: farmer);
        },
        AppRoutes.farmList: (context) {
          final farmerId = ModalRoute.of(context)?.settings.arguments as String?;
          return FarmListScreen(farmerId: farmerId);
        },
        AppRoutes.farmDetail: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          return FarmDetailScreen(
            farm: args?['farm'],
            farmerId: args?['farmerId'],
          );
        },
        AppRoutes.farmImages: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          final referenceType = args?['type'] ?? 'Farmer';
          return FarmImageScreen(
            referenceId: args?['id'] ?? '',
            referenceType: referenceType,
            title: args?['title'] ?? referenceType,
          );
        },
      },
    );
  }
}
