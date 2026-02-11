import 'package:get/get.dart';
import 'pl_template_manage_logic.dart';
class PlTemplateManageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PlTemplateManageLogic());
  }
}
