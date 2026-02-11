import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'pl_budget_setting_logic.dart';

class PlBudgetSettingPage extends GetView<PlBudgetSettingLogic> {
  const PlBudgetSettingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF212121)),
        ),
        title: const Text(
          'Budget Setting',
          style: TextStyle(
            color: Color(0xFF212121),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        actions: [
          Obx(() {
            if (controller.hasBudget) {
              return IconButton(
                onPressed: () => _showDeleteBudgetDialog(),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFE53935),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            _buildTabSwitcher(),
            SizedBox(height: 20.h),
            Expanded(
              child: controller.currentTabIndex.value == 0
                  ? _buildTotalBudgetView()
                  : _buildCategoryBudgetsView(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTabSwitcher() {
    return Obx(
      () => Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8FA),
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Row(
          children: [
            Expanded(child: _buildTabButton('Total Budget', 0)),
            Expanded(child: _buildTabButton('By Category', 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = controller.currentTabIndex.value == index;
    return GestureDetector(
      onTap: () => controller.switchTab(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12.w),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFF212121)
                : const Color(0xFF757575),
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTotalBudgetView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20.h),
          _buildBudgetCircle(),
          SizedBox(height: 40.h),
          _buildBudgetInfo(),
          SizedBox(height: 40.h),
          _buildSetBudgetButton(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildCategoryBudgetsView() {
    return Obx(() {
      if (controller.categoryBudgets.isEmpty) {
        return _buildEmptyCategoryBudgets();
      }
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              itemCount: controller.categoryBudgets.length,
              itemBuilder: (context, index) {
                final budget = controller.categoryBudgets[index];
                return _buildCategoryBudgetItem(budget);
              },
            ),
          ),
          _buildAddCategoryBudgetButton(),
          SizedBox(height: 24.h),
        ],
      );
    });
  }

  Widget _buildEmptyCategoryBudgets() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 80.w,
            color: const Color(0xFFBDBDBD),
          ),
          SizedBox(height: 16.h),
          Text(
            'No category budgets yet',
            style: TextStyle(color: const Color(0xFF757575), fontSize: 16.sp),
          ),
          SizedBox(height: 24.h),
          _buildAddCategoryBudgetButton(),
        ],
      ),
    );
  }

  Widget _buildCategoryBudgetItem(budget) {
    return FutureBuilder<double>(
      future: controller.getCategoryExpense(budget.category!),
      builder: (context, snapshot) {
        final expense = snapshot.data ?? 0.0;
        final remaining = budget.amount - expense;
        final progress = budget.amount > 0
            ? (expense / budget.amount).clamp(0.0, 1.0)
            : 0.0;
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    budget.category!,
                    style: TextStyle(
                      color: const Color(0xFF212121),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showDeleteCategoryBudgetDialog(budget),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20.w,
                      color: const Color(0xFFE53935),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Budget: \$${budget.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: const Color(0xFF757575),
                      fontSize: 12.sp,
                    ),
                  ),
                  Text(
                    'Spent: \$${expense.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: const Color(0xFF757575),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.w),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFFE0E0E0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0
                        ? const Color(0xFFE53935)
                        : progress >= 0.8
                        ? const Color(0xFFFFA726)
                        : const Color(0xFF6B8EFF),
                  ),
                  minHeight: 8.h,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Remaining: \$${remaining.toStringAsFixed(2)}',
                style: TextStyle(
                  color: remaining < 0
                      ? const Color(0xFFE53935)
                      : const Color(0xFF2E7D32),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddCategoryBudgetButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40.w),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: controller.showCategoryBudgetDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Category Budget'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B8EFF),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.w),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  void _showDeleteCategoryBudgetDialog(budget) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Category Budget'),
        content: Text('Delete budget for ${budget.category}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteCategoryBudget(budget.id!);
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

  Widget _buildBudgetCircle() {
    return Obx(
      () => Center(
        child: SizedBox(
          width: 200.w,
          height: 200.w,
          child: CustomPaint(
            painter: _BudgetCirclePainter(
              progress: controller.progress.value,
              backgroundColor: const Color(0xFFE0E0E0),
              progressColor: controller.progressColor,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.budgetDisplayText,
                    style: TextStyle(
                      color: const Color(0xFF212121),
                      fontSize: controller.hasBudget ? 24 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (controller.hasBudget)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        'Remaining',
                        style: TextStyle(
                          color: const Color(0xFF757575),
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetInfo() {
    return Obx(
      () => Container(
        margin: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          children: [
            _buildInfoRow(
              'Remaining Budget:',
              '\$${controller.formatAmount(controller.remainingBudget.value)}',
            ),
            SizedBox(height: 16.h),
            _buildInfoRow(
              'Monthly Budget:',
              '\$${controller.formatAmount(controller.monthlyBudget.value)}',
            ),
            SizedBox(height: 16.h),
            _buildInfoRow(
              'Monthly Expense:',
              '\$${controller.formatAmount(controller.monthlyExpense.value)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF757575), fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF212121),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSetBudgetButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40.w),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _showBudgetDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B8EFF),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.w),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Set Budget',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showBudgetDialog() {
    final TextEditingController textController = TextEditingController();
    if (controller.hasBudget) {
      textController.text = controller.monthlyBudget.value.toStringAsFixed(0);
    }
    Get.dialog(
      AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: textController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: const InputDecoration(
            hintText: 'Enter budget amount',
            border: OutlineInputBorder(),
            prefixText: '\$ ',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final value = textController.text.trim();
              if (value.isEmpty) {
                Get.back();
                return;
              }
              final amount = double.tryParse(value);
              if (amount != null && amount > 0) {
                Get.back();
                controller.saveBudget(amount);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showDeleteBudgetDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Budget'),
        content: const Text(
          'Are you sure you want to delete the current month\'s budget?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteBudget();
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

class _BudgetCirclePainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  _BudgetCirclePainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final strokeWidth = 20.0;
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, backgroundPaint);
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
