import 'package:get/get.dart';
import '../data/models/user_model.dart';
import '../repository/auth_repository.dart';

class ProfileViewModel extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  // Observable state
  final isLoading = false.obs;
  final currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  // Load user profile
  void loadUserProfile() {
    _authRepository.streamCurrentUserData().listen((user) {
      currentUser.value = user;
    });
  }

  // Sign out
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authRepository.signOut();
    } finally {
      isLoading.value = false;
    }
  }
}
