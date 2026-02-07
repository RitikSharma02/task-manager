import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../views/auth/login_view.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.put(AuthService());
  
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final token = await _authService.getAccessToken();
    if (token != null) {
      isLoggedIn.value = true;
      Get.offAllNamed('/dashboard');
    } else {
      isLoggedIn.value = false;
      Get.offAllNamed('/login');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _authService.login(email, password);
      isLoggedIn.value = true;
      Get.offAllNamed('/dashboard'); // Navigate to dashboard
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String email, String password) async {
    try {
      isLoading.value = true;
      await _authService.register(email, password);
      Get.snackbar('Success', 'Registration successful. Please login.');
      Get.off(() => const LoginView());
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }
}
