import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pocket_ledger/db_pl/db_pl_entity.dart';
import 'pl_details_logic.dart';

class PlDetailsPage extends GetView<PlDetailsLogic> {
  const PlDetailsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      body: Column(
        children: [
          _buildHeader(),
          _buildViewModeSwitcher(),
          Expanded(
            child: Obx(
              () => controller.viewMode.value == 0
                  ? _buildListView()
                  : _buildCalendarView(),
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
                    onPressed: controller.onPreviousMonth,
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    iconSize: 28,
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: controller.showMonthPicker,
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
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            controller.selectedMonth.value,
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
                    onPressed: controller.onNextMonth,
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
                    'Balance',
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
                        'Expense',
                        controller.totalExpense.value,
                        Icons.arrow_upward_rounded,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40.h,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Income',
                        controller.totalIncome.value,
                        Icons.arrow_downward_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              _buildFilterBar(),
              SizedBox(height: 12.h),
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

  Widget _buildBillItem(BillEntity bill) {
    final category = controller.getCategoryDisplay(bill);
    final date = controller.getDateDisplay(bill);
    final amount = controller.getAmountDisplay(bill);
    final iconBgColor = bill.type == 'expense'
        ? const Color(0xFF1565C0)
        : const Color(0xFF2E7D32);
    final icon = _getIconForCategory(bill.category);
    return Dismissible(
      key: Key('bill_${bill.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935),
          borderRadius: BorderRadius.circular(12.w),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        await controller.onDeleteBill(bill);
        return false;
      },
      child: InkWell(
        onTap: () => controller.onBillTap(bill),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: iconBgColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconBgColor, size: 24.w),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        color: Color(0xFF212121),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      date,
                      style: const TextStyle(
                        color: Color(0xFF757575),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  color: bill.type == 'expense'
                      ? const Color(0xFF1565C0)
                      : const Color(0xFF2E7D32),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            _buildFilterChip('All', controller.filterType.value == 'All', () {
              controller.onFilterTypeChanged('All');
            }),
            SizedBox(width: 8.w),
            _buildFilterChip(
              'Expense',
              controller.filterType.value == 'Expense',
              () {
                controller.onFilterTypeChanged('Expense');
              },
            ),
            SizedBox(width: 8.w),
            _buildFilterChip(
              'Income',
              controller.filterType.value == 'Income',
              () {
                controller.onFilterTypeChanged('Income');
              },
            ),
            const Spacer(),
            if (controller.filterType.value != 'All' ||
                controller.filterCategory.isNotEmpty)
              TextButton(
                onPressed: controller.onClearFilter,
                child: const Text(
                  'Clear',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20.w),
          border: isSelected
              ? null
              : Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF1976D2) : Colors.white,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64.w,
            color: const Color(0xFFBDBDBD),
          ),
          SizedBox(height: 16.h),
          const Text(
            'No data available',
            style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'transport':
        return Icons.directions_subway;
      case 'business':
        return Icons.business;
      case 'housing':
        return Icons.apartment;
      case 'food':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.receipt;
    }
  }

  Widget _buildViewModeSwitcher() {
    return Obx(
      () => Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8FA),
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: Row(
          children: [
            Expanded(child: _buildViewModeButton('List', Icons.list, 0)),
            Expanded(
              child: _buildViewModeButton('Calendar', Icons.calendar_month, 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewModeButton(String title, IconData icon, int mode) {
    final isSelected = controller.viewMode.value == mode;
    return GestureDetector(
      onTap: () => controller.switchViewMode(mode),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.w,
              color: isSelected
                  ? const Color(0xFF1976D2)
                  : const Color(0xFF757575),
            ),
            SizedBox(width: 6.w),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF1976D2)
                    : const Color(0xFF757575),
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return Obx(
      () => RefreshIndicator(
        onRefresh: controller.loadData,
        child: controller.bills.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: controller.bills.length,
                itemBuilder: (context, index) {
                  final bill = controller.bills[index];
                  return _buildBillItem(bill);
                },
              ),
      ),
    );
  }

  Widget _buildCalendarView() {
    return Obx(
      () => RefreshIndicator(
        onRefresh: controller.loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildSimpleCalendar(),
              SizedBox(height: 16.h),
              controller.selectedDayBills.isEmpty
                  ? SizedBox(height: 200.h, child: _buildNoDataForDay())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: controller.selectedDayBills.length,
                      itemBuilder: (context, index) {
                        final bill = controller.selectedDayBills[index];
                        return _buildBillItem(bill);
                      },
                    ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleCalendar() {
    final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays
                .map(
                  (day) => Text(
                    day,
                    style: TextStyle(
                      color: const Color(0xFF757575),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                .toList(),
          ),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return Obx(() {
      final days = List.generate(controller.daysInMonth, (i) => i + 1);
      final leadingBlanks = List.generate(
        controller.firstWeekdayOfMonth,
        (_) => 0,
      );
      final allCells = [...leadingBlanks, ...days];
      final rows = (allCells.length / 7).ceil();
      return Padding(
        padding: EdgeInsets.only(top: 12.h),
        child: Column(
          children: List.generate(rows, (rowIndex) {
            return Padding(
              padding: EdgeInsets.only(bottom: rowIndex < rows - 1 ? 8.h : 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (colIndex) {
                  final cellIndex = rowIndex * 7 + colIndex;
                  if (cellIndex >= allCells.length) {
                    return Expanded(child: SizedBox(height: 40.h));
                  }
                  final day = allCells[cellIndex];
                  if (day == 0) {
                    return Expanded(child: SizedBox(height: 40.h));
                  }
                  final isSelected = day == controller.selectedDay.value;
                  final isMarked = controller.markedDates.contains(day);
                  final isTodayDay = controller.isToday(day);
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: GestureDetector(
                        onTap: () => controller.selectDay(day),
                        child: Container(
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1976D2)
                                : isMarked
                                ? const Color(0xFF1976D2).withOpacity(0.1)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: isTodayDay
                                ? Border.all(
                                    color: const Color(0xFF1976D2),
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              day.toString(),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : isMarked
                                    ? const Color(0xFF1976D2)
                                    : const Color(0xFF757575),
                                fontSize: 14.sp,
                                fontWeight: isMarked
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      );
    });
  }

  Widget _buildNoDataForDay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 60.w, color: const Color(0xFFBDBDBD)),
          SizedBox(height: 12.h),
          Text(
            'No bills on this day',
            style: TextStyle(color: const Color(0xFF757575), fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}
