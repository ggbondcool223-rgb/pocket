import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_ledger/db_pl/data.dart';
import 'package:pocket_ledger/utils/index.dart';

class PlAnnualLogic extends GetxController {
  final PlDatabase _db = PlDatabase();
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;
  final RxDouble balance = 0.0.obs;
  final RxList<MonthlyStats> monthlyStats = <MonthlyStats>[].obs;
  final RxInt rankingTabIndex = 0.obs;
  final RxList<Map<String, dynamic>> topExpenses = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> topDays = <Map<String, dynamic>>[].obs;
  final RxString rankingFilterCategory = 'All'.obs;
  @override
  void onReady() {
    super.onReady();
    loadData();
  }

  Future<void> loadData() async {
    try {
      await Future.wait([
        _loadYearlyStatistics(),
        _loadMonthlyData(),
        _loadRankingData(),
      ]);
    } catch (e) {
      print('Error loading annual data: $e');
      errorToast('Failed to load data');
    }
  }

  Future<void> _loadYearlyStatistics() async {
    try {
      final income = await _db.getTotalAmountByYear(
        selectedYear.value,
        'income',
      );
      final expense = await _db.getTotalAmountByYear(
        selectedYear.value,
        'expense',
      );
      totalIncome.value = income;
      totalExpense.value = expense;
      balance.value = income - expense;
    } catch (e) {
      print('Error loading yearly statistics: $e');
      totalIncome.value = 0.0;
      totalExpense.value = 0.0;
      balance.value = 0.0;
    }
  }

  Future<void> _loadMonthlyData() async {
    try {
      final stats = await _db.getMonthlyStatsByYear(selectedYear.value);
      final List<MonthlyStats> result = [];
      for (var stat in stats) {
        result.add(
          MonthlyStats(
            month: stat['month'] as int,
            yearMonth: stat['yearMonth'] as String,
            income: stat['income'] as double,
            expense: stat['expense'] as double,
            balance: stat['balance'] as double,
          ),
        );
      }
      result.sort((a, b) => b.month.compareTo(a.month));
      monthlyStats.value = result;
    } catch (e) {
      print('Error loading monthly data: $e');
      monthlyStats.value = [];
    }
  }

  void onYearChanged(int year) {
    selectedYear.value = year;
    loadData();
  }

  String getMonthName(int month) {
    const monthNames = [
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
    return monthNames[month - 1];
  }

  void onMonthTap(String yearMonth) {}
  void showYearPicker() async {
    final currentYear = selectedYear.value;
    final startYear = currentYear - 10;
    final endYear = currentYear + 5;
    final pickedYear = await Get.dialog<int>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 300, maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Year',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: endYear - startYear + 1,
                  itemBuilder: (context, index) {
                    final year = endYear - index;
                    final isSelected = year == selectedYear.value;
                    return InkWell(
                      onTap: () => Get.back(result: year),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1976D2)
                              : const Color(0xFFF5F8FA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          year.toString(),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF212121),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
    if (pickedYear != null) {
      onYearChanged(pickedYear);
    }
  }

  void onPreviousYear() {
    onYearChanged(selectedYear.value - 1);
  }

  void onNextYear() {
    onYearChanged(selectedYear.value + 1);
  }

  void refreshData() {
    loadData();
  }

  Future<void> _loadRankingData() async {
    try {
      final bills = await _db.getBillsByYear(selectedYear.value);
      var expenseBills = bills.where((b) => b.type == 'expense').toList();
      if (rankingFilterCategory.value != 'All') {
        expenseBills = expenseBills
            .where((b) => b.category == rankingFilterCategory.value)
            .toList();
      }
      expenseBills.sort((a, b) => b.amount.compareTo(a.amount));
      topExpenses.value = expenseBills.take(10).map((bill) {
        return {
          'id': bill.id,
          'category': bill.category,
          'subCategory': bill.subCategory,
          'amount': bill.amount,
          'date': bill.date,
          'note': bill.note,
        };
      }).toList();
      final dailyExpenses = <String, double>{};
      for (var bill in expenseBills) {
        dailyExpenses[bill.date] =
            (dailyExpenses[bill.date] ?? 0) + bill.amount;
      }
      final sortedDays = dailyExpenses.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topDays.value = sortedDays.take(10).map((entry) {
        return {'date': entry.key, 'amount': entry.value};
      }).toList();
    } catch (e) {
      print('Error loading ranking data: $e');
      topExpenses.value = [];
      topDays.value = [];
    }
  }

  void switchRankingTab(int index) {
    rankingTabIndex.value = index;
  }

  void switchRankingFilter(String category) {
    rankingFilterCategory.value = category;
    _loadRankingData();
  }

  List<String> get expenseCategories => [
    'All',
    'Food',
    'Transport',
    'Housing',
    'Shopping',
    'Social',
    'Medical',
    'Entertainment',
    'Education',
    'Communication',
    'Investment',
    'Pet',
    'Repayment',
    'Other',
  ];
  String getCategoryDisplay(Map<String, dynamic> bill) {
    final category = bill['category'] as String;
    final subCategory = bill['subCategory'] as String?;
    if (subCategory != null && subCategory.isNotEmpty) {
      return '$category-$subCategory';
    }
    return category;
  }

  String formatDateDisplay(String date) {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        final monthNames = [
          '',
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
        return '${monthNames[month]} $day';
      }
    } catch (e) {}
    return date;
  }
}

class MonthlyStats {
  final int month;
  final String yearMonth;
  final double income;
  final double expense;
  final double balance;
  MonthlyStats({
    required this.month,
    required this.yearMonth,
    required this.income,
    required this.expense,
    required this.balance,
  });
}
