// ignore: unused_import
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/antique_model.dart';
import '../../theme/app_colors.dart';
import '../../utils/helpers.dart';
import '../../view_models/antique_view_model.dart';

class EditAntiqueScreen extends StatefulWidget {
  const EditAntiqueScreen({super.key});

  @override
  State<EditAntiqueScreen> createState() => _EditAntiqueScreenState();
}

class _EditAntiqueScreenState extends State<EditAntiqueScreen> {
  final antiqueViewModel = Get.find<AntiqueViewModel>();
  late AntiqueModel antique;
  
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController basePriceController;
  late TextEditingController categoryController;

  @override
  void initState() {
    super.initState();
    antique = Get.arguments as AntiqueModel;
    
    titleController = TextEditingController(text: antique.title);
    descriptionController = TextEditingController(text: antique.description);
    basePriceController = TextEditingController(text: antique.basePrice.toString());
    categoryController = TextEditingController(text: antique.category);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    basePriceController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  Future<void> _updateAntique() async {
    if (!_validateForm()) return;

    try {
      antiqueViewModel.isLoading.value = true;

      await antiqueViewModel.updateAntiqueDetails(
        antiqueId: antique.id,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        basePrice: double.parse(basePriceController.text),
        category: categoryController.text.trim(),
      );

      Get.back();
      Get.snackbar(
        'Success',
        'Antique updated successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update antique: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      antiqueViewModel.isLoading.value = false;
    }
  }

  bool _validateForm() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a title');
      return false;
    }
    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a description');
      return false;
    }
    if (basePriceController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a base price');
      return false;
    }
    final price = double.tryParse(basePriceController.text);
    if (price == null || price <= 0) {
      Get.snackbar('Error', 'Please enter a valid price');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Antique'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmDelete,
            tooltip: 'Delete Antique',
          ),
        ],
      ),
      body: Obx(() {
        if (antiqueViewModel.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Preview
              if (antique.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: antique.imageUrl.startsWith('assets/')
                      ? Image.asset(
                          antique.imageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          antique.imageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter antique title',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter antique description',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              // Base Price
              TextFormField(
                controller: basePriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Base Price',
                  hintText: 'Enter starting price',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category
              TextFormField(
                controller: categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
                  hintText: 'Enter category',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Auction Info (Read-only)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Auction Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Current Bid', Helpers.formatCurrency(antique.currentBid)),
                    _buildInfoRow('Total Bids', '${antique.totalBids}'),
                    _buildInfoRow('End Time', Helpers.formatDateTime(antique.bidEndTime)),
                    _buildInfoRow('Status', antique.isActive ? 'Active' : 'Ended'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateAntique,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Update Antique',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Antique'),
        content: const Text(
          'Are you sure you want to delete this antique? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _deleteAntique,
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAntique() async {
    Get.back(); // Close dialog

    try {
      antiqueViewModel.isLoading.value = true;
      await antiqueViewModel.deleteAntique(antique.id);
      
      Get.back(); // Go back to previous screen
      Get.snackbar(
        'Success',
        'Antique deleted successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete antique: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      antiqueViewModel.isLoading.value = false;
    }
  }
}
