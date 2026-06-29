import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ErrorHandler {
  // Check internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Handle Firebase exceptions with user-friendly messages
  static String handleFirebaseError(dynamic error) {
    final errorMessage = error.toString().toLowerCase();

    if (errorMessage.contains('network')) {
      return 'No internet connection. Please check your network and try again.';
    } else if (errorMessage.contains('permission-denied')) {
      return 'You don\'t have permission to perform this action.';
    } else if (errorMessage.contains('not-found')) {
      return 'The requested item was not found.';
    } else if (errorMessage.contains('already-exists')) {
      return 'This item already exists.';
    } else if (errorMessage.contains('deadline-exceeded') || 
               errorMessage.contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else if (errorMessage.contains('unavailable')) {
      return 'Service temporarily unavailable. Please try again later.';
    } else if (errorMessage.contains('cancelled')) {
      return 'Operation was cancelled.';
    } else if (errorMessage.contains('invalid-argument')) {
      return 'Invalid data provided. Please check your input.';
    } else if (errorMessage.contains('failed-precondition')) {
      return 'Operation failed. Please refresh and try again.';
    } else if (errorMessage.contains('aborted')) {
      return 'Operation aborted due to conflict. Please try again.';
    } else if (errorMessage.contains('out-of-range')) {
      return 'Value out of acceptable range.';
    } else if (errorMessage.contains('unauthenticated')) {
      return 'Please log in to continue.';
    } else if (errorMessage.contains('resource-exhausted')) {
      return 'Too many requests. Please wait a moment and try again.';
    } else if (errorMessage.contains('data-loss')) {
      return 'Data corruption detected. Please contact support.';
    } else if (errorMessage.contains('unknown')) {
      return 'An unexpected error occurred. Please try again.';
    } else if (errorMessage.contains('internal')) {
      return 'Server error. Please try again later.';
    } else if (errorMessage.contains('email-already-in-use')) {
      return 'This email is already registered.';
    } else if (errorMessage.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters.';
    } else if (errorMessage.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (errorMessage.contains('user-not-found')) {
      return 'No account found with this email.';
    } else if (errorMessage.contains('user-disabled')) {
      return 'This account has been disabled.';
    } else if (errorMessage.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    } else if (errorMessage.contains('operation-not-allowed')) {
      return 'This operation is not allowed.';
    }

    // Default message
    return 'Something went wrong. Please try again.';
  }

  // Show error snackbar with retry option
  static void showErrorWithRetry({
    required String message,
    required VoidCallback onRetry,
    Duration duration = const Duration(seconds: 5),
  }) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: duration,
      mainButton: TextButton(
        onPressed: () {
          Get.closeCurrentSnackbar();
          onRetry();
        },
        child: const Text(
          'RETRY',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  // Show success message
  static void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  // Show info message
  static void showInfo(String message) {
    Get.snackbar(
      'Info',
      message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  // Show offline warning
  static void showOfflineWarning() {
    Get.snackbar(
      'Offline',
      'No internet connection. Some features may not work.',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.wifi_off, color: Colors.white),
    );
  }

  // Log error for debugging (can be extended with Firebase Crashlytics)
  static void logError(String context, dynamic error, [StackTrace? stackTrace]) {
    debugPrint('❌ ERROR in $context: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
    // TODO: Add Firebase Crashlytics logging here
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}

// Connectivity Monitor
class ConnectivityMonitor extends GetxController {
  final _connectivity = Connectivity();
  final isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus as void Function(List<ConnectivityResult> event)?);
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result as ConnectivityResult);
    } catch (e) {
      ErrorHandler.logError('ConnectivityMonitor', e);
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) async {
    final wasOnline = isOnline.value;
    
    if (result == ConnectivityResult.none) {
      isOnline.value = false;
      if (wasOnline) {
        ErrorHandler.showOfflineWarning();
      }
    } else {
      // Double check with actual internet access
      final hasInternet = await ErrorHandler.hasInternetConnection();
      isOnline.value = hasInternet;
      
      if (!wasOnline && hasInternet) {
        ErrorHandler.showSuccess('Back online!');
      }
    }
  }
}
