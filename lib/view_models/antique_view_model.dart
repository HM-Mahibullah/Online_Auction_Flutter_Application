import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models/antique_model.dart';
import '../repository/antique_repository.dart';
import '../repository/auth_repository.dart';

class AntiqueViewModel extends GetxController {
  final AntiqueRepository _antiqueRepository = AntiqueRepository();
  final AuthRepository _authRepository = AuthRepository();

  // Controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final basePriceController = TextEditingController();
  final categoryController = TextEditingController();

  // Observable state
  final isLoading = false.obs;
  final antiques = <AntiqueModel>[].obs;
  final activeAntiques = <AntiqueModel>[].obs;
  final filteredAntiques = <AntiqueModel>[].obs;
  final selectedAntique = Rx<AntiqueModel?>(null);
  final selectedImage = Rx<File?>(null);
  final selectedEndDate = Rx<DateTime?>(null);
  final canAddAntiques = false.obs;
  final selectedCategory = Rx<String?>(null);
  final categories = <String>[].obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadAntiques();
    checkAddPermission();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    basePriceController.dispose();
    categoryController.dispose();
    super.onClose();
  }

  // Check if user can add antiques
  Future<void> checkAddPermission() async {
    try {
      final userId = _authRepository.currentUserId;
      if (userId != null) {
        canAddAntiques.value = await _antiqueRepository.canAddAntiques(userId);
      }
    } catch (e) {
      debugPrint('Error checking add permission: $e');
    }
  }

  // Load all antiques
  void loadAntiques() {
    _antiqueRepository.streamActiveAntiques().listen((data) {
      if (data.isEmpty) {
        // Load demo data if no antiques found
        _loadDemoAntiques();
      } else {
        activeAntiques.value = data.map(_normalizeAntique).toList();
        _updateCategories();
        _applyFilter();
      }
    });
  }

  // Load demo antiques for testing
  void _loadDemoAntiques() {
    final demoAntiques = [
      AntiqueModel(
        id: 'demo_1',
        title: 'Antique Bagladesh car',
        description: 'Beautifully preserved vintage car from the early 20th century, showcasing classic design and craftsmanship. A true collector\'s item for automobile enthusiasts.',
        // imageUrl: 'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61',
        imageUrl: 'assets/images/car.png',
        basePrice: 5500.0,
        currentBid: 5500.0,
        bidEndTime: DateTime.now().add(const Duration(days: 10)),
        curatorId: 'demo_admin',
        curatorName: 'Curator Admin',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isActive: true,
        totalBids: 0,
        category: 'Pottery',
      ),
      AntiqueModel(
        id: 'demo_2',
        title: 'Gramaphone from 1920s',
        description: 'Iconic gramophone from the roaring 1920s, featuring a large brass horn and intricate woodwork. This vintage piece is in excellent condition and still plays music, making it a prized possession for collectors.',
        // imageUrl: 'https://images.unsplash.com/photo-1561214115-6d2f1b0609fa',
        imageUrl: 'assets/images/gramaphone.png',
        basePrice: 15000.0,
        currentBid: 15000.0,
        bidEndTime: DateTime.now().add(const Duration(days: 7)),
        curatorId: 'demo_admin',
        curatorName: 'Curator Admin',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isActive: true,
        totalBids: 0,
        category: 'Paintings',
      ),
      AntiqueModel(
        id: 'demo_3',
        title: 'jumka from 18th century',
        description: ' Exquisite 18th-century jumka earrings, crafted with intricate gold filigree and adorned with precious gemstones. These traditional Indian earrings are a stunning example of historical jewelry design and craftsmanship.',
        // imageUrl: 'https://images.unsplash.com/photo-1578500494198-246f612d03b3',
        imageUrl: 'assets/images/jumka.png',
        basePrice: 8500.0,
        currentBid: 8500.0,
        bidEndTime: DateTime.now().add(const Duration(days: 5)),
        curatorId: 'demo_admin',
        curatorName: 'Curator Admin',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        isActive: true,
        totalBids: 0,
        category: 'Sculptures',
      ),
      AntiqueModel(
        id: 'demo_4',
        title: 'Rikchaw from 19th century',
        description: 'Charming 19th-century rickshaw, a symbol of traditional transportation in South Asia. This vintage piece features intricate woodwork and metal detailing, making it a unique collectible for those interested in historical artifacts.',
        // imageUrl: 'https://images.unsplash.com/photo-1610070175285-6b0e60bbbc83',
        imageUrl: 'assets/images/rickshaw.png',
        basePrice: 12000.0,
        currentBid: 12000.0,
        bidEndTime: DateTime.now().add(const Duration(days: 8)),
        curatorId: 'demo_admin',
        curatorName: 'Curator Admin',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isActive: true,
        totalBids: 0,
        category: 'Cars',
      ),
      AntiqueModel(
        id: 'demo_5',
        title: 'Golden Ring',
        description: 'Elegant golden ring from the early 20th century, featuring intricate engravings and a timeless design. This vintage piece is a testament to the craftsmanship of the era and is a must-have for jewelry collectors.',
        // imageUrl: 'https://images.unsplash.com/photo-1599388894657-b2e454eda8c8',
        imageUrl: 'assets/images/ring.png',
        basePrice: 3500.0,
        currentBid: 3500.0,
        bidEndTime: DateTime.now().add(const Duration(days: 6)),
        curatorId: 'demo_admin',
        curatorName: 'Curator Admin',
        createdAt: DateTime.now(),
        isActive: true,
        totalBids: 0,
        category: 'Timepieces',
      ),
      AntiqueModel(
        id: 'demo_6',
        title: ' Poet Kazi Nazrul Islam ',
        description: 'Kazi Nazrul Islam (1899-1976) was a Bengali poet, writer, musician, and revolutionary. Known as the "Rebel Poet," his works inspired the fight against British colonial rule in India. His poetry and songs continue to resonate with themes of freedom, humanity, and social justice.',
        imageUrl: 'assets/images/Nazrul.png',
        basePrice: 9500.0,
        currentBid: 9500.0,
        bidEndTime: DateTime.now().add(const Duration(days: 9)), 
        curatorId: 'demo_admin',
        curatorName: 'Curator Admin',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        isActive: true,
        totalBids: 0,
        category: 'Pictures',
      ),
    ];

    activeAntiques.value = demoAntiques;
    _updateCategories();
    _applyFilter();
  }

  // Update categories list
  void _updateCategories() {
    final categorySet = <String>{};
    for (var antique in activeAntiques) {
      if (antique.category.isNotEmpty) {
        categorySet.add(antique.category);
      }
    }
    categories.value = categorySet.toList()..sort();
  }

  // Apply category filter
  void _applyFilter() {
    if (selectedCategory.value == null) {
      filteredAntiques.value = activeAntiques;
    } else {
      filteredAntiques.value = activeAntiques
          .where((a) => a.category == selectedCategory.value)
          .toList();
    }
  }

  // Select category
  void selectCategory(String? category) {
    selectedCategory.value = category;
    _applyFilter();
  }

  // Get antique by ID
  Future<void> getAntique(String antiqueId) async {
    try {
      isLoading.value = true;
      final antique = await _antiqueRepository.getAntique(antiqueId);
      if (antique != null) {
        selectedAntique.value = _normalizeAntique(antique);
      } else {
        selectedAntique.value = null;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load antique details',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Stream antique by ID
  void streamAntique(String antiqueId) {
    if (antiqueId.isEmpty) {
      debugPrint('ERROR: streamAntique called with empty antiqueId');
      selectedAntique.value = activeAntiques.isNotEmpty ? activeAntiques.first : null;
      return;
    }
    
    try {
      _antiqueRepository.streamAntique(antiqueId).listen(
        (antique) {
          if (antique != null) {
            selectedAntique.value = _normalizeAntique(antique);
            debugPrint('✓ Loaded antique from Firestore: $antiqueId');
          } else {
            debugPrint('WARNING: Firestore returned null for antique: $antiqueId');
            // Try to find in active antiques (demo data)
            try {
              final found = activeAntiques.firstWhere((a) => a.id == antiqueId);
              selectedAntique.value = found;
              debugPrint('✓ Found antique in demo data: $antiqueId');
            } catch (e) {
              debugPrint('ERROR: Antique not found in demo data either: $antiqueId');
              // Load first demo antique as fallback
              if (activeAntiques.isNotEmpty) {
                selectedAntique.value = activeAntiques.first;
              }
            }
          }
        },
        onError: (error) {
          debugPrint('Stream error for antique $antiqueId: $error');
          // On error, try demo data fallback
          try {
            final found = activeAntiques.firstWhere((a) => a.id == antiqueId);
            selectedAntique.value = found;
            debugPrint('✓ Fallback to demo data after stream error: $antiqueId');
          } catch (e) {
            if (activeAntiques.isNotEmpty) {
              selectedAntique.value = activeAntiques.first;
            }
          }
        },
      );
    } catch (e) {
      debugPrint('ERROR in streamAntique: $e');
      // Fallback to demo data
      try {
        final found = activeAntiques.firstWhere((a) => a.id == antiqueId);
        selectedAntique.value = found;
      } catch (e) {
        if (activeAntiques.isNotEmpty) {
          selectedAntique.value = activeAntiques.first;
        }
      }
    }
  }

  // Pick image from gallery
  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Take photo
  Future<void> takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take photo',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Select end date
  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        selectedEndDate.value = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );
      }
    }
  }

  // Create antique
  Future<void> createAntique() async {
    try {
      if (selectedEndDate.value == null) {
        Get.snackbar(
          'Error',
          'Please select an end date',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;

      final basePrice = double.parse(basePriceController.text);

      await _antiqueRepository.createAntique(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        imageFile: selectedImage.value,
        basePrice: basePrice,
        bidEndTime: selectedEndDate.value!,
        category: categoryController.text.trim().isEmpty
            ? 'Other'
            : categoryController.text.trim(),
      );

      // Show success message with options
      Get.snackbar(
        'Success',
        'Antique added successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () {
            Get.back(); // Close snackbar
            clearForm(); // Stay on page to add more
          },
          child: const Text(
            'Add More',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

      clearForm();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add antique: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Clear form
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    basePriceController.clear();
    categoryController.clear();
    selectedImage.value = null;
    selectedEndDate.value = null;
  }

  // Update antique details
  Future<void> updateAntiqueDetails({
    required String antiqueId,
    required String title,
    required String description,
    required double basePrice,
    required String category,
  }) async {
    try {
      await _antiqueRepository.updateAntique(antiqueId, {
        'title': title,
        'description': description,
        'basePrice': basePrice,
        'category': category,
      });

      // Refresh local copies so UI (image/category) updates immediately
      try {
        final updated = await _antiqueRepository.getAntique(antiqueId);
        if (updated != null) {
          final normalized = _normalizeAntique(updated);

          // Update selectedAntique if it's the same item
          if (selectedAntique.value != null && selectedAntique.value!.id == antiqueId) {
            selectedAntique.value = normalized;
          }

          // Replace in activeAntiques
          final idx = activeAntiques.indexWhere((a) => a.id == antiqueId);
          if (idx != -1) {
            activeAntiques[idx] = normalized;
            // Trigger reactive update
            activeAntiques.refresh();
            _updateCategories();
            _applyFilter();
          }
        }
      } catch (e) {
        debugPrint('Warning: failed to refresh updated antique locally: $e');
      }
    } catch (e) {
      throw Exception('Failed to update antique: $e');
    }
  }

  // Delete antique
  Future<void> deleteAntique(String antiqueId) async {
    try {
      await _antiqueRepository.deleteAntique(antiqueId);
    } catch (e) {
      throw Exception('Failed to delete antique: $e');
    }
  }

  // Local asset list and mapping
  final List<String> _localAssets = [
    'assets/images/car.png',
    'assets/images/gramaphone.png',
    'assets/images/jumka.png',
    'assets/images/rickshaw.png',
    'assets/images/ring.png',
    'assets/images/Nazrul.png',
  ];

  final Map<String, String> _categoryToAsset = {
    'cars': 'assets/images/car.png',
    'pottery': 'assets/images/car.png',
    'paintings': 'assets/images/gramaphone.png',
    'sculptures': 'assets/images/jumka.png',
    'timepieces': 'assets/images/ring.png',
    'pictures': 'assets/images/Nazrul.png',
  };

  String _getRandomLocalAsset() {
    final rnd = Random();
    return _localAssets[rnd.nextInt(_localAssets.length)];
  }

  AntiqueModel _normalizeAntique(AntiqueModel a) {
    final cat = a.category.toLowerCase().trim();
    final current = a.imageUrl.trim();
    if (_categoryToAsset.containsKey(cat)) {
      return a.copyWith(imageUrl: _categoryToAsset[cat]);
    }
    if (current.isEmpty || !current.startsWith('assets/')) {
      return a.copyWith(imageUrl: _getRandomLocalAsset());
    }
    return a;
  }

  // Check if current user can manage this antique (admin/curator only)
  bool isAntiqueOwner(String? curatorId) {
    final userId = _authRepository.currentUserId;
    // Admins (canAddAntiques) OR the curator who created the item can manage it
    if (userId == null) return false;
    return canAddAntiques.value || (curatorId != null && userId == curatorId);
  }
}
