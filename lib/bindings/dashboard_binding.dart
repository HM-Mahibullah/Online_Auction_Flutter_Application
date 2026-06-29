import 'package:get/get.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/dashboard_view_model.dart';
import '../view_models/antique_view_model.dart';
import '../view_models/bid_view_model.dart';
import '../view_models/profile_view_model.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Register AuthViewModel if not already registered
    if (!Get.isRegistered<AuthViewModel>()) {
      Get.put<AuthViewModel>(AuthViewModel(), permanent: true);
    }
    Get.lazyPut<DashboardViewModel>(() => DashboardViewModel());
    Get.lazyPut<AntiqueViewModel>(() => AntiqueViewModel());
    Get.lazyPut<BidViewModel>(() => BidViewModel());
    Get.lazyPut<ProfileViewModel>(() => ProfileViewModel());
  }
}
