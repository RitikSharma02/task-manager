import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../tasks/add_task_dialog.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../tasks/task_list_view.dart';

class DashboardController extends GetxController {
  final RxInt tabIndex = 0.obs;

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}


class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final DashboardController dashboardController = Get.put(DashboardController());

    return Scaffold(
      extendBody: false,
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        backgroundColor: Colors.white,
         iconTheme: const IconThemeData(color: AppColors.primary),
         titleTextStyle: const TextStyle(
           color: AppColors.primary,
           fontWeight: FontWeight.bold,
           fontSize: 20
         ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Obx(() => IndexedStack(
        index: dashboardController.tabIndex.value,
        children: [
          TaskListView(),
          Container(
            color: Colors.white,
            child: Center(
              child: Icon(
                Icons.settings,
                size: 200,
                color: AppColors.textSecondary.withValues(alpha: 0.2),
              ),
            ),
          ), 
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.dialog(const AddTaskDialog());
        },
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        elevation: 10,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: dashboardController.tabIndex.value,
        onTap: dashboardController.changeTabIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      )),
    );
  }
}
