import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import 'pl_template_manage_logic.dart';

class PlTemplateManagePage extends GetView<PlTemplateManageLogic> {
  const PlTemplateManagePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlColors.bgColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: PlColors.textPrimary),
        ),
        title: Text(
          'Templates',
          style: TextStyle(
            color: PlColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: controller.showAddTemplateDialog,
            icon: Icon(Icons.add, color: PlColors.primary),
            tooltip: 'Add Template',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.templates.isEmpty) {
          return _buildEmptyState();
        }
        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.templates.length,
          itemBuilder: (context, index) {
            final template = controller.templates[index];
            return _buildTemplateCard(template);
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.content_paste_off,
            size: 80.w,
            color: PlColors.textSecondary.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'No templates yet',
            style: TextStyle(color: PlColors.textSecondary, fontSize: 16.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            'Create templates for recurring expenses',
            style: TextStyle(
              color: PlColors.textSecondary.withOpacity(0.7),
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: controller.showAddTemplateDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Template'),
            style: ElevatedButton.styleFrom(
              backgroundColor: PlColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.w),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(template) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.showEditTemplateDialog(template),
          borderRadius: BorderRadius.circular(12.w),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: controller.getTypeColor(template).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    template.type == 'expense'
                        ? Icons.shopping_bag_outlined
                        : Icons.account_balance_wallet_outlined,
                    color: controller.getTypeColor(template),
                    size: 24.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: TextStyle(
                          color: PlColors.textPrimary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: controller
                                  .getTypeColor(template)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.w),
                            ),
                            child: Text(
                              controller.getTypeText(template),
                              style: TextStyle(
                                color: controller.getTypeColor(template),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            controller.getCategoryText(template),
                            style: TextStyle(
                              color: PlColors.textSecondary,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${template.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: controller.getTypeColor(template),
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        InkWell(
                          onTap: () => _showDeleteConfirmation(template),
                          borderRadius: BorderRadius.circular(4.w),
                          child: Padding(
                            padding: EdgeInsets.all(4.w),
                            child: Icon(
                              Icons.delete_outline,
                              size: 18.w,
                              color: const Color(0xFFE53935),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(template) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteTemplate(template.id!);
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
