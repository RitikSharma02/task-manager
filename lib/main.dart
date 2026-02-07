import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'views/auth/login_view.dart';
import 'views/dashboard/dashboard_view.dart';

void main() {
  runApp(const MyApp());
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject AuthController globally
    Get.put(AuthController());

    return GetMaterialApp(
      
      title: 'Flutter Task App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // initialRoute: '/login', // Removed to let AuthController handle navigation or use home
      home: const Scaffold(body: Center(child: CircularProgressIndicator())), // Simple Splash
      getPages: [
        GetPage(name: '/login', page: () => const LoginView()),
        GetPage(name: '/dashboard', page: () => const DashboardView()),
      ],
    );
  }
}
