import 'package:flutter/material.dart';

// --- SAU NÀY BẠN SẼ IMPORT CÁC MÀN HÌNH TỪ THƯ MỤC SCREENS VÀO ĐÂY ---
// import 'package:guardian/screens/machine/machine_list_screen.dart';

class GuardianApp extends StatelessWidget {
  // Xóa AdminRepository ở đây đi, UI không nên ôm Data.
  const GuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian Farm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F5C45)),
        // Màu xanh rêu điểm nhấn chuẩn
        useMaterial3: true,
      ),
      // Tạm thời để home là một màn hình rỗng chờ các bạn code UI
      home: const Scaffold(
        body: Center(
          child: Text(
            'Hệ thống Thần Hộ Mệnh\nĐang xây dựng...',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),

      // Khai báo Routes chuẩn (Mở comment khi đã có màn hình)
      /*
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomePage(),
        '/machine-list': (context) => const MachineListScreen(),
        // ... các route khác
      },
      */
    );
  }
}
