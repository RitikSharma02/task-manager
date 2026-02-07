import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../controllers/task_controller.dart';
import '../../widgets/task_card.dart';
import '../../utils/app_colors.dart';

class TaskListView extends StatelessWidget {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.put(TaskController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (taskController.isLoading.value && taskController.tasks.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        return RefreshIndicator(
          onRefresh: () => taskController.fetchTasks(isRefresh: true),
          color: AppColors.primary,
          child: taskController.tasks.isEmpty
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7, // Ensure draggable area
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_outlined, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text('No tasks yet', style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5))),
                        ],
                      ),
                    ),
                  ),
                )
              : AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 80),
                    itemCount: taskController.tasks.length,
                    itemBuilder: (context, index) {
                      final task = taskController.tasks[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: TaskCard(
                              task: task,
                              onToggle: () => taskController.toggleTaskStatus(task.id),
                              onDelete: () => taskController.deleteTask(task.id),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        );
      }),
    );
  }
}
