import 'package:get/get.dart';
import 'pl_home_logic.dart';
class PlHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PlHomeLogic());
  }
}
