import 'package:get/get.dart';
import 'pl_add_record_logic.dart';
class PlAddRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PlAddRecordLogic());
  }
}
