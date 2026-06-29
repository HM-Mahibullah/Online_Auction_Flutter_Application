import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';
import '../../view_models/antique_view_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class AddAntiqueScreen extends StatelessWidget {
  const AddAntiqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final antiqueViewModel = Get.find<AntiqueViewModel>();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Antique'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker
              Obx(() {
                final image = antiqueViewModel.selectedImage.value;
                return GestureDetector(
                  onTap: () => _showImagePickerOptions(context, antiqueViewModel),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: image == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 60,
                                color: AppColors.textTertiary,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add Antique Image',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              image,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              // Title Field
              CustomTextField(
                controller: antiqueViewModel.titleController,
                label: 'Title',
                hint: 'Enter antique title',
                validator: (value) => Validators.validateRequired(value, 'Title'),
              ),
              const SizedBox(height: 16),
              // Description Field
              CustomTextField(
                controller: antiqueViewModel.descriptionController,
                label: 'Description',
                hint: 'Enter antique description',
                maxLines: 4,
                validator: (value) => Validators.validateRequired(value, 'Description'),
              ),
              const SizedBox(height: 16),
              // Category Field
              CustomTextField(
                controller: antiqueViewModel.categoryController,
                label: 'Category',
                hint: 'e.g., Furniture, Jewelry, Art',
              ),
              const SizedBox(height: 16),
              // Base Price Field
              CustomTextField(
                controller: antiqueViewModel.basePriceController,
                label: 'Base Price (Tk)',
                hint: 'Enter starting price',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixIcon: const Icon(Icons.attach_money),
                validator: Validators.validatePrice,
              ),
              const SizedBox(height: 16),
              // End Date Field
              Obx(() {
                final endDate = antiqueViewModel.selectedEndDate.value;
                return CustomTextField(
                  controller: TextEditingController(
                    text: endDate != null
                        ? Helpers.formatDateTime(endDate)
                        : '',
                  ),
                  label: 'Auction End Date & Time',
                  hint: 'Select end date and time',
                  readOnly: true,
                  prefixIcon: const Icon(Icons.calendar_today),
                  onTap: () => antiqueViewModel.selectEndDate(context),
                  validator: (value) {
                    if (endDate == null) {
                      return 'Please select end date and time';
                    }
                    return null;
                  },
                );
              }),
              const SizedBox(height: 32),
              // Submit Button
              Obx(() => CustomButton(
                    text: 'Add Antique',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        antiqueViewModel.createAntique();
                      }
                    },
                    isLoading: antiqueViewModel.isLoading.value,
                    icon: Icons.add,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePickerOptions(
    BuildContext context,
    AntiqueViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                viewModel.pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Get.back();
                viewModel.takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }
}
