import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../view_models/antique_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/dashboard_view_model.dart';
import '../widgets/empty_state_widget.dart';
// ignore: unused_import
import '../widgets/loading_widget.dart';
import '../widgets/featured_carousel.dart';
import '../widgets/bid_analytics.dart';
import '../widgets/category_filter.dart';
import 'antique_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final antiqueViewModel = Get.put(AntiqueViewModel());
    final authViewModel = Get.find<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Antique Auction'),
        actions: [
          // User Info Menu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Obx(() {
              final user = authViewModel.currentUser.value;
              if (user != null) {
                return PopupMenuButton<String>(
                  offset: const Offset(0, 50),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (user.isAdmin) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                        
                            ),
                          ],
                          const Divider(height: 16),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person_outline, size: 20),
                          SizedBox(width: 12),
                          Text('My Profile'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'bids',
                      child: Row(
                        children: [
                          Icon(Icons.gavel_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('My Bids'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text(
                            'Sign Out',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'profile':
                        Get.find<DashboardViewModel>().changeTab(2);
                        break;
                      case 'bids':
                        Get.find<DashboardViewModel>().changeTab(1);
                        break;
                      case 'logout':
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Sign Out'),
                            content: const Text(
                              'Are you sure you want to sign out?',
                            ),
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
                        break;
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ),
        ],
      ),
      body: Obx(() {
        final antiques = antiqueViewModel.activeAntiques;

        if (antiques.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.museum_outlined,
            title: 'No Active Auctions',
            message: 'There are no active auctions at the moment.\nCheck back later!',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            antiqueViewModel.loadAntiques();
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // Featured Carousel
              FeaturedCarousel(antiques: antiques),
              
              // Analytics
              BidAnalytics(antiques: antiques),
              
              const SizedBox(height: 16),
              
              // Section Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.list_alt,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Browse Auctions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Category Filter
              Obx(() {
                return CategoryFilter(
                  categories: antiqueViewModel.categories,
                  selectedCategory: antiqueViewModel.selectedCategory.value,
                  onCategorySelected: antiqueViewModel.selectCategory,
                );
              }),
              
              const SizedBox(height: 8),
              
              // Filtered Antiques List
              Obx(() {
                final displayAntiques = antiqueViewModel.filteredAntiques;
                
                if (displayAntiques.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No antiques in this category',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }
                
                return Column(
                  children: displayAntiques.map((antique) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AntiqueCard(antique: antique),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        );
      }),
      // Floating Action Button for Admin
      floatingActionButton: Obx(() {
        if (antiqueViewModel.canAddAntiques.value) {
          // return FloatingActionButton.extended(
          //   onPressed: () {
          //     Get.toNamed(AppRoutes.addAntique);
          //   },
          //   icon: const Icon(Icons.add),
          //   label: const Text('Add Auction'),
          //   tooltip: 'Add New Antique',
          // );
        }
        return const SizedBox.shrink();
      }),
    );
  }
}
