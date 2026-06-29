import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/notification_model.dart';
import '../../theme/app_colors.dart';
import '../../utils/helpers.dart';
import '../../view_models/notification_view_model.dart';
import '../widgets/empty_state_widget.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationViewModel = Get.put(NotificationViewModel());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Obx(() {
            final hasNotifications = notificationViewModel.notifications.isNotEmpty;
            if (!hasNotifications) return const SizedBox.shrink();

            return PopupMenuButton<String>(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.done_all, size: 20),
                      SizedBox(width: 12),
                      Text('Mark all as read'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Delete all', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'mark_all_read') {
                  notificationViewModel.markAllAsRead();
                } else if (value == 'delete_all') {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Delete All'),
                      content: const Text(
                        'Are you sure you want to delete all notifications?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            notificationViewModel.deleteAllNotifications();
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        final notifications = notificationViewModel.notifications;

        if (notifications.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.notifications_none_outlined,
            title: 'No Notifications',
            message: 'You\'re all caught up!\nWe\'ll notify you about auction updates.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _NotificationCard(
              notification: notification,
              viewModel: notificationViewModel,
            );
          },
        );
      }),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final NotificationViewModel viewModel;

  const _NotificationCard({
    required this.notification,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    IconData icon;

    switch (notification.type) {
      case NotificationType.auctionWon:
        iconColor = AppColors.success;
        icon = Icons.emoji_events;
        break;
      case NotificationType.outbid:
        iconColor = AppColors.warning;
        icon = Icons.trending_down;
        break;
      case NotificationType.auctionLost:
        iconColor = AppColors.error;
        icon = Icons.cancel;
        break;
      case NotificationType.auctionEndingSoon:
        iconColor = AppColors.info;
        icon = Icons.access_time;
        break;
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (direction) {
        viewModel.deleteNotification(notification.id);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: notification.read 
            ? Colors.white 
            : AppColors.primary.withOpacity(0.05),
        child: InkWell(
          onTap: () => viewModel.handleNotificationTap(notification),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification.read 
                                    ? FontWeight.normal 
                                    : FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (!notification.read)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Helpers.getRelativeTime(notification.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
