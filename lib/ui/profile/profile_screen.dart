import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/profile_view_model.dart';
import '../widgets/loading_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Get.put(ProfileViewModel());
    final authViewModel = Get.find<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Obx(() {
        final user = profileViewModel.currentUser.value;

        if (user == null) {
          return const LoadingWidget(message: 'Loading profile...');
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Name
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Email
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    if (user.isAdmin) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),

                      ),
                    ],
                  ],
                ),
              ),
              // Stats
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.gavel,
                        label: 'Total Bids',
                        value: user.totalBids.toString(),
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.emoji_events,
                        label: 'Won Auctions',
                        value: user.wonAuctions.toString(),
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Account Info
              _buildSectionTitle('Account Information'),
              _buildInfoTile(
                icon: Icons.person,
                title: 'Full Name',
                subtitle: user.name,
              ),
              _buildInfoTile(
                icon: Icons.email,
                title: 'Email',
                subtitle: user.email,
              ),
              if (user.phoneNumber != null)
                _buildInfoTile(
                  icon: Icons.phone,
                  title: 'Phone Number',
                  subtitle: user.phoneNumber!,
                ),
              _buildInfoTile(
                icon: Icons.calendar_today,
                title: 'Member Since',
                subtitle: _formatDate(user.createdAt),
              ),
              const SizedBox(height: 16),
              // Actions
              _buildSectionTitle('Actions'),
              ListTile(
                leading: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Get.toNamed(AppRoutes.changePassword);
                },
              ),
              ListTile(
                leading: const Icon(Icons.verified_user_outlined, color: AppColors.textSecondary),
                title: const Text('Email Verification'),
                trailing: authViewModel.currentUser.value?.email != null
                    ? Icon(
                        authViewModel.isEmailVerified.value
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: authViewModel.isEmailVerified.value
                            ? AppColors.success
                            : AppColors.warning,
                      )
                    : null,
                onTap: () {
                  if (!authViewModel.isEmailVerified.value) {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Email Verification'),
                        content: const Text(
                          'Your email is not verified. Would you like to send a verification email?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back();
                              authViewModel.sendEmailVerification();
                            },
                            child: const Text('Send'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    Get.snackbar(
                      'Verified',
                      'Your email is already verified',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: AppColors.textSecondary),
                title: const Text('Settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Get.snackbar(
                    'Coming Soon',
                    'Settings feature will be available soon',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline, color: AppColors.textSecondary),
                title: const Text('Help & Support'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Get.snackbar(
                    'Coming Soon',
                    'Help & Support feature will be available soon',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: AppColors.textSecondary),
                title: const Text('About'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
              const Divider(),
              // Logout
              Obx(() => ListTile(
                    leading: profileViewModel.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout, color: AppColors.error),
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: AppColors.error),
                    ),
                    onTap: profileViewModel.isLoading.value
                        ? null
                        : () {
                            _showLogoutDialog(context, authViewModel);
                          },
                  )),
              // (Removed dev-only admin toggle)
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showLogoutDialog(BuildContext context, AuthViewModel authViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authViewModel.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Antique Auction'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text(
              'Antique Auction is a platform for buying and selling rare antiques through live bidding.',
            ),
            SizedBox(height: 8),
            Text('© 2026 Antique Auction. All rights reserved.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
