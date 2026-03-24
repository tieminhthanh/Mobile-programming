import 'package:flutter/material.dart';

import 'features/admin/domain/repositories/admin_repository.dart';
import 'features/admin/presentation/pages/admin_dashboard_page.dart';
import 'features/product/domain/entities/product.dart';
import 'features/product/presentation/pages/home_page.dart';
import 'features/product/presentation/pages/product_add_edit_page.dart';
import 'features/product/presentation/pages/product_detail_page.dart';
import 'features/product/presentation/pages/product_list_page.dart';
import 'features/routes/app_routes.dart';

class GuardianApp extends StatelessWidget {
  const GuardianApp({
    super.key,
    required this.adminRepository,
  });

  final AdminRepository adminRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian Farm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F5C45)),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (context) => const HomePage(),
        AppRoutes.products: (context) => const ProductListPage(),
        AppRoutes.productAdd: (context) => const ProductAddEditPage(),
        AppRoutes.adminDashboard: (context) => AdminDashboardPage(
              adminRepository: adminRepository,
              initialTabIndex:
                  (ModalRoute.of(context)?.settings.arguments as int?) ?? 0,
            ),
        AppRoutes.productDetail: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Product?;
          if (args != null) {
            return ProductDetailPage(product: args, images: const []);
          }
          return const SizedBox.shrink();
        },
        AppRoutes.productEdit: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Product?;
          return ProductAddEditPage(product: args);
        },
      },
    );
  }
}
