import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/antique_model.dart';
import '../../theme/app_colors.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';
import '../../view_models/bid_view_model.dart';
import '../widgets/custom_button.dart';
// ignore: unused_import
import '../widgets/custom_textfield.dart';

class PlaceBidSheet extends StatelessWidget {
  final AntiqueModel antique;

  const PlaceBidSheet({
    super.key,
    required this.antique,
  });

  @override
  Widget build(BuildContext context) {
    final bidViewModel = Get.find<BidViewModel>();
    final formKey = GlobalKey<FormState>();
    final minimumBid = antique.minimumNextBid;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  const Text(
                    'Place Your Bid',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    antique.title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 24),
                  // Current Bid Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Current Bid:',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              Helpers.formatCurrency(antique.currentBid),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Minimum Next Bid:',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              Helpers.formatCurrency(minimumBid + 1),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Bid Amount Field
                  TextFormField(
                    controller: bidViewModel.bidAmountController,
                    decoration: InputDecoration(
                      labelText: 'Your Bid Amount (Tk)',
                      hintText: 'Enter your bid amount',
                      prefixText: '৳ ',
                      prefixStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    autofocus: true,
                    validator: (value) => Validators.validateBidAmount(
                      value,
                      minimumBid,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Quick Bid Buttons
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildQuickBidChip(
                        context,
                        bidViewModel,
                        minimumBid + 5,
                      ),
                      _buildQuickBidChip(
                        context,
                        bidViewModel,
                        minimumBid + 10,
                      ),
                      _buildQuickBidChip(
                        context,
                        bidViewModel,
                        minimumBid + 20,
                      ),
                      _buildQuickBidChip(
                        context,
                        bidViewModel,
                        minimumBid + 50,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Place Bid Button
                  Obx(
                    () => CustomButton(
                      text: 'Place Bid',
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          bidViewModel.placeBid(antique.id, minimumBid);
                        }
                      },
                      isLoading: bidViewModel.isLoading.value,
                      icon: Icons.gavel,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Cancel Button
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickBidChip(
    BuildContext context,
    BidViewModel bidViewModel,
    double amount,
  ) {
    return ActionChip(
      label: Text('+${amount.toStringAsFixed(0)}'),
      onPressed: () {
        bidViewModel.bidAmountController.text = amount.toStringAsFixed(2);
      },
      backgroundColor: AppColors.primaryLight.withOpacity(0.2),
      labelStyle: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
