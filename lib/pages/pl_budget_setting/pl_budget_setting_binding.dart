import 'package:get/get.dart';
import 'pl_budget_setting_logic.dart';
class PlBudgetSettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PlBudgetSettingLogic());
  }
}
