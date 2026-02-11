import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'pl_annual_logic.dart';

class PlAnnualPage extends GetView<PlAnnualLogic> {
  const PlAnnualPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadData,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(height: 16.h),
                  _buildMonthlyTable(),
                  SizedBox(height: 24.h),
                  _buildRankingSection(),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Obx(
      () => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: controller.onPreviousYear,
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    iconSize: 28,
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: controller.showYearPicker,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20.w),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            controller.selectedYear.value.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    onPressed: controller.onNextYear,
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    iconSize: 28,
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  const Text(
                    'Annual Balance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                '\$${controller.balance.value.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 24.h),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16.w),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Total Income',
                        controller.totalIncome.value,
                        Icons.arrow_downward_rounded,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40.h,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Total Expense',
                        controller.totalExpense.value,
                        Icons.arrow_upward_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, double amount, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyTable() {
    return Obx(
      () => Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
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
            Container(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.w),
                  topRight: Radius.circular(16.w),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Month',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Income',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Expense',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Balance',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            controller.monthlyStats.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(48.h),
                    child: Column(
                      children: [
                        Icon(
                          Icons.bar_chart_outlined,
                          size: 48.w,
                          color: const Color(0xFFBDBDBD),
                        ),
                        SizedBox(height: 12.h),
                        const Text(
                          'No data available',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      for (
                        int i = 0;
                        i < controller.monthlyStats.length;
                        i++
                      ) ...[
                        if (i > 0)
                          Divider(height: 1.h, color: const Color(0xFFE0E0E0)),
                        _buildMonthRow(controller.monthlyStats[i]),
                      ],
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthRow(dynamic stat) {
    final month = controller.getMonthName(stat.month);
    final income = stat.income.toStringAsFixed(2);
    final expense = stat.expense.toStringAsFixed(2);
    final balance = stat.balance.toStringAsFixed(2);
    final balanceColor = stat.balance >= 0
        ? const Color(0xFF2E7D32)
        : const Color(0xFFE53935);
    return InkWell(
      onTap: () => controller.onMonthTap(stat.yearMonth),
      borderRadius: BorderRadius.circular(8.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    width: 6.w,
                    height: 6.h,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1976D2),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    month,
                    style: const TextStyle(
                      color: Color(0xFF212121),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '\$$income',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '\$$expense',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF1565C0),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '\$$balance',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: balanceColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingSection() {
    return Obx(
      () => Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: Color(0xFFFFB84D),
                    size: 24,
                  ),
                  SizedBox(width: 8.w),
                  const Text(
                    'Top Expenses',
                    style: TextStyle(
                      color: Color(0xFF212121),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showCategoryFilterDialog,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F8FA),
                        borderRadius: BorderRadius.circular(16.w),
                      ),
                      child: Row(
                        children: [
                          Text(
                            controller.rankingFilterCategory.value,
                            style: TextStyle(
                              color: const Color(0xFF1976D2),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.filter_list,
                            size: 16.w,
                            color: const Color(0xFF1976D2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (controller.topExpenses.isEmpty)
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Center(
                  child: Text(
                    'No expense data yet',
                    style: TextStyle(
                      color: const Color(0xFF757575),
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              )
            else
              ...controller.topExpenses.asMap().entries.map((entry) {
                final index = entry.key;
                final bill = entry.value;
                return _buildRankingItem(index + 1, bill);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingItem(int rank, Map<String, dynamic> bill) {
    final amount = bill['amount'] as double;
    final category = controller.getCategoryDisplay(bill);
    final date = controller.formatDateDisplay(bill['date'] as String);
    final note = bill['note'] as String?;
    Color rankColor;
    if (rank == 1) {
      rankColor = const Color(0xFFFFD700);
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0);
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32);
    } else {
      rankColor = const Color(0xFF757575);
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: const Color(0xFFF5F5F5), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  color: rankColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    color: const Color(0xFF212121),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  date + (note != null && note.isNotEmpty ? ' • $note' : ''),
                  style: TextStyle(
                    color: const Color(0xFF757575),
                    fontSize: 12.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: const Color(0xFFE53935),
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryFilterDialog() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.w)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Category',
              style: TextStyle(
                color: Color(0xFF212121),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: controller.expenseCategories.map((category) {
                final isSelected =
                    controller.rankingFilterCategory.value == category;
                return GestureDetector(
                  onTap: () {
                    controller.switchRankingFilter(category);
                    Get.back();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1976D2)
                          : const Color(0xFFF5F8FA),
                      borderRadius: BorderRadius.circular(20.w),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF212121),
                        fontSize: 14.sp,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
