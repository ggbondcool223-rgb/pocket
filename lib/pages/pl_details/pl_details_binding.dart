import 'package:get/get.dart';
import 'pl_details_logic.dart';
class PlDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PlDetailsLogic());
  }
}
