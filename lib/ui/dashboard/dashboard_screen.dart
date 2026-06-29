import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import 'package:flutter/foundation.dart';

import '../../view_models/auth_view_model.dart';
import '../../repository/user_repository.dart';
import '../../view_models/dashboard_view_model.dart';
import '../home/home_screen.dart';
import '../my_bids/my_bids_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends GetView<DashboardViewModel> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardViewModel = Get.put(DashboardViewModel());

    final screens = [
      const HomeScreen(),
      const MyBidsScreen(),
      const ProfileScreen(),
    ];

    return Obx(() => Scaffold(
          drawer: _buildDrawer(context),
          body: IndexedStack(
            index: dashboardViewModel.currentIndex.value,
            children: screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: dashboardViewModel.currentIndex.value,
            onTap: dashboardViewModel.changeTab,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textTertiary,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.gavel_outlined),
                activeIcon: Icon(Icons.gavel),
                label: 'My Bids',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outlined),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ));
  }

  Widget _buildDrawer(BuildContext context) {
    final authViewModel = Get.find<AuthViewModel>();
    
    return Drawer(
      child: Obx(() {
        final user = authViewModel.currentUser.value;
        
        return Column(
          children: [
            // Drawer Header
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 40,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              accountName: Text(
                user?.name ?? 'Guest',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(user?.email ?? ''),
              otherAccountsPictures: [
                if (user?.isAdmin ?? false)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(12),
                    ),

                  ),
              ],
            ),
            
            // Navigation Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.home_outlined),
                    title: const Text('Home'),
                    onTap: () {
                      Get.back();
                      controller.changeTab(0);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.gavel_outlined),
                    title: const Text('My Bids'),
                    onTap: () {
                      Get.back();
                      controller.changeTab(1);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_outlined),
                    title: const Text('Profile'),
                    onTap: () {
                      Get.back();
                      controller.changeTab(2);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Notifications'),
                    onTap: () {
                      Get.back();
                      Get.toNamed(AppRoutes.notifications);
                    },
                  ),
                  const Divider(),
                  
                  // // Quick Actions - Add Auction visible only for admins
                  // if (authViewModel.currentUser.value?.isAdmin ?? false)
                  //   ListTile(
                  //     leading: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                  //     title: const Text('Add Auction'),
                  //     onTap: () {
                  //       Get.back();
                  //       Get.toNamed(AppRoutes.addAntique);
                  //     },
                  //   ),

                  // Admin entry visible to everyone. If user is admin open admin panel,
                  // otherwise offer a debug-only enable action or show a not-authorized dialog.
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.primary),
                    title: const Text('Admin'),
                      subtitle: null,
                    onTap: () async {
                      final user = authViewModel.currentUser.value;
                      if (user == null) {
                        Get.snackbar('Error', 'No signed-in user');
                        return;
                      }

                      if (user.isAdmin) {
                        Get.back();
                        // Admin panel
                        Get.dialog(AlertDialog(
                          title: const Text('Admin Panel'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.inventory_2_outlined),
                                title: const Text('Manage Antiques'),
                                onTap: () {
                                  Get.back();
                                  Get.toNamed(AppRoutes.addAntique);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.analytics_outlined),
                                title: const Text('View Analytics'),
                                onTap: () {
                                  Get.back();
                                  Get.snackbar('Analytics', 'Open analytics on Home screen',
                                      backgroundColor: AppColors.info, colorText: Colors.white);
                                },
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Close'),
                            ),
                          ],
                        ));
                        return;
                      }

                      // Not admin: in debug builds allow toggling admin for testing
                      if (kDebugMode) {
                        final repo = UserRepository();
                        final newVal = !user.isAdmin;
                        try {
                          await repo.updateAdminStatus(user.id, newVal);
                          Get.snackbar('Success', 'isAdmin set to $newVal',
                              backgroundColor: Colors.green, colorText: Colors.white);
                        } catch (e) {
                          Get.snackbar('Error', 'Failed to update admin: $e',
                              backgroundColor: Colors.red, colorText: Colors.white);
                        }
                        return;
                      }

                      // Production: show not authorized message
                      Get.dialog(AlertDialog(
                        title: const Text('Not Authorized'),
                        content: const Text('You are not an admin.'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Close'),
                          ),
                        ],
                      ));
                    },
                  ),

                  // (Removed standalone Analytics drawer item)
                  
                  const Divider(),

                  // Settings & Info (combined, richer for users)
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Help & Info'),
                    subtitle: const Text('How bidding works & support'),
                    onTap: () {
                      Get.back();
                      Get.dialog(
                        AlertDialog(
                          title: const Text('Help & Info'),
                          content: const SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'How to bid:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text('• Browse antiques on Home screen'),
                                Text('• Open any antique to see full details'),
                                Text('• Tap "Place Bid" and enter your amount'),
                                Text('• Track your activity from the "My Bids" tab'),
                                SizedBox(height: 16),
                                Text(
                                  'Support:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text('📧 Email: support@antiqueauction.com'),
                                SizedBox(height: 4),
                                Text('📱 Phone: +92 300 1234567'),
                                SizedBox(height: 4),
                                Text('🕐 Hours: 9 AM - 6 PM (Mon-Fri)'),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Sign Out
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Get.back();
                Get.dialog(
                  AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          authViewModel.signOut();
                        },
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      }),
    );
  }
}
