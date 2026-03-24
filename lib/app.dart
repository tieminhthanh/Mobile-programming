import 'package:flutter/material.dart';

// Import Models
import 'package:guardian/models/order_model.dart';

// Import Marketplace Screens
import 'package:guardian/screens/marketplace/shop_home_screen.dart';
import 'package:guardian/screens/marketplace/product_detail_screen.dart';
import 'package:guardian/screens/marketplace/product_form_screen.dart';
import 'package:guardian/screens/marketplace/cart_screen.dart';
import 'package:guardian/screens/marketplace/checkout_screen.dart';
import 'package:guardian/screens/marketplace/order_success_screen.dart';
import 'package:guardian/screens/marketplace/my_orders_screen.dart';
import 'package:guardian/screens/marketplace/my_products_screen.dart';

// Import Admin/SME Screens
import 'package:guardian/screens/marketplace/admin_dashboard_screen.dart';
import 'package:guardian/screens/marketplace/order_detail_screen.dart';

class GuardianApp extends StatelessWidget {
  const GuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian Marketplace',
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
      initialRoute: '/',
      
      // =============================================================
      // 1. STATIC ROUTES & SIMPLE PARAMETERS (INT)
      // =============================================================
      routes: {
        '/': (context) => const ShopHomeScreen(),
        '/product-form': (context) => const ProductFormScreen(),
        '/my-products': (context) => const MyProductsScreen(),
        '/cart': (context) => const CartScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        
        // Fix lỗi: Thêm route này để Dashboard gọi được danh sách đơn hàng
        '/all-orders': (context) => const MyOrdersScreen(buyerId: 0), 

        '/my-orders': (context) {
          final buyerId = ModalRoute.of(context)!.settings.arguments as int;
          return MyOrdersScreen(buyerId: buyerId);
        },
        
        '/product-detail': (context) {
          final productId = ModalRoute.of(context)!.settings.arguments as int;
          return ProductDetailScreen(productId: productId);
        },
        
        '/order-success': (context) {
          final orderId = ModalRoute.of(context)!.settings.arguments as int;
          return OrderSuccessScreen(orderId: orderId);
        },
      },

      // =============================================================
      // 2. DYNAMIC ROUTES (OBJECT PARAMETERS)
      // =============================================================
      onGenerateRoute: (settings) {
        // Route chi tiết đơn hàng (truyền nguyên Object OrderModel)
        if (settings.name == '/order-detail') {
          final order = settings.arguments as OrderModel;
          return MaterialPageRoute(
            builder: (context) => OrderDetailScreen(order: order),
          );
        }

        // Route thanh toán (truyền danh sách items đã chọn)
        if (settings.name == '/checkout') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => CheckoutScreen(
              selectedItems: args['selectedItems'],
              totalAmount: args['totalAmount'],
            ),
          );
        }
        
        return null;
      },
    );
  }
}