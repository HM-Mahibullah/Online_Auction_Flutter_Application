import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/user_model.dart';
import '../repository/auth_repository.dart';
import '../routes/app_routes.dart';

class AuthViewModel extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // Observable state
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final currentUser = Rx<UserModel?>(null);
  final isEmailVerified = false.obs;
  final canAddAntiques = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
  }

  // Check authentication state
  void _checkAuthState() {
    _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        _loadUserData();
      } else {
        currentUser.value = null;
      }
    });
  }

  // Load user data
  Future<void> _loadUserData() async {
    try {
      final userData = await _authRepository.getCurrentUserData();
      currentUser.value = userData;
      // Update email verification status
      _updateEmailVerificationStatus();
      // All authenticated users can add antiques
      canAddAntiques.value = userData != null;
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // Update email verification status
  void _updateEmailVerificationStatus() {
    final user = _authRepository.currentUser;
    if (user != null) {
      isEmailVerified.value = user.emailVerified;
    }
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Sign up
  Future<void> signUp() async {
    try {
      isLoading.value = true;

      // Validate inputs
      final email = emailController.text.trim();
      final password = passwordController.text;
      final name = nameController.text.trim();

      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        Get.snackbar(
          'Error',
          'Email, password, and name are required',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      if (password.length < 6) {
        Get.snackbar(
          'Error',
          'Password must be at least 6 characters',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      await _authRepository.signUp(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneController.text.trim().isEmpty
            ? null
            : phoneController.text.trim(),
      );

      // Sign out after signup to require manual login
      await _authRepository.signOut();
      
      Get.snackbar(
        'Success',
        'Account created successfully! Please login with your credentials.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Clear form and navigate to login screen
      clearForm();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      // Provide more user-friendly error messages
      if (errorMessage.contains('email-already-in-use')) {
        errorMessage = 'This email is already registered. Please try another or log in.';
      } else if (errorMessage.contains('weak-password')) {
        errorMessage = 'Password is too weak. Use at least 8 characters with numbers and letters.';
      } else if (errorMessage.contains('invalid-email')) {
        errorMessage = 'The email address format is invalid.';
      }

      Get.snackbar(
        'Sign Up Failed',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      debugPrint('Sign up error: $e');
    } finally {
      isLoading.value = false;
    }
  }


  // Sign in
  Future<void> signIn() async {
    try {
      isLoading.value = true;

      // Validate inputs
      final email = emailController.text.trim();
      final password = passwordController.text;

      if (email.isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter your email address',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      if (password.isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter your password',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );

      currentUser.value = user;
      
      Get.snackbar(
        'Success',
        'Welcome back, ${user.name}!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Clear form before navigation
      clearForm();
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      // Provide more user-friendly error messages
      if (errorMessage.contains('user-not-found')) {
        errorMessage = 'No account found with this email. Please sign up first.';
      } else if (errorMessage.contains('wrong-password') || errorMessage.contains('incorrect')) {
        errorMessage = 'Email or password is incorrect. Please try again.';
      } else if (errorMessage.contains('too-many-requests')) {
        errorMessage = 'Too many login attempts. Please try again later.';
      } else if (errorMessage.contains('user-disabled')) {
        errorMessage = 'This account has been disabled. Please contact support.';
      }

      Get.snackbar(
        'Sign In Failed',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      debugPrint('Sign in error: $e');
    } finally {
      isLoading.value = false;
    }
  }


  // Sign out
  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      currentUser.value = null;
      
      Get.snackbar(
        'Success',
        'Signed out successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail() async {
    try {
      if (emailController.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter your email address',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;

      await _authRepository.sendPasswordResetEmail(
        emailController.text.trim(),
      );

      Get.snackbar(
        'Success',
        'Password reset email sent!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      isLoading.value = true;

      // Re-authenticate first
      await _authRepository.signIn(
        email: currentUser.value!.email,
        password: currentPassword,
      );

      await _authRepository.changePassword(newPassword);

      Get.snackbar(
        'Success',
        'Password changed successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      isLoading.value = true;

      await _authRepository.sendEmailVerification();

      Get.snackbar(
        'Success',
        'Verification email sent! Please check your inbox.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Check email verification status
  Future<void> checkEmailVerification() async {
    try {
      await _authRepository.reloadUser();
      _updateEmailVerificationStatus();
      await _loadUserData();
      
      if (isEmailVerified.value) {
        Get.snackbar(
          'Verified!',
          'Your email has been verified successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error checking email verification: $e');
    }
  }

  // Clear form
  void clearForm() {
    try {
      emailController.clear();
      passwordController.clear();
      nameController.clear();
      phoneController.clear();
    } catch (e) {
      // Controllers may be disposed, ignore
    }
  }
}
