import 'package:get/get.dart';
import 'pl_settings_logic.dart';
class PlSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PlSettingsLogic());
  }
}
