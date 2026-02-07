import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/task_controller.dart';
import '../../utils/app_colors.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/primary_button.dart';

class AddTaskView extends StatelessWidget {
  const AddTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find<TaskController>();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('New Task'),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'What needs to be done?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              controller: titleController,
              label: 'Task Title',
              icon: Icons.title,
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: descController,
              label: 'Description',
              icon: Icons.description_outlined,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 48),
            Obx(() => PrimaryButton(
                  text: 'CREATE TASK',
                  isLoading: taskController.isLoading.value,
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      taskController.addTask(
                        titleController.text,
                        descController.text,
                      );
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
