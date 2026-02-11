import 'package:get/get.dart';

import 'pl_mind_logic.dart';

class PlMindBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      PlMindLogic(),
      permanent: true,
    );
  }
}
