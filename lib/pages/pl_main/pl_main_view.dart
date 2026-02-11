import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pocket_ledger/pages/pl_home/pl_home_view.dart';
import 'package:pocket_ledger/pages/pl_details/pl_details_view.dart';
import 'package:pocket_ledger/pages/pl_annual/pl_annual_view.dart';
import 'package:pocket_ledger/pages/pl_settings/pl_settings_view.dart';
import 'pl_main_logic.dart';

class PlMainPage extends GetView<PlMainLogic> {
  const PlMainPage({super.key});
  static final List<Widget> _pages = const [
    PlHomePage(),
    PlDetailsPage(),
    PlAnnualPage(),
    PlSettingsPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60.h,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                BottomNavigationBar(
                  currentIndex: controller.currentIndex.value <= 1
                      ? controller.currentIndex.value
                      : controller.currentIndex.value + 1,
                  onTap: (index) {
                    if (index == 2) {
                      controller.onAddRecordTap();
                      return;
                    }
                    controller.onTabTap(index > 2 ? index - 1 : index);
                  },
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: const Color(0xFF2E7D32),
                  unselectedItemColor: const Color(0xFF757575),
                  selectedFontSize: 12.sp,
                  unselectedFontSize: 12.sp,
                  selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                  items: [
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Icon(
                          controller.currentIndex.value == 0
                              ? Icons.home
                              : Icons.home_outlined,
                          size: 24.w,
                        ),
                      ),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Icon(
                          controller.currentIndex.value == 1
                              ? Icons.receipt_long
                              : Icons.receipt_long_outlined,
                          size: 24.w,
                        ),
                      ),
                      label: 'Details',
                    ),
                    BottomNavigationBarItem(
                      icon: SizedBox(width: 24.w, height: 24.w),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Icon(
                          controller.currentIndex.value == 2
                              ? Icons.pie_chart
                              : Icons.pie_chart_outline,
                          size: 24.w,
                        ),
                      ),
                      label: 'Annual',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Icon(
                          controller.currentIndex.value == 3
                              ? Icons.settings
                              : Icons.settings_outlined,
                          size: 24.w,
                        ),
                      ),
                      label: 'Settings',
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: -18.h,
                  child: Center(
                    child: GestureDetector(
                      onTap: controller.onAddRecordTap,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 56.w,
                            height: 56.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4169E1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 32.w,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Add',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF2E7D32),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
