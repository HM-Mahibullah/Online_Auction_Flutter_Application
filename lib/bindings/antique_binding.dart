import 'package:get/get.dart';
import '../view_models/antique_view_model.dart';

class AntiqueBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AntiqueViewModel>(() => AntiqueViewModel());
  }
}
