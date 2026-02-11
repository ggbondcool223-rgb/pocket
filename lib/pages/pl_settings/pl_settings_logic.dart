import 'package:get/get.dart';
import 'package:pocket_ledger/db_pl/data.dart';
import 'package:pocket_ledger/utils/index.dart';
class PlSettingsLogic extends GetxController {
  final PlDatabase _database = PlDatabase();
  Future<void> deleteAllData() async {
    try {
      await _database.deleteAllData();
      successToast('All data deleted successfully');
      Get.back();
    } catch (e) {
      errorToast('Failed to delete data: ${e.toString()}');
    }
  }
}
