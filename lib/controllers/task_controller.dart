import 'package:get/get.dart';
import '../services/task_service.dart';
import '../models/task_model.dart';

class TaskController extends GetxController {
  final TaskService _taskService = Get.put(TaskService());
  
  final RxList<Task> tasks = <Task>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  Future<void> fetchTasks({bool isRefresh = false}) async {
    try {
      if (!isRefresh) isLoading.value = true;
      tasks.value = await _taskService.getTasks();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch tasks: $e');
    } finally {
      if (!isRefresh) isLoading.value = false;
    }
  }

  Future<bool> addTask(String title, String description) async {
    try {
      isLoading.value = true;
      final newTask = await _taskService.createTask(title, description);
      tasks.add(newTask);
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _taskService.deleteTask(id);
      tasks.removeWhere((t) => t.id == id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete task');
    }
  }

  Future<void> toggleTaskStatus(String id) async {
    try {
      final updatedTask = await _taskService.toggleStatus(id);
      final index = tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        tasks[index] = updatedTask;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status');
    }
  }
}
