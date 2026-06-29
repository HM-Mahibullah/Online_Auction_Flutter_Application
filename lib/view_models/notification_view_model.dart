import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/notification_model.dart';
import '../data/services/notification_service.dart';
import '../repository/auth_repository.dart';
import '../routes/app_routes.dart';

class NotificationViewModel extends GetxController {
  final NotificationService _notificationService = NotificationService();
  final AuthRepository _authRepository = AuthRepository();

  final notifications = <NotificationModel>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  void loadNotifications() {
    final userId = _authRepository.currentUserId;
    if (userId != null) {
      // Stream notifications
      _notificationService.streamUserNotifications(userId).listen((data) {
        notifications.value = data;
      });

      // Stream unread count
      _notificationService.streamUnreadCount(userId).listen((count) {
        unreadCount.value = count;
      });
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark notification as read',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> markAllAsRead() async {
    final userId = _authRepository.currentUserId;
    if (userId != null) {
      try {
        isLoading.value = true;
        await _notificationService.markAllAsRead(userId);
        Get.snackbar(
          'Success',
          'All notifications marked as read',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to mark all as read',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete notification',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteAllNotifications() async {
    final userId = _authRepository.currentUserId;
    if (userId != null) {
      try {
        isLoading.value = true;
        await _notificationService.deleteAllNotifications(userId);
        Get.snackbar(
          'Success',
          'All notifications deleted',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete notifications',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  void handleNotificationTap(NotificationModel notification) {
    // Mark as read
    if (!notification.read) {
      markAsRead(notification.id);
    }

    // Navigate to antique detail
    Get.toNamed(
      AppRoutes.antiqueDetail,
      arguments: notification.antiqueId,
    );
  }
}
