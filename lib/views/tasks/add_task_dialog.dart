import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/task_controller.dart';
import '../../utils/app_colors.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/primary_button.dart';

class AddTaskDialog extends StatelessWidget {
  const AddTaskDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find<TaskController>();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'New Task',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: titleController,
              label: 'Task Title',
              icon: Icons.title,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: descController,
              label: 'Description',
              icon: Icons.description_outlined,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 24),
            Obx(() => PrimaryButton(
                  text: 'CREATE TASK',
                  isLoading: taskController.isLoading.value,
                  onPressed: () async {
                    if (titleController.text.isNotEmpty) {
                      final success = await taskController.addTask(
                        titleController.text,
                        descController.text,
                      );
                      if (success) {
                        Get.back();
                        Get.snackbar('Success', 'Task added', 
                          backgroundColor: AppColors.success, colorText: Colors.white);
                      } else {
                        Get.snackbar('Error', 'Failed to add task',
                          backgroundColor: AppColors.error, colorText: Colors.white);
                      }
                    } else {
                      Get.snackbar(
                        'Required',
                        'Please enter a title',
                        backgroundColor: AppColors.error,
                        colorText: Colors.white,
                      );
                    }
                  },
                )),
          ],
        ),
      ),
    );
  }
}
