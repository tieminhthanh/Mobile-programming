import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guardian/core/widgets/auth_guard.dart';
import 'package:guardian/models/user.dart';
import 'package:guardian/screens/machine/machine_calendar_screen.dart';
import 'package:guardian/screens/machine/machine_list_screen.dart';
import 'package:guardian/screens/machine/owner_bookings_screen.dart';
import 'package:guardian/screens/machine/owner_dashboard_screen.dart';
import 'package:guardian/screens/machine/owner_machine_list_screen.dart';

import 'routes/app_routes.dart';
import 'screens/address/address_edit_page.dart';
import 'screens/address/address_list_page.dart';
import 'screens/admin/admin_dashboard_page.dart';
import 'screens/admin/admin_support_page.dart';
import 'screens/admin/system_stats_page.dart';
import 'screens/auth/change_password_page.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/logout_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/enterprise/enterprise_profile_page.dart';
import 'screens/home_page.dart';
import 'screens/user/profile_page.dart';
import 'screens/user/user_list_page.dart';
import 'screens/user/user_lock_page.dart';
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
import 'package:guardian/screens/marketplace/admin_dashboard_screen.dart'
  as marketplace;
import 'package:guardian/screens/marketplace/order_detail_screen.dart';

class GuardianApp extends StatelessWidget {
  const GuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1E6B47);
    const primarySoft = Color(0xFFE8F3ED);
    const background = Color(0xFFF7F8F6);
    const surface = Color(0xFFFFFFFF);
    const onSurface = Color(0xFF1F2933);
    const outline = Color(0xFFDDE3DD);

    final colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: Color(0xFF2F7D58),
      onSecondary: Colors.white,
      surface: surface,
      onSurface: onSurface,
      background: background,
      onBackground: onSurface,
      error: Color(0xFFB00020),
      onError: Colors.white,
      outline: outline,
    );

    final baseTextTheme = GoogleFonts.beVietnamProTextTheme();
    const ownerRoles = [UserRole.sme, UserRole.admin];

    Widget guarded(
      Widget child, {
      List<UserRole>? roles,
      String? deniedRoute,
    }) {
      return AuthGuard(
        loginRoute: AppRoutes.login,
        deniedRoute: deniedRoute ?? AppRoutes.home,
        allowedRoles: roles ?? const <UserRole>[],
        child: child,
      );
    }

    return MaterialApp(
      title: 'Thần Hộ Mệnh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: background,
        textTheme: baseTextTheme.apply(
          bodyColor: onSurface,
          displayColor: onSurface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F5C45),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: const CardThemeData(
          color: surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            side: BorderSide(color: outline),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 1.4),
          ),
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(color: primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            foregroundColor: primary,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primary,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: primarySoft,
          selectedColor: primarySoft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF25563E),
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide.none,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: primary,
          unselectedItemColor: Color(0xFF6B7280),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
        dividerTheme: const DividerThemeData(color: outline, thickness: 1),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: onSurface,
          contentTextStyle: GoogleFonts.beVietnamPro(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.home: (context) => guarded(
          const HomePage(),
          roles: const [UserRole.farmer, UserRole.sme, UserRole.admin],
        ),
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.register: (context) => const RegisterPage(),
        AppRoutes.logout: (context) => guarded(const LogoutPage()),
        AppRoutes.changePassword: (context) => guarded(
          const ChangePasswordPage(),
        ),
        AppRoutes.profile: (context) => guarded(const ProfilePage()),
        AppRoutes.userList: (context) => guarded(
          const UserListPage(),
          roles: const [UserRole.admin],
        ),
        AppRoutes.userLock: (context) => guarded(
          const UserLockPage(),
          roles: const [UserRole.admin],
        ),
        AppRoutes.addressList: (context) => guarded(const AddressListPage()),
        AppRoutes.addressEdit: (context) => guarded(
          const AddressEditPage(),
          deniedRoute: AppRoutes.addressList,
        ),
        AppRoutes.enterpriseProfile: (context) => guarded(
          const EnterpriseProfilePage(),
          roles: ownerRoles,
        ),
        AppRoutes.adminDashboard: (context) => guarded(
          const AdminDashboardPage(),
          roles: const [UserRole.admin],
        ),
        AppRoutes.systemStats: (context) => guarded(
          const SystemStatsPage(),
          roles: ownerRoles,
        ),
        AppRoutes.adminSupport: (context) => guarded(
          const AdminSupportPage(),
          roles: ownerRoles,
        ),
        AppRoutes.machineList: (context) => guarded(
          const MachineListScreen(),
          roles: const [UserRole.farmer, UserRole.sme, UserRole.admin],
        ),
        AppRoutes.ownerDashboard: (context) => guarded(
          const OwnerDashboardScreen(),
          roles: ownerRoles,
        ),
        AppRoutes.ownerBookings: (context) => guarded(
          const OwnerBookingsScreen(),
          roles: ownerRoles,
        ),
        AppRoutes.ownerCalendar: (context) => guarded(
          const MachineCalendarScreen(),
          roles: ownerRoles,
        ),
        AppRoutes.ownerMachines: (context) => guarded(
          const OwnerMachineListScreen(),
          roles: ownerRoles,
        ),

        // Marketplace routes
        AppRoutes.marketplace: (context) => const ShopHomeScreen(),
        AppRoutes.marketplaceProductForm: (context) => const ProductFormScreen(),
        AppRoutes.marketplaceMyProducts: (context) => const MyProductsScreen(),
        AppRoutes.marketplaceCart: (context) => const CartScreen(),
        AppRoutes.marketplaceAdminDashboard:
            (context) => const marketplace.AdminDashboardScreen(),
        AppRoutes.marketplaceAllOrders: (context) => const MyOrdersScreen(buyerId: 0),

        AppRoutes.marketplaceMyOrders: (context) {
          final buyerId = ModalRoute.of(context)!.settings.arguments as int;
          return MyOrdersScreen(buyerId: buyerId);
        },

        AppRoutes.marketplaceProductDetail: (context) {
          final productId = ModalRoute.of(context)!.settings.arguments as int;
          return ProductDetailScreen(productId: productId);
        },

        AppRoutes.marketplaceOrderSuccess: (context) {
          final orderId = ModalRoute.of(context)!.settings.arguments as int;
          return OrderSuccessScreen(orderId: orderId);
        },
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.marketplaceOrderDetail) {
          final order = settings.arguments as OrderModel;
          return MaterialPageRoute(
            builder: (context) => OrderDetailScreen(order: order),
          );
        }

        if (settings.name == AppRoutes.marketplaceCheckout) {
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
