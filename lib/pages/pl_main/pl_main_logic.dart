import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_ledger/pages/pl_home/pl_home_logic.dart';
import 'package:pocket_ledger/pages/pl_details/pl_details_logic.dart';
import 'package:pocket_ledger/pages/pl_annual/pl_annual_logic.dart';
class PlMainLogic extends GetxController {
  final currentIndex = 0.obs;
  late PageController pageController;
  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0);
  }
  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
  void onTabTap(int index) {
    if (currentIndex.value == index) return;
    currentIndex.value = index;
    pageController.jumpToPage(index);
    _refreshPageData(index);
  }
  void _refreshPageData(int index) {
    try {
      switch (index) {
        case 0:
          final homeLogic = Get.find<PlHomeLogic>();
          homeLogic.refreshData();
          break;
        case 1:
          final detailsLogic = Get.find<PlDetailsLogic>();
          detailsLogic.refreshData();
          break;
        case 2:
          final annualLogic = Get.find<PlAnnualLogic>();
          annualLogic.refreshData();
          break;
      }
    } catch (e) {
      print('Error refreshing page data: $e');
    }
  }
  void onAddRecordTap() {
    Get.toNamed('/add_record')?.then((result) {
      if (result == true) {
        _refreshPageData(currentIndex.value);
      }
    });
  }
}
