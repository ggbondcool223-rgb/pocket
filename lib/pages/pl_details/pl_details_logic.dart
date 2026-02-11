import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_ledger/db_pl/data.dart';
import 'package:pocket_ledger/db_pl/db_pl_entity.dart';
import 'package:pocket_ledger/utils/index.dart';

class PlDetailsLogic extends GetxController {
  final PlDatabase _db = PlDatabase();
  final RxString selectedMonth = ''.obs;
  final RxList<BillEntity> bills = <BillEntity>[].obs;
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;
  final RxDouble balance = 0.0.obs;
  final RxString filterType = 'All'.obs;
  final RxString filterCategory = ''.obs;
  final RxInt viewMode = 0.obs;
  final RxList<int> markedDates = <int>[].obs;
  final RxInt selectedDay = 0.obs;
  final RxList<BillEntity> selectedDayBills = <BillEntity>[].obs;
  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  @override
  void onReady() {
    super.onReady();
    loadData();
  }

  void _initData() {
    final now = DateTime.now();
    selectedMonth.value = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<void> loadData() async {
    try {
      await Future.wait([_loadBills(), _loadStatistics()]);
    } catch (e) {
      print('Error loading details data: $e');
      errorToast('Failed to load data');
    }
  }

  Future<void> _loadBills() async {
    try {
      List<BillEntity> result;
      if (filterCategory.isNotEmpty) {
        result = await _db.getBillsByMonthAndCategory(
          selectedMonth.value,
          filterCategory.value,
        );
      } else if (filterType.value != 'All') {
        final type = filterType.value == 'Expense' ? 'expense' : 'income';
        result = await _db.getBillsByMonthAndType(selectedMonth.value, type);
      } else {
        result = await _db.getBillsByMonth(selectedMonth.value);
      }
      bills.value = result;
    } catch (e) {
      print('Error loading bills: $e');
      bills.value = [];
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final income = await _db.getTotalAmountByMonth(
        selectedMonth.value,
        'income',
      );
      final expense = await _db.getTotalAmountByMonth(
        selectedMonth.value,
        'expense',
      );
      totalIncome.value = income;
      totalExpense.value = expense;
      balance.value = income - expense;
    } catch (e) {
      print('Error loading statistics: $e');
      totalIncome.value = 0.0;
      totalExpense.value = 0.0;
      balance.value = 0.0;
    }
  }

  void onMonthChanged(String month) {
    selectedMonth.value = month;
    selectedDay.value = 0;
    selectedDayBills.clear();
    loadData();
    if (viewMode.value == 1) {
      _loadCalendarData();
    }
  }

  void onFilterTypeChanged(String type) {
    filterType.value = type;
    _loadBills();
  }

  void onFilterCategoryChanged(String category) {
    filterCategory.value = category;
    _loadBills();
  }

  void onClearFilter() {
    filterType.value = 'All';
    filterCategory.value = '';
    _loadBills();
  }

  String getCategoryDisplay(BillEntity bill) {
    if (bill.subCategory != null && bill.subCategory!.isNotEmpty) {
      return '${bill.category}-${bill.subCategory}';
    }
    return bill.category;
  }

  String getAmountDisplay(BillEntity bill) {
    final sign = bill.type == 'expense' ? '-' : '+';
    return '$sign${bill.amount.toStringAsFixed(2)}';
  }

  String getDateDisplay(BillEntity bill) {
    try {
      final date = DateTime.parse(bill.date);
      final monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${monthNames[date.month - 1]} ${date.day}';
    } catch (e) {
      return bill.date;
    }
  }

  void onBillTap(BillEntity bill) {}
  Future<void> onDeleteBill(BillEntity bill) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Bill'),
          content: const Text('Are you sure you want to delete this bill?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed == true && bill.id != null) {
        await _db.deleteBill(bill.id!);
        successToast('Bill deleted successfully');
        loadData();
      }
    } catch (e) {
      print('Error deleting bill: $e');
      errorToast('Failed to delete bill');
    }
  }

  void showMonthPicker() async {
    final currentDate = DateTime.parse('${selectedMonth.value}-01');
    final pickedDate = await Get.dialog<DateTime>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Month',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 300,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final month = index + 1;
                    final monthStr = month.toString().padLeft(2, '0');
                    final yearMonth = '${currentDate.year}-$monthStr';
                    final isSelected = yearMonth == selectedMonth.value;
                    final monthNames = [
                      'Jan',
                      'Feb',
                      'Mar',
                      'Apr',
                      'May',
                      'Jun',
                      'Jul',
                      'Aug',
                      'Sep',
                      'Oct',
                      'Nov',
                      'Dec',
                    ];
                    return InkWell(
                      onTap: () =>
                          Get.back(result: DateTime(currentDate.year, month)),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1976D2)
                              : const Color(0xFFF5F8FA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          monthNames[index],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF212121),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          final newDate = DateTime(
                            currentDate.year - 1,
                            currentDate.month,
                          );
                          Get.back(result: newDate);
                        },
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text(
                        '${currentDate.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final newDate = DateTime(
                            currentDate.year + 1,
                            currentDate.month,
                          );
                          Get.back(result: newDate);
                        },
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (pickedDate != null) {
      final yearMonth =
          '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}';
      onMonthChanged(yearMonth);
    }
  }

  void onPreviousMonth() {
    try {
      final currentDate = DateTime.parse('${selectedMonth.value}-01');
      final previousMonth = DateTime(currentDate.year, currentDate.month - 1);
      final yearMonth =
          '${previousMonth.year}-${previousMonth.month.toString().padLeft(2, '0')}';
      onMonthChanged(yearMonth);
    } catch (e) {
      print('Error changing to previous month: $e');
    }
  }

  void onNextMonth() {
    try {
      final currentDate = DateTime.parse('${selectedMonth.value}-01');
      final nextMonth = DateTime(currentDate.year, currentDate.month + 1);
      final yearMonth =
          '${nextMonth.year}-${nextMonth.month.toString().padLeft(2, '0')}';
      onMonthChanged(yearMonth);
    } catch (e) {
      print('Error changing to next month: $e');
    }
  }

  void refreshData() {
    loadData();
  }

  void switchViewMode(int mode) {
    viewMode.value = mode;
    if (mode == 1) {
      _loadCalendarData();
    }
  }

  Future<void> _loadCalendarData() async {
    try {
      final monthBills = await _db.getBillsByMonth(selectedMonth.value);
      print('日历数据加载: 找到 ${monthBills.length} 条账单');
      final dates = <int>{};
      for (var bill in monthBills) {
        final day = int.tryParse(bill.date.split('-').last);
        if (day != null) {
          dates.add(day);
        }
      }
      markedDates.value = dates.toList()..sort();
      print('标记的日期: $markedDates');
      if (markedDates.isNotEmpty && selectedDay.value == 0) {
        selectDay(markedDates.first);
      }
    } catch (e) {
      print('Error loading calendar data: $e');
    }
  }

  void selectDay(int day) {
    print('选择日期: $day');
    selectedDay.value = day;
    _loadSelectedDayBills(day);
  }

  void backToListView() {
    viewMode.value = 0;
  }

  Future<void> _loadSelectedDayBills(int day) async {
    try {
      final year = selectedMonth.value.split('-')[0];
      final month = selectedMonth.value.split('-')[1];
      final dateStr = '$year-$month-${day.toString().padLeft(2, '0')}';
      print('加载日期账单: $dateStr');
      final dayBills = await _db.getBillsByDate(dateStr);
      selectedDayBills.value = dayBills;
      print('找到 ${dayBills.length} 条账单');
    } catch (e) {
      print('Error loading day bills: $e');
      selectedDayBills.value = [];
    }
  }

  int get daysInMonth {
    final parts = selectedMonth.value.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    return DateTime(year, month + 1, 0).day;
  }

  int get firstWeekdayOfMonth {
    final parts = selectedMonth.value.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    return DateTime(year, month, 1).weekday % 7;
  }

  String get monthTitle {
    final parts = selectedMonth.value.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);
    final monthNames = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${monthNames[month]} $year';
  }

  bool isToday(int day) {
    final now = DateTime.now();
    final parts = selectedMonth.value.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    return year == now.year && month == now.month && day == now.day;
  }

  Future<double> getDayExpense(int day) async {
    try {
      final year = selectedMonth.value.split('-')[0];
      final month = selectedMonth.value.split('-')[1];
      final dateStr = '$year-$month-${day.toString().padLeft(2, '0')}';
      return await _db.getTotalAmountByDate(dateStr, 'expense');
    } catch (e) {
      return 0.0;
    }
  }
}
