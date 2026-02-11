import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'pl_settings_logic.dart';

class PlSettingsPage extends GetView<PlSettingsLogic> {
  const PlSettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF212121),
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildSettingItem(
            'Budget Setting',
            Icons.account_balance_wallet,
            () => Get.toNamed('/budget_setting'),
          ),
          SizedBox(height: 12.h),
          _buildSettingItem(
            'Templates',
            Icons.content_paste,
            () => Get.toNamed('/template_manage'),
          ),
          SizedBox(height: 12.h),
          _buildSettingItem('Version v1.0.0', Icons.info_outline, null),
          SizedBox(height: 12.h),
          _buildSettingItem(
            'Delete All Data',
            Icons.delete_outline,
            () {
              _showDeleteDialog();
            },
            textColor: const Color(0xFFE53935),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    IconData icon,
    VoidCallback? onTap, {
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? const Color(0xFF2E7D32), size: 24.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor ?? const Color(0xFF212121),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                color: const Color(0xFF757575),
                size: 16.w,
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'Are you sure you want to delete all data? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteAllData();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFE53935)),
            ),
          ),
        ],
      ),
    );
  }
}
