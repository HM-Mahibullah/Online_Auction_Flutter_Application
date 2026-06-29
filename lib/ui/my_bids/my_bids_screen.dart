import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/bid_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../utils/helpers.dart';
import '../../view_models/bid_view_model.dart';
import '../widgets/empty_state_widget.dart';

class MyBidsScreen extends StatelessWidget {
  const MyBidsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bidViewModel = Get.put(BidViewModel());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bids'),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 15,
            ),
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Won'),
              Tab(text: 'Lost'),
            ],
          ),
        ),
        body: Obx(() {
          final allBids = bidViewModel.myBids;
          final isLoading = bidViewModel.isLoading.value;
          final errorMsg = bidViewModel.errorMessage.value;

          if (errorMsg.isNotEmpty && allBids.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading bids',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      errorMsg,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => bidViewModel.refreshMyBids(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (isLoading && allBids.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (allBids.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.gavel_outlined,
              title: 'No Bids Yet',
              message: 'You haven\'t placed any bids yet.\nStart bidding on antiques!',
            );
          }

          return RefreshIndicator(
            onRefresh: () => bidViewModel.refreshMyBids(),
            child: TabBarView(
              children: [
              // Active Bids
              _buildBidsList(
                bids: allBids
                    .where((bid) =>
                        bid.status == BidStatus.winning ||
                        bid.status == BidStatus.pending ||
                        bid.status == BidStatus.outbid)
                    .toList(),
                emptyMessage: 'No active bids',
              ),
              // Won Bids
              _buildBidsList(
                bids: allBids
                    .where((bid) => bid.status == BidStatus.won)
                    .toList(),
                emptyMessage: 'No won auctions yet',
              ),
              // Lost Bids
              _buildBidsList(
                bids: allBids
                    .where((bid) => bid.status == BidStatus.lost)
                    .toList(),
                emptyMessage: 'No lost bids',
              ),
            ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBidsList({
    required List<BidModel> bids,
    required String emptyMessage,
  }) {
    if (bids.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.inbox_outlined,
        title: emptyMessage,
        message: '',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bids.length,
      itemBuilder: (context, index) {
        final bid = bids[index];
        return _BidCard(bid: bid);
      },
    );
  }
}

class _BidCard extends StatelessWidget {
  final BidModel bid;

  const _BidCard({required this.bid});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (bid.status) {
      case BidStatus.winning:
        statusColor = AppColors.winning;
        statusIcon = Icons.trending_up;
        break;
      case BidStatus.won:
        statusColor = AppColors.success;
        statusIcon = Icons.emoji_events;
        break;
      case BidStatus.outbid:
        statusColor = AppColors.outbid;
        statusIcon = Icons.trending_down;
        break;
      case BidStatus.lost:
        statusColor = AppColors.ended;
        statusIcon = Icons.cancel;
        break;
      case BidStatus.pending:
      default:
        statusColor = AppColors.info;
        statusIcon = Icons.hourglass_empty;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Get.toNamed(
            AppRoutes.antiqueDetail,
            arguments: bid.antiqueId,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: bid.antiqueImageUrl.isNotEmpty
                    ? bid.antiqueImageUrl.startsWith('assets/')
                        ? Image.asset(
                            bid.antiqueImageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            bid.antiqueImageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: AppColors.cardBackground,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: AppColors.textTertiary,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: AppColors.cardBackground,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: AppColors.textTertiary,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bid.antiqueName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your Bid: ${Helpers.formatCurrency(bid.bidAmount)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Helpers.getRelativeTime(bid.bidTime),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // Status
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bid.statusText,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
