import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_ledger/db_pl/data.dart';
import 'package:pocket_ledger/db_pl/db_pl_entity.dart';
import 'package:pocket_ledger/utils/index.dart';
class PlHomeLogic extends GetxController {
  final PlDatabase _db = PlDatabase();
  final RxString currentDate = ''.obs;
  final RxString currentMonth = ''.obs;
  final RxDouble monthlyIncome = 0.0.obs;
  final RxDouble monthlyExpense = 0.0.obs;
  final RxDouble remainingBudget = 0.0.obs;
  final RxDouble monthlyBudget = 0.0.obs;
  final RxBool isOverBudget = false.obs;
  final RxBool isBudgetAlert = false.obs;
  final RxList<BillEntity> todayBills = <BillEntity>[].obs;
  final RxDouble dailyIncome = 0.0.obs;
  final RxDouble dailyExpense = 0.0.obs;
  final RxDouble dailyBalance = 0.0.obs;
  final RxDouble lastMonthIncome = 0.0.obs;
  final RxDouble lastMonthExpense = 0.0.obs;
  final RxDouble incomeChange = 0.0.obs;
  final RxDouble expenseChange = 0.0.obs;
  final RxBool showComparison = false.obs;
  final RxList<TemplateEntity> quickTemplates = <TemplateEntity>[].obs;
  final RxList<Map<String, dynamic>> categoryBudgetAlerts = <Map<String, dynamic>>[].obs;
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
    currentDate.value = getDateString(now);
    currentMonth.value = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }
  Future<void> loadData() async {
    try {
      await Future.wait([
        _loadMonthlyData(),
        _loadTodayBills(),
        _loadMonthlyComparison(),
        _loadQuickTemplates(),
        _loadCategoryBudgetAlerts(),
      ]);
    } catch (e) {
      print('Error loading home data: $e');
    }
  }
  Future<void> _loadMonthlyData() async {
    try {
      final income = await _db.getTotalAmountByMonth(currentMonth.value, 'income');
      final expense = await _db.getTotalAmountByMonth(currentMonth.value, 'expense');
      monthlyIncome.value = income;
      monthlyExpense.value = expense;
      final budget = await _db.getBudgetByMonth(currentMonth.value, category: null);
      if (budget != null) {
        monthlyBudget.value = budget.amount;
        remainingBudget.value = budget.amount - expense;
        if (expense > budget.amount) {
          isOverBudget.value = true;
          isBudgetAlert.value = false;
        } else if (expense >= budget.amount * 0.8) {
          isOverBudget.value = false;
          isBudgetAlert.value = true;
        } else {
          isOverBudget.value = false;
          isBudgetAlert.value = false;
        }
      } else {
        monthlyBudget.value = 0.0;
        remainingBudget.value = 0.0;
        isOverBudget.value = false;
        isBudgetAlert.value = false;
      }
    } catch (e) {
      print('Error loading monthly data: $e');
    }
  }
  Future<void> _loadTodayBills() async {
    try {
      final bills = await _db.getBillsByDate(currentDate.value);
      todayBills.value = bills;
      final income = await _db.getTotalAmountByDate(currentDate.value, 'income');
      final expense = await _db.getTotalAmountByDate(currentDate.value, 'expense');
      dailyIncome.value = income;
      dailyExpense.value = expense;
      dailyBalance.value = income - expense;
    } catch (e) {
      print('Error loading today bills: $e');
    }
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
  void onBillTap(BillEntity bill) {
  }
  void refreshData() {
    loadData();
  }
  Future<void> _loadMonthlyComparison() async {
    try {
      final now = DateTime.now();
      final lastMonth = DateTime(now.year, now.month - 1, 1);
      final lastMonthStr = '${lastMonth.year}-${lastMonth.month.toString().padLeft(2, '0')}';
      final lastIncome = await _db.getTotalAmountByMonth(lastMonthStr, 'income');
      final lastExpense = await _db.getTotalAmountByMonth(lastMonthStr, 'expense');
      lastMonthIncome.value = lastIncome;
      lastMonthExpense.value = lastExpense;
      if (lastIncome > 0) {
        incomeChange.value = ((monthlyIncome.value - lastIncome) / lastIncome) * 100;
      } else {
        incomeChange.value = monthlyIncome.value > 0 ? 100.0 : 0.0;
      }
      if (lastExpense > 0) {
        expenseChange.value = ((monthlyExpense.value - lastExpense) / lastExpense) * 100;
      } else {
        expenseChange.value = monthlyExpense.value > 0 ? 100.0 : 0.0;
      }
      showComparison.value = lastIncome > 0 || lastExpense > 0;
    } catch (e) {
      print('Error loading monthly comparison: $e');
      showComparison.value = false;
    }
  }
  String getChangeText(double change) {
    if (change > 0) {
      return '+${change.toStringAsFixed(1)}%';
    } else if (change < 0) {
      return '${change.toStringAsFixed(1)}%';
    } else {
      return '0%';
    }
  }
  Color getChangeColor(double change, bool isExpense) {
    if (change == 0) return const Color(0xFF757575);
    if (isExpense) {
      return change > 0 ? const Color(0xFFE53935) : const Color(0xFF2E7D32);
    } else {
      return change > 0 ? const Color(0xFF2E7D32) : const Color(0xFFE53935);
    }
  }
  void toggleComparison() {
    showComparison.value = !showComparison.value;
  }
  Future<void> _loadQuickTemplates() async {
    try {
      final templates = await _db.getAllTemplates();
      quickTemplates.value = templates.take(3).toList();
    } catch (e) {
      print('Error loading quick templates: $e');
      quickTemplates.value = [];
    }
  }
  Future<void> createBillFromTemplate(TemplateEntity template) async {
    try {
      final now = DateTime.now().toIso8601String();
      final bill = BillEntity(
        type: template.type,
        category: template.category,
        subCategory: template.subCategory,
        amount: template.amount,
        date: getDateString(DateTime.now()),
        note: template.note,
        createdAt: now,
        updatedAt: now,
      );
      await _db.insertBill(bill);
      successToast('Bill created from template');
      await loadData();
    } catch (e) {
      errorToast('Failed to create bill: $e');
    }
  }
  Future<void> _loadCategoryBudgetAlerts() async {
    try {
      final alerts = <Map<String, dynamic>>[];
      final budgets = await _db.getCategoryBudgetsByMonth(currentMonth.value);
      print('🔍 [DEBUG] Category budgets found: ${budgets.length}');
      for (var budget in budgets) {
        if (budget.category == null) continue;
        print('🔍 [DEBUG] Checking budget for: ${budget.category}');
        final categoryAmounts = await _db.getCategoryAmountsByMonth(
          currentMonth.value,
          'expense',
        );
        final expense = categoryAmounts[budget.category] ?? 0.0;
        print('🔍 [DEBUG] ${budget.category} - Budget: \$${budget.amount}, Expense: \$${expense}');
        final usage = budget.amount > 0 ? (expense / budget.amount) : 0.0;
        print('🔍 [DEBUG] ${budget.category} - Usage: ${(usage * 100).toStringAsFixed(1)}%');
        if (usage >= 0.5) {
          print('✅ [DEBUG] Adding alert for ${budget.category}');
          String alertLevel;
          if (usage >= 1.0) {
            alertLevel = 'exceeded';
          } else if (usage >= 0.8) {
            alertLevel = 'critical';
          } else {
            alertLevel = 'warning';
          }
          alerts.add({
            'category': budget.category,
            'budget': budget.amount,
            'expense': expense,
            'usage': usage,
            'isOverBudget': usage >= 1.0,
            'alertLevel': alertLevel,
          });
        }
      }
      print('🔍 [DEBUG] Total alerts: ${alerts.length}');
      categoryBudgetAlerts.value = alerts;
    } catch (e) {
      print('❌ Error loading category budget alerts: $e');
      categoryBudgetAlerts.value = [];
    }
  }
  String getTemplateDisplay(TemplateEntity template) {
    if (template.subCategory != null && template.subCategory!.isNotEmpty) {
      return '${template.category}-${template.subCategory}';
    }
    return template.category;
  }
}
