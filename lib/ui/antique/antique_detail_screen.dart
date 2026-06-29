import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../utils/helpers.dart';
import '../../view_models/antique_view_model.dart';
import '../../view_models/bid_view_model.dart';
import '../widgets/loading_widget.dart';
import '../widgets/bid_history_timeline.dart';
import 'place_bid_sheet.dart';

class AntiqueDetailScreen extends StatefulWidget {
  const AntiqueDetailScreen({super.key});

  @override
  State<AntiqueDetailScreen> createState() => _AntiqueDetailScreenState();
}

class _AntiqueDetailScreenState extends State<AntiqueDetailScreen> {
  String _timeRemaining = '';
  late final AntiqueViewModel _antiqueViewModel;
  late final BidViewModel _bidViewModel;

  @override
  void initState() {
    super.initState();
    _antiqueViewModel = Get.find<AntiqueViewModel>();
    _bidViewModel = Get.find<BidViewModel>();
    
    final antiqueId = Get.arguments as String?;
    
    if (antiqueId == null || antiqueId.isEmpty) {
      debugPrint('ERROR: AntiqueDetailScreen - No antique ID provided');
      Future.microtask(() {
        Get.back();
        Get.snackbar('Error', 'Invalid antique ID', backgroundColor: Colors.red);
      });
      return;
    }

    // Stream antique data
    _antiqueViewModel.streamAntique(antiqueId);
    _bidViewModel.loadAntiqueBids(antiqueId);

    // Update time every second
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _antiqueViewModel.selectedAntique.value != null) {
        setState(() {
          _timeRemaining = Helpers.getTimeRemaining(
            _antiqueViewModel.selectedAntique.value!.bidEndTime,
          );
        });
        return true;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final antique = _antiqueViewModel.selectedAntique.value;

        if (antique == null) {
          return const LoadingWidget(message: 'Loading antique details...');
        }

        final isActive = Helpers.isAuctionActive(antique.bidEndTime);
        final isOwner = _antiqueViewModel.isAntiqueOwner(antique.curatorId);

        return CustomScrollView(
          slivers: [
            // App Bar with Image
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              actions: isOwner ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    debugPrint('Edit button pressed for antique: ${antique.id}');
                    Get.toNamed(
                      AppRoutes.editAntique,
                      arguments: antique,
                    );
                  },
                  tooltip: 'Edit Antique',
                ),
              ] : null,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    antique.imageUrl.isNotEmpty
                        ? antique.imageUrl.startsWith('assets/')
                            ? Image.asset(
                                antique.imageUrl,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                antique.imageUrl,
                                fit: BoxFit.cover,
                                frameBuilder:
                                    (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
                                  if (wasSynchronouslyLoaded) return child;
                                  if (frame == null) {
                                    return Container(
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
                                  debugPrint('Image load error for ${antique.imageUrl}: $error');
                                  return Container(
                                    color: AppColors.cardBackground,
                                    child: const Center(
                                      child: Icon(
                                        Icons.museum_outlined,
                                        size: 80,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  );
                                },
                              )
                        : Container(
                            color: AppColors.cardBackground,
                            child: const Center(
                              child: Icon(
                                Icons.museum_outlined,
                                size: 80,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.success : AppColors.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isActive ? 'ACTIVE AUCTION' : 'AUCTION ENDED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      antique.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Category
                    Text(
                      antique.category,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Current Bid Info
                    _buildInfoCard(
                      icon: Icons.gavel,
                      title: 'Current Bid',
                      value: antique.currentBid > 0
                          ? Helpers.formatCurrency(antique.currentBid)
                          : Helpers.formatCurrency(antique.basePrice),
                      subtitle: antique.currentBidderName ?? 'No bids yet',
                    ),
                    const SizedBox(height: 12),
                    // Time Remaining
                    _buildInfoCard(
                      icon: isActive ? Icons.timer : Icons.timer_off,
                      title: isActive ? 'Time Remaining' : 'Auction Ended',
                      value: _timeRemaining,
                      subtitle: Helpers.formatDateTime(antique.bidEndTime),
                      valueColor: isActive ? AppColors.error : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    // Total Bids
                    _buildInfoCard(
                      icon: Icons.people,
                      title: 'Total Bids',
                      value: '${antique.totalBids}',
                      subtitle: '${antique.totalBids} ${antique.totalBids == 1 ? 'bidder' : 'bidders'}',
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      antique.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Curator Info
                    const Text(
                      'Curated By',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          (antique.curatorName?.isNotEmpty == true ? antique.curatorName![0] : '?').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        antique.curatorName ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Listed on ${Helpers.formatDate(antique.createdAt)}',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Bid History Timeline
                    BidHistoryTimeline(antiqueId: antique.id),
                    
                    const SizedBox(height: 100), // Space for button
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      // Place Bid Button (only for non-owners)
      bottomNavigationBar: Obx(() {
        final antique = _antiqueViewModel.selectedAntique.value;
        if (antique == null) return const SizedBox.shrink();

        final isActive = Helpers.isAuctionActive(antique.bidEndTime);

        if (!isActive) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => PlaceBidSheet(antique: antique),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gavel),
                  SizedBox(width: 8),
                  Text(
                    'Place Your Bid',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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
    );
  }
}
