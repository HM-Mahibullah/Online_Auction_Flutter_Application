import 'package:get/get.dart';
import '../view_models/auth_view_model.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthViewModel>(AuthViewModel(), permanent: true);
  }
}
