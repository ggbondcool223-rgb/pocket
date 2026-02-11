import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_ledger/db_pl/data.dart';
import 'package:pocket_ledger/db_pl/db_pl_entity.dart';
import 'package:pocket_ledger/utils/index.dart';

class PlBudgetSettingLogic extends GetxController {
  final PlDatabase _database = PlDatabase();
  final RxDouble monthlyBudget = 0.0.obs;
  final RxDouble monthlyExpense = 0.0.obs;
  final RxDouble remainingBudget = 0.0.obs;
  final RxDouble progress = 0.0.obs;
  final RxString currentMonth = ''.obs;
  final RxBool isLoading = true.obs;
  final RxList<BudgetEntity> categoryBudgets = <BudgetEntity>[].obs;
  final RxInt currentTabIndex = 0.obs;
  @override
  void onInit() {
    super.onInit();
    _initCurrentMonth();
    loadBudgetData();
  }

  void _initCurrentMonth() {
    final now = DateTime.now();
    currentMonth.value = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<void> loadBudgetData() async {
    try {
      isLoading.value = true;
      final budget = await _database.getBudgetByMonth(
        currentMonth.value,
        category: null,
      );
      monthlyBudget.value = budget?.amount ?? 0.0;
      final expense = await _database.getTotalAmountByMonth(
        currentMonth.value,
        'expense',
      );
      monthlyExpense.value = expense;
      remainingBudget.value = monthlyBudget.value - monthlyExpense.value;
      if (monthlyBudget.value > 0) {
        progress.value = (monthlyExpense.value / monthlyBudget.value).clamp(
          0.0,
          1.0,
        );
      } else {
        progress.value = 0.0;
      }
      await loadCategoryBudgets();
    } catch (e) {
      errorToast('Failed to load budget data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCategoryBudgets() async {
    try {
      categoryBudgets.value = await _database.getCategoryBudgetsByMonth(
        currentMonth.value,
      );
    } catch (e) {
      errorToast('Failed to load category budgets: ${e.toString()}');
    }
  }

  Future<void> saveBudget(double amount) async {
    if (amount <= 0) {
      errorToast('Budget amount must be greater than 0');
      return;
    }
    try {
      final existingBudget = await _database.getBudgetByMonth(
        currentMonth.value,
        category: null,
      );
      if (existingBudget != null) {
        final updatedBudget = BudgetEntity(
          id: existingBudget.id,
          month: currentMonth.value,
          amount: amount,
          category: null,
          createdAt: existingBudget.createdAt,
        );
        await _database.updateBudget(updatedBudget);
      } else {
        final newBudget = BudgetEntity(
          month: currentMonth.value,
          amount: amount,
          category: null,
          createdAt: DateTime.now().toIso8601String(),
        );
        await _database.insertBudget(newBudget);
      }
      successToast('Budget saved successfully');
      await loadBudgetData();
    } catch (e) {
      errorToast('Failed to save budget: ${e.toString()}');
    }
  }

  Future<void> saveCategoryBudget(String category, double amount) async {
    if (amount <= 0) {
      errorToast('Budget amount must be greater than 0');
      return;
    }
    try {
      final existingBudget = await _database.getBudgetByMonth(
        currentMonth.value,
        category: category,
      );
      if (existingBudget != null) {
        final updatedBudget = BudgetEntity(
          id: existingBudget.id,
          month: currentMonth.value,
          amount: amount,
          category: category,
          createdAt: existingBudget.createdAt,
        );
        await _database.updateBudget(updatedBudget);
      } else {
        final newBudget = BudgetEntity(
          month: currentMonth.value,
          amount: amount,
          category: category,
          createdAt: DateTime.now().toIso8601String(),
        );
        await _database.insertBudget(newBudget);
      }
      successToast('Category budget saved successfully');
      await loadCategoryBudgets();
    } catch (e) {
      errorToast('Failed to save category budget: ${e.toString()}');
    }
  }

  Future<void> deleteBudget() async {
    try {
      final existingBudget = await _database.getBudgetByMonth(
        currentMonth.value,
        category: null,
      );
      if (existingBudget != null && existingBudget.id != null) {
        await _database.deleteBudget(existingBudget.id!);
        successToast('Budget deleted successfully');
        await loadBudgetData();
      } else {
        errorToast('No budget to delete');
      }
    } catch (e) {
      errorToast('Failed to delete budget: ${e.toString()}');
    }
  }

  Future<void> deleteCategoryBudget(int budgetId) async {
    try {
      await _database.deleteBudget(budgetId);
      successToast('Category budget deleted successfully');
      await loadCategoryBudgets();
    } catch (e) {
      errorToast('Failed to delete category budget: ${e.toString()}');
    }
  }

  Future<double> getCategoryExpense(String category) async {
    try {
      final categoryAmounts = await _database.getCategoryAmountsByMonth(
        currentMonth.value,
        'expense',
      );
      return categoryAmounts[category] ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  void switchTab(int index) {
    currentTabIndex.value = index;
  }

  List<String> get expenseCategories => [
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
  Future<void> showCategoryBudgetDialog() async {
    final usedCategories = categoryBudgets.map((b) => b.category!).toList();
    final availableCategories = expenseCategories
        .where((cat) => !usedCategories.contains(cat))
        .toList();
    if (availableCategories.isEmpty) {
      errorToast('All categories already have budgets');
      return;
    }
    String? selectedCategory = availableCategories.first;
    final TextEditingController amountController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Set Category Budget'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  items: availableCategories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Enter budget amount',
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                  ),
                  autofocus: true,
                  onSubmitted: (value) {
                    final amount = double.tryParse(value);
                    if (amount != null &&
                        amount > 0 &&
                        selectedCategory != null) {
                      Get.back();
                      saveCategoryBudget(selectedCategory!, amount);
                    }
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final value = amountController.text.trim();
              if (value.isEmpty) {
                Get.back();
                return;
              }
              final amount = double.tryParse(value);
              if (amount != null && amount > 0 && selectedCategory != null) {
                Get.back();
                saveCategoryBudget(selectedCategory!, amount);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  String formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }

  bool get hasBudget => monthlyBudget.value > 0;
  String get budgetDisplayText {
    if (!hasBudget) {
      return 'No Budget';
    } else if (remainingBudget.value < 0) {
      return 'Over Budget';
    } else {
      return '\$${formatAmount(remainingBudget.value)}';
    }
  }

  Color get progressColor {
    if (!hasBudget) {
      return const Color(0xFFE0E0E0);
    } else if (progress.value >= 1.0) {
      return const Color(0xFFE53935);
    } else if (progress.value >= 0.8) {
      return const Color(0xFFFFA726);
    } else {
      return const Color(0xFF6B8EFF);
    }
  }
}
