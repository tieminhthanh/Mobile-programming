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
        appBarTheme: AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: onSurface),
          titleTextStyle: GoogleFonts.beVietnamPro(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          labelStyle: const TextStyle(color: Color(0xFF25563E), fontWeight: FontWeight.w600),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.home: (context) => AuthGuard(
              loginRoute: AppRoutes.login,
              deniedRoute: AppRoutes.home,
              allowedRoles: [UserRole.farmer, UserRole.sme, UserRole.admin],
              child: const HomePage(),
            ),
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.register: (context) => const RegisterPage(),
        AppRoutes.logout: (context) => AuthGuard(
              loginRoute: AppRoutes.login,
              deniedRoute: AppRoutes.home,
              child: const LogoutPage(),
            ),
        AppRoutes.changePassword: (context) => AuthGuard(
              loginRoute: AppRoutes.login,
              deniedRoute: AppRoutes.home,
              child: const ChangePasswordPage(),
            ),
        AppRoutes.profile: (context) => AuthGuard(
              loginRoute: AppRoutes.login,
              deniedRoute: AppRoutes.home,
              child: const ProfilePage(),
            ),
        AppRoutes.userList: (context) => AuthGuard(
              loginRoute: AppRoutes.login,
              deniedRoute: AppRoutes.home,
              allowedRoles: [UserRole.admin],
              child: const UserListPage(),
            ),
        AppRoutes.userLock: (context) => AuthGuard(
              loginRoute: AppRoutes.login,
              deniedRoute: AppRoutes.home,
              allowedRoles: [UserRole.admin],
              child: const UserLockPage(),
            ),
        AppRoutes.addressList: (context) => AuthGuard(
              loginRoute: AppRoutes.login,
              deniedRoute: AppRoutes.home,
              child: const AddressListPage(),
            ),
        AppRoutes.addressEdit: (context) => AuthGuard(
              loginRoute: AppRoutes.login,
              deniedRoute: AppRoutes.addressList,
              child: const AddressEditPage(),
            ),
        AppRoutes.enterpriseProfile: (context) => AuthGuard(
              loginRoute: AppRoutes.login,
              deniedRoute: AppRoutes.home,
              allowedRoles: [UserRole.admin, UserRole.sme],
              child: const EnterpriseProfilePage(),
            ),
        AppRoutes.adminDashboard: (context) => AuthGuard(
              loginRoute: AppRoutes.login,
              deniedRoute: AppRoutes.home,
              allowedRoles: [UserRole.admin, UserRole.sme],
              child: const AdminDashboardPage(),
            ),
        AppRoutes.systemStats: (context) => AuthGuard(
              loginRoute: AppRoutes.login,
              deniedRoute: AppRoutes.home,
              allowedRoles: [UserRole.admin, UserRole.sme],
              child: const SystemStatsPage(),
            ),
        AppRoutes.adminSupport: (context) => AuthGuard(
              loginRoute: AppRoutes.login,
              deniedRoute: AppRoutes.home,
              allowedRoles: [UserRole.admin, UserRole.sme],
              child: const AdminSupportPage(),
            ),
        '/machine-list': (context) => AuthGuard(
              loginRoute: AppRoutes.login,
              deniedRoute: AppRoutes.home,
              allowedRoles: [UserRole.farmer, UserRole.sme, UserRole.admin],
              child: const MachineListScreen(),
            ),
        '/owner-dashboard': (context) => AuthGuard(
              loginRoute: AppRoutes.login,
              deniedRoute: AppRoutes.home,
              allowedRoles: [UserRole.sme, UserRole.admin],
              child: const OwnerDashboardScreen(),
            ),
        '/owner-bookings': (context) => AuthGuard(
              loginRoute: AppRoutes.login,
              deniedRoute: AppRoutes.home,
              allowedRoles: [UserRole.sme, UserRole.admin],
              child: const OwnerBookingsScreen(),
            ),
        '/owner-calendar': (context) => AuthGuard(
              loginRoute: AppRoutes.login,
              deniedRoute: AppRoutes.home,
              allowedRoles: [UserRole.sme, UserRole.admin],
              child: const MachineCalendarScreen(),
            ),
        '/owner-machines': (context) => AuthGuard(
              loginRoute: AppRoutes.login,
              deniedRoute: AppRoutes.home,
              allowedRoles: [UserRole.sme, UserRole.admin],
              child: const OwnerMachineListScreen(),
            ),
      },
    );
  }
}
