import 'package:flutter/material.dart';

// Farmer/Farm Features (ACTIVE - Testing Mode)
import 'controllers/farmer_controller.dart';
import 'screens/farm/farm_test_home_screen.dart';
import 'screens/farm/farmer_list_screen.dart';
import 'screens/farm/farmer_detail_screen.dart';
import 'screens/farm/farm_list_screen.dart';
import 'screens/farm/farm_detail_screen.dart';
import 'screens/farm/farm_image_screen.dart';

// Marketplace Screens (COMMENTED - Will be uncommented to switch back)
// import 'package:guardian/screens/marketplace/shop_home_screen.dart';
// import 'package:guardian/screens/marketplace/product_detail_screen.dart';
// import 'package:guardian/screens/marketplace/product_form_screen.dart';
// import 'package:guardian/screens/marketplace/cart_screen.dart';
// import 'package:guardian/screens/marketplace/checkout_screen.dart';
// import 'package:guardian/screens/marketplace/order_success_screen.dart';
// import 'package:guardian/screens/marketplace/my_orders_screen.dart';
// import 'package:guardian/screens/marketplace/my_products_screen.dart';
// import 'package:guardian/screens/marketplace/admin_dashboard_screen.dart';
// import 'package:guardian/screens/marketplace/order_detail_screen.dart';
// import 'package:guardian/models/order_model.dart';

class GuardianApp extends StatelessWidget {
  const GuardianApp({
    super.key,
    required this.farmerController,
  });

  final FarmerController farmerController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian - Farm Features (TEST MODE)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F5C45)),
        useMaterial3: true,
        // AppBar đồng bộ màu thương hiệu
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F5C45),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      // TẠMMODE: TEST FARM FEATURES
      initialRoute: '/farm-test',
      
      // =============================================================
      // ROUTES: FARM FEATURES (TESTING)
      // =============================================================
      routes: {
        // Farm Features - TEST MODE
        '/farm-test': (context) => const FarmTestHomeScreen(),
        '/farmers': (context) => const FarmerListScreen(),
        '/farms': (context) => const FarmListScreen(),
        
        // Screens without parameters (create new)
        '/farmer-detail': (context) => const FarmerDetailScreen(),
        '/farm-detail': (context) => const FarmDetailScreen(),
      },

      // =============================================================
      // DYNAMIC ROUTES (FARM FEATURES - TESTING MODE)
      // =============================================================
      onGenerateRoute: (settings) {
        // Edit Farmer (pass Farmer object)
        if (settings.name == '/farmer-detail/edit') {
          final farmer = settings.arguments as dynamic;
          return MaterialPageRoute(
            builder: (context) => FarmerDetailScreen(farmer: farmer),
          );
        }

        // Edit Farm (pass Farm object)
        if (settings.name == '/farm-detail/edit') {
          final farm = settings.arguments as dynamic;
          return MaterialPageRoute(
            builder: (context) => FarmDetailScreen(farm: farm),
          );
        }

        // Add Farm with Farmer ID
        if (settings.name == '/farm-detail/add') {
          final farmerId = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (context) => FarmDetailScreen(farmerId: farmerId),
          );
        }

        // Images Management (pass referenceId, referenceType, title)
        if (settings.name == '/farm-images') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => FarmImageScreen(
              referenceId: args['referenceId'] as String,
              referenceType: args['referenceType'] as String,
              title: args['title'] as String,
            ),
          );
        }

        return null;
      },
    );
  }
}