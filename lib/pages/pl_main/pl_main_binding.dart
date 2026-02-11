import 'package:get/get.dart';
import 'package:pocket_ledger/pages/pl_home/pl_home_logic.dart';
import 'package:pocket_ledger/pages/pl_details/pl_details_logic.dart';
import 'package:pocket_ledger/pages/pl_annual/pl_annual_logic.dart';
import 'package:pocket_ledger/pages/pl_settings/pl_settings_logic.dart';
import 'pl_main_logic.dart';
class PlMainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PlMainLogic());
    Get.lazyPut(() => PlHomeLogic());
    Get.lazyPut(() => PlDetailsLogic());
    Get.lazyPut(() => PlAnnualLogic());
    Get.lazyPut(() => PlSettingsLogic());
  }
}
