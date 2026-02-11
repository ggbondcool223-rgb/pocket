import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pocket_ledger/db_pl/db_pl_entity.dart';
import 'pl_home_logic.dart';
class PlHomePage extends GetView<PlHomeLogic> {
  const PlHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadData,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            _buildMonthlySummaryCard(),
            SizedBox(height: 12.h),
            _buildCategoryBudgetAlerts(),
            SizedBox(height: 16.h),
            _buildDateHeader(),
            SizedBox(height: 16.h),
            _buildBillListCard(),
            SizedBox(height: 16.h),
            _buildDailySummary(),
            SizedBox(height: 16.h),
            _buildQuickTemplates(),
          ],
        ),
      ),
    );
  }
  Widget _buildMonthlySummaryCard() {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.w),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF1976D2).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  controller.currentMonth.value,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Column(
                children: [
                  Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: _buildSummaryItem(
                            controller.monthlyIncome.value.toStringAsFixed(2),
                            'Monthly Income',
                            change: controller.incomeChange.value,
                            isExpense: false,
                          ),
                        ),
                        Expanded(
                          child: _buildSummaryItem(
                            controller.monthlyExpense.value.toStringAsFixed(2),
                            'Monthly Expense',
                            change: controller.expenseChange.value,
                            isExpense: true,
                          ),
                        ),
                        Expanded(
                          child: _buildSummaryItem(
                            controller.remainingBudget.value.toStringAsFixed(2),
                            'Remaining Budget',
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (controller.isOverBudget.value) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.warning_rounded,
                            color: Color(0xFFE53935),
                            size: 16,
                          ),
                          SizedBox(width: 6.w),
                          const Text(
                            'Over Budget!',
                            style: TextStyle(
                              color: Color(0xFFE53935),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (controller.isBudgetAlert.value) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFFF6F00),
                            size: 16,
                          ),
                          SizedBox(width: 6.w),
                          const Text(
                            'Budget Alert!',
                            style: TextStyle(
                              color: Color(0xFFFF6F00),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSummaryItem(
    String amount,
    String label, {
    double? change,
    bool? isExpense,
  }) {
    return Column(
      children: [
        Text(
          amount,
          style: const TextStyle(
            color: Color(0xFF212121),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF757575), fontSize: 11),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (change != null &&
            isExpense != null &&
            controller.showComparison.value) ...[
          SizedBox(height: 4.h),
          Obx(
            () => Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: controller
                    .getChangeColor(change, isExpense)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.w),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    change > 0
                        ? Icons.arrow_upward
                        : change < 0
                        ? Icons.arrow_downward
                        : Icons.remove,
                    size: 10.w,
                    color: controller.getChangeColor(change, isExpense),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    controller.getChangeText(change),
                    style: TextStyle(
                      color: controller.getChangeColor(change, isExpense),
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
  Widget _buildQuickTemplates() {
    return Obx(
      () => controller.quickTemplates.isEmpty
          ? const SizedBox.shrink()
          : Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bolt,
                        size: 20.w,
                        color: const Color(0xFFFFB84D),
                      ),
                      SizedBox(width: 8.w),
                      const Text(
                        'Quick Templates',
                        style: TextStyle(
                          color: Color(0xFF212121),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: controller.quickTemplates.map((template) {
                      return GestureDetector(
                        onTap: () => _showTemplateConfirmDialog(template),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F8FA),
                            borderRadius: BorderRadius.circular(20.w),
                            border: Border.all(
                              color: const Color(0xFF1976D2).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                template.type == 'expense'
                                    ? Icons.remove_circle_outline
                                    : Icons.add_circle_outline,
                                size: 16.w,
                                color: template.type == 'expense'
                                    ? const Color(0xFFE53935)
                                    : const Color(0xFF2E7D32),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                template.name,
                                style: TextStyle(
                                  color: const Color(0xFF212121),
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                '\$${template.amount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: const Color(0xFF757575),
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
    );
  }
  Widget _buildCategoryBudgetAlerts() {
    return Obx(
      () => controller.categoryBudgetAlerts.isEmpty
          ? const SizedBox.shrink()
          : Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Column(
                children: controller.categoryBudgetAlerts.map((alert) {
                  final alertLevel = alert['alertLevel'] as String;
                  final usage = alert['usage'] as double;
                  final category = alert['category'] as String;
                  final expense = alert['expense'] as double;
                  final budget = alert['budget'] as double;
                  Color alertColor;
                  IconData alertIcon;
                  String alertText;
                  if (alertLevel == 'exceeded') {
                    alertColor = const Color(0xFFE53935);
                    alertIcon = Icons.error;
                    alertText = '$category Budget Exceeded!';
                  } else if (alertLevel == 'critical') {
                    alertColor = const Color(0xFFFFA726);
                    alertIcon = Icons.warning;
                    alertText = '$category Budget Alert!';
                  } else {
                    alertColor = const Color(0xFFFFB84D);
                    alertIcon = Icons.info_outline;
                    alertText = '$category Budget Notice';
                  }
                  return Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: alertColor, width: 4.w),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(alertIcon, color: alertColor, size: 24.w),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                alertText,
                                style: TextStyle(
                                  color: const Color(0xFF212121),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Text(
                                    '\$${expense.toStringAsFixed(2)} / \$${budget.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: const Color(0xFF757575),
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: alertColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4.w),
                                    ),
                                    child: Text(
                                      '${(usage * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        color: alertColor,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
  Widget _buildDateHeader() {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1976D2),
          borderRadius: BorderRadius.circular(12.w),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1976D2).withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.white, size: 16),
            SizedBox(width: 8.w),
            Text(
              controller.currentDate.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildBillListCard() {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Category',
                    style: TextStyle(
                      color: const Color(0xFF757575),
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Amount',
                    style: TextStyle(
                      color: const Color(0xFF757575),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Note',
                    style: TextStyle(
                      color: const Color(0xFF757575),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            if (controller.todayBills.isEmpty) ...[
              SizedBox(height: 40.h),
              Icon(
                Icons.receipt_long_outlined,
                size: 48.w,
                color: const Color(0xFFBDBDBD),
              ),
              SizedBox(height: 12.h),
              const Text(
                'How much did you spend today?',
                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
              ),
              SizedBox(height: 40.h),
            ] else ...[
              for (int i = 0; i < controller.todayBills.length; i++) ...[
                if (i > 0)
                  Divider(height: 20.h, color: const Color(0xFFE0E0E0)),
                _buildBillItem(controller.todayBills[i]),
              ],
            ],
          ],
        ),
      ),
    );
  }
  Widget _buildBillItem(BillEntity bill) {
    final category = controller.getCategoryDisplay(bill);
    final amount = controller.getAmountDisplay(bill);
    final note = bill.note ?? '';
    return InkWell(
      onTap: () => controller.onBillTap(bill),
      borderRadius: BorderRadius.circular(8.w),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                category,
                style: const TextStyle(color: Color(0xFF212121), fontSize: 14),
              ),
            ),
            Expanded(
              child: Text(
                amount,
                style: TextStyle(
                  color: bill.type == 'expense'
                      ? const Color(0xFF1565C0)
                      : const Color(0xFF2E7D32),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                note,
                style: const TextStyle(color: Color(0xFF757575), fontSize: 12),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildDailySummary() {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Summary',
              style: TextStyle(
                color: Color(0xFF212121),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            _buildSummaryRow(
              'Total Expense:',
              controller.dailyExpense.value.toStringAsFixed(2),
              const Color(0xFF1976D2),
            ),
            SizedBox(height: 12.h),
            _buildSummaryRow(
              'Total Income:',
              controller.dailyIncome.value.toStringAsFixed(2),
              const Color(0xFF2E7D32),
            ),
            SizedBox(height: 12.h),
            Obx(
              () => _buildSummaryRow(
                'Balance:',
                controller.dailyBalance.value.toStringAsFixed(2),
                controller.dailyBalance.value >= 0
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFE53935),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSummaryRow(String label, String amount, Color dotColor) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF757575), fontSize: 14),
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            color: Color(0xFF212121),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  void _showTemplateConfirmDialog(TemplateEntity template) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.w),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                template.type == 'expense'
                    ? Icons.remove_circle_outline
                    : Icons.add_circle_outline,
                size: 48.w,
                color: template.type == 'expense'
                    ? const Color(0xFFE53935)
                    : const Color(0xFF2E7D32),
              ),
              SizedBox(height: 16.h),
              const Text(
                'Create Bill from Template?',
                style: TextStyle(
                  color: Color(0xFF212121),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                template.name,
                style: const TextStyle(color: Color(0xFF757575), fontSize: 16),
              ),
              SizedBox(height: 8.h),
              Text(
                '\$${template.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: template.type == 'expense'
                      ? const Color(0xFFE53935)
                      : const Color(0xFF2E7D32),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (template.note != null && template.note!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  template.note!,
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF757575),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.createBillFromTemplate(template);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
