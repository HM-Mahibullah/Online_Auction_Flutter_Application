import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/antique_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../utils/helpers.dart';
import '../../view_models/antique_view_model.dart';

class AntiqueCard extends StatefulWidget {
  final AntiqueModel antique;

  const AntiqueCard({
    super.key,
    required this.antique,
  });

  @override
  State<AntiqueCard> createState() => _AntiqueCardState();
}

class _AntiqueCardState extends State<AntiqueCard> {
  String _timeRemaining = '';

  @override
  void initState() {
    super.initState();
    _updateTimeRemaining();
    // Update time every second
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        _updateTimeRemaining();
        return true;
      }
      return false;
    });
  }

  void _updateTimeRemaining() {
    if (mounted) {
      setState(() {
        _timeRemaining = Helpers.getTimeRemaining(widget.antique.bidEndTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final antique = widget.antique;
    final isActive = Helpers.isAuctionActive(antique.bidEndTime);
    final antiqueViewModel = Get.find<AntiqueViewModel>();
    final isOwner = antiqueViewModel.isAntiqueOwner(antique.curatorId);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          debugPrint('Tapped antique: ${antique.id} - ${antique.title}');
          if (antique.id.isEmpty) {
            Get.snackbar('Error', 'Invalid antique ID', backgroundColor: Colors.red);
            return;
          }
          Get.toNamed(
            AppRoutes.antiqueDetail,
            arguments: antique.id,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  antique.imageUrl.isNotEmpty
                      ? antique.imageUrl.startsWith('assets/')
                          ? Image.asset(
                              antique.imageUrl,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('Image error for ${antique.imageUrl}: $error');
                                return Container(
                                  height: 200,
                                  color: AppColors.cardBackground,
                                  child: const Center(
                                    child: Icon(
                                      Icons.museum_outlined,
                                      size: 60,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Image.network(
                              antique.imageUrl,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
                                if (wasSynchronouslyLoaded) return child;
                                if (frame == null) {
                                  return Container(
                                    height: 200,
                                    color: AppColors.cardBackground,
                                    child: const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                                  );
                                }
                                return child;
                              },
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('Image error for ${antique.imageUrl}: $error');
                                return Container(
                                  height: 200,
                                  color: AppColors.cardBackground,
                                  child: const Center(
                                    child: Icon(
                                      Icons.museum_outlined,
                                      size: 60,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                );
                              },
                            )
                      : Container(
                          height: 200,
                          color: AppColors.cardBackground,
                          child: const Center(
                            child: Icon(
                              Icons.museum_outlined,
                              size: 60,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                  // Status Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.success : AppColors.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isActive ? 'ACTIVE' : 'ENDED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Edit Button (Admin/Owner)
                  if (isOwner)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: PopupMenuButton<String>(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            Get.toNamed(
                              AppRoutes.editAntique,
                              arguments: antique,
                            );
                          } else if (value == 'delete') {
                            _confirmDelete(context, antique);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    antique.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      antique.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Current Bid
                  Row(
                    children: [
                      const Icon(
                        Icons.gavel,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Current Bid: ',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        antique.currentBid > 0
                            ? Helpers.formatCurrency(antique.currentBid)
                            : Helpers.formatCurrency(antique.basePrice),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Time Remaining
                  Row(
                    children: [
                      Icon(
                        isActive ? Icons.timer : Icons.timer_off,
                        size: 20,
                        color: isActive ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isActive ? 'Ends in: ' : 'Auction Ended',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (isActive)
                        Text(
                          _timeRemaining,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Total Bids
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 20,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${antique.totalBids} ${antique.totalBids == 1 ? 'bid' : 'bids'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AntiqueModel antique) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Auction'),
        content: Text(
          'Are you sure you want to delete "${antique.title}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final antiqueViewModel = Get.find<AntiqueViewModel>();
              try {
                antiqueViewModel.isLoading.value = true;
                await antiqueViewModel.deleteAntique(antique.id);
                Get.snackbar(
                  'Success',
                  'Auction deleted successfully!',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to delete auction: ${e.toString()}',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              } finally {
                antiqueViewModel.isLoading.value = false;
              }
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
}
