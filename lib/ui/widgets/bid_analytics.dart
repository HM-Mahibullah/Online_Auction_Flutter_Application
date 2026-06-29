import 'package:flutter/material.dart';
import '../../data/models/antique_model.dart';
import '../../theme/app_colors.dart';
import '../../utils/helpers.dart';

class BidAnalytics extends StatelessWidget {
  final List<AntiqueModel> antiques;
  
  const BidAnalytics({
    super.key,
    required this.antiques,
  });

  @override
  Widget build(BuildContext context) {
    if (antiques.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalAuctions = antiques.length;
    final totalBids = antiques.fold<int>(0, (sum, item) => sum + item.totalBids);
    final highestBid = antiques.fold<double>(
      0,
      (max, item) => item.currentBid > max ? item.currentBid : max,
    );
    final avgBidsPerAuction = totalBids / totalAuctions;
    
    // Calculate active auctions
    final activeAuctions = antiques.where(
      (a) => Helpers.isAuctionActive(a.bidEndTime),
    ).length;

    // Find hot auction (most bids)
    final hotAuction = antiques.reduce(
      (a, b) => a.totalBids > b.totalBids ? a : b,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Live Bid Analytics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _buildStatCard(
                icon: Icons.gavel,
                label: 'Total Bids',
                value: totalBids.toString(),
                color: AppColors.primary,
              ),
              _buildStatCard(
                icon: Icons.trending_up,
                label: 'Highest Bid',
                value: Helpers.formatCurrency(highestBid),
                color: AppColors.success,
              ),
              _buildStatCard(
                icon: Icons.museum_outlined,
                label: 'Active Auctions',
                value: '$activeAuctions/$totalAuctions',
                color: AppColors.warning,
              ),
              _buildStatCard(
                icon: Icons.show_chart,
                label: 'Avg Bids',
                value: avgBidsPerAuction.toStringAsFixed(1),
                color: AppColors.info,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Hot Auction Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🔥 HOT AUCTION',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hotAuction.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${hotAuction.totalBids} active bids',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
