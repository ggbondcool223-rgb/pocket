import 'package:get/get.dart';
import 'pl_annual_logic.dart';
class PlAnnualBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PlAnnualLogic());
  }
}
