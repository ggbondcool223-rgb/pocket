import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../db_pl/data.dart';
import '../../db_pl/db_pl_entity.dart';
import '../../utils/index.dart' as utils;
class PlAddRecordLogic extends GetxController {
  final PlDatabase _db = PlDatabase();
  final RxInt currentTabIndex = 0.obs;
  final RxString selectedCategory = ''.obs;
  final RxString selectedSubCategory = ''.obs;
  final RxString amount = ''.obs;
  final TextEditingController amountController = TextEditingController();
  final RxString calcDisplay = '0'.obs;
  final RxString calcFormula = ''.obs;
  final RxBool showCalculator = false.obs;
  String _currentNumber = '';
  String _operator = '';
  double _firstNumber = 0;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString note = ''.obs;
  final TextEditingController noteController = TextEditingController();
  String? _templateMode;
  String? _templateName;
  TemplateEntity? _editingTemplate;
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map) {
      _templateMode = args['mode'];
      _templateName = args['templateName'];
      _editingTemplate = args['template'];
      if (_templateMode == 'edit_template' && _editingTemplate != null) {
        currentTabIndex.value = _editingTemplate!.type == 'expense' ? 0 : 1;
        selectedCategory.value = _editingTemplate!.category;
        selectedSubCategory.value = _editingTemplate!.subCategory ?? '';
        amount.value = _editingTemplate!.amount.toStringAsFixed(2);
        note.value = _editingTemplate!.note ?? '';
        noteController.text = _editingTemplate!.note ?? '';
        _templateName = _editingTemplate!.name;
      }
    }
  }
  final expenseCategories = [
    {
      'name': 'Food',
      'icon': Icons.restaurant,
      'color': const Color(0xFFFFB84D),
      'hasSub': true,
    },
    {
      'name': 'Transport',
      'icon': Icons.directions_bus,
      'color': const Color(0xFF66BB6A),
      'hasSub': true,
    },
    {
      'name': 'Housing',
      'icon': Icons.apartment,
      'color': const Color(0xFFFF8A65),
      'hasSub': true,
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag,
      'color': const Color(0xFFBA68C8),
      'hasSub': true,
    },
    {
      'name': 'Social',
      'icon': Icons.card_giftcard,
      'color': const Color(0xFFFFD54F),
      'hasSub': true,
    },
    {
      'name': 'Medical',
      'icon': Icons.medical_services,
      'color': const Color(0xFF4FC3F7),
      'hasSub': true,
    },
    {
      'name': 'Entertainment',
      'icon': Icons.games,
      'color': const Color(0xFFBA68C8),
      'hasSub': true,
    },
    {
      'name': 'Education',
      'icon': Icons.school,
      'color': const Color(0xFF66BB6A),
      'hasSub': true,
    },
    {
      'name': 'Communication',
      'icon': Icons.phone,
      'color': const Color(0xFFFFB84D),
      'hasSub': true,
    },
    {
      'name': 'Investment',
      'icon': Icons.trending_up,
      'color': const Color(0xFFFF8A65),
      'hasSub': true,
    },
    {
      'name': 'Pet',
      'icon': Icons.pets,
      'color': const Color(0xFFFF8A65),
      'hasSub': true,
    },
    {
      'name': 'Repayment',
      'icon': Icons.credit_card,
      'color': const Color(0xFFFFB84D),
      'hasSub': true,
    },
    {
      'name': 'Other',
      'icon': Icons.more_horiz,
      'color': const Color(0xFF4FC3F7),
      'hasSub': true,
    },
  ];
  final incomeCategories = [
    {
      'name': 'Salary',
      'icon': Icons.receipt_long,
      'color': const Color(0xFF4FC3F7),
      'hasSub': false,
    },
    {
      'name': 'Business',
      'icon': Icons.storefront,
      'color': const Color(0xFF66BB6A),
      'hasSub': false,
    },
    {
      'name': 'Part-time',
      'icon': Icons.work_outline,
      'color': const Color(0xFFFFB84D),
      'hasSub': false,
    },
    {
      'name': 'Interest',
      'icon': Icons.attach_money,
      'color': const Color(0xFFBA68C8),
      'hasSub': false,
    },
    {
      'name': 'Other',
      'icon': Icons.more_horiz,
      'color': const Color(0xFF4FC3F7),
      'hasSub': false,
    },
    {
      'name': 'Stock',
      'icon': Icons.show_chart,
      'color': const Color(0xFFFF8A65),
      'hasSub': false,
    },
    {
      'name': 'Fund',
      'icon': Icons.account_balance,
      'color': const Color(0xFFFFB84D),
      'hasSub': false,
    },
    {
      'name': 'Futures',
      'icon': Icons.pie_chart,
      'color': const Color(0xFFBA68C8),
      'hasSub': false,
    },
    {
      'name': 'Lottery',
      'icon': Icons.card_giftcard,
      'color': const Color(0xFFFF8A65),
      'hasSub': false,
    },
    {
      'name': 'Gift',
      'icon': Icons.redeem,
      'color': const Color(0xFFFFB84D),
      'hasSub': false,
    },
  ];
  final Map<String, List<Map<String, dynamic>>> subCategories = {
    'Food': [
      {'name': 'Breakfast', 'icon': Icons.free_breakfast},
      {'name': 'Lunch', 'icon': Icons.lunch_dining},
      {'name': 'Dinner', 'icon': Icons.dinner_dining},
      {'name': 'Snack', 'icon': Icons.cookie},
      {'name': 'Drink', 'icon': Icons.local_cafe},
      {'name': 'Groceries', 'icon': Icons.shopping_basket},
      {'name': 'Fruit', 'icon': Icons.apple},
    ],
    'Transport': [
      {'name': 'Taxi', 'icon': Icons.local_taxi},
      {'name': 'Bus', 'icon': Icons.directions_bus},
      {'name': 'Subway', 'icon': Icons.subway},
      {'name': 'Bike', 'icon': Icons.directions_bike},
      {'name': 'Train', 'icon': Icons.train},
      {'name': 'Flight', 'icon': Icons.flight},
    ],
    'Shopping': [
      {'name': 'Clothing', 'icon': Icons.checkroom},
      {'name': 'Bag', 'icon': Icons.shopping_bag},
      {'name': 'Cosmetics', 'icon': Icons.face_retouching_natural},
      {'name': 'Daily', 'icon': Icons.receipt},
    ],
    'Housing': [
      {'name': 'Rent', 'icon': Icons.home},
      {'name': 'Property', 'icon': Icons.cottage},
      {'name': 'Utility', 'icon': Icons.bolt},
      {'name': 'Repair', 'icon': Icons.build},
      {'name': 'Mortgage', 'icon': Icons.account_balance},
    ],
    'Social': [
      {'name': 'Gift', 'icon': Icons.card_giftcard},
      {'name': 'Red Envelope', 'icon': Icons.redeem},
      {'name': 'Wedding', 'icon': Icons.favorite},
      {'name': 'Birthday', 'icon': Icons.cake},
      {'name': 'Charity', 'icon': Icons.volunteer_activism},
      {'name': 'Party', 'icon': Icons.celebration},
    ],
    'Medical': [
      {'name': 'Clinic', 'icon': Icons.local_hospital},
      {'name': 'Pharmacy', 'icon': Icons.medication},
      {'name': 'Hospital', 'icon': Icons.medical_services},
      {'name': 'Health Check', 'icon': Icons.health_and_safety},
      {'name': 'Dental', 'icon': Icons.emoji_emotions},
      {'name': 'Eye Care', 'icon': Icons.remove_red_eye},
    ],
    'Entertainment': [
      {'name': 'Movie', 'icon': Icons.movie},
      {'name': 'Concert', 'icon': Icons.music_note},
      {'name': 'Game', 'icon': Icons.games},
      {'name': 'KTV', 'icon': Icons.mic},
      {'name': 'Sports', 'icon': Icons.sports_basketball},
      {'name': 'Travel', 'icon': Icons.luggage},
    ],
    'Education': [
      {'name': 'Tuition', 'icon': Icons.school},
      {'name': 'Books', 'icon': Icons.menu_book},
      {'name': 'Course', 'icon': Icons.class_},
      {'name': 'Training', 'icon': Icons.model_training},
      {'name': 'Exam', 'icon': Icons.quiz},
      {'name': 'Stationery', 'icon': Icons.edit},
    ],
    'Communication': [
      {'name': 'Phone Bill', 'icon': Icons.phone},
      {'name': 'Internet', 'icon': Icons.wifi},
      {'name': 'Mobile Data', 'icon': Icons.signal_cellular_alt},
      {'name': 'Postage', 'icon': Icons.mail},
      {'name': 'Subscription', 'icon': Icons.subscriptions},
    ],
    'Investment': [
      {'name': 'Stock', 'icon': Icons.show_chart},
      {'name': 'Fund', 'icon': Icons.account_balance},
      {'name': 'Insurance', 'icon': Icons.security},
      {'name': 'Real Estate', 'icon': Icons.location_city},
      {'name': 'Crypto', 'icon': Icons.currency_bitcoin},
      {'name': 'Bond', 'icon': Icons.attach_money},
    ],
    'Pet': [
      {'name': 'Food', 'icon': Icons.pets},
      {'name': 'Medical', 'icon': Icons.medical_services},
      {'name': 'Grooming', 'icon': Icons.content_cut},
      {'name': 'Toys', 'icon': Icons.toys},
      {'name': 'Supplies', 'icon': Icons.shopping_bag},
      {'name': 'Boarding', 'icon': Icons.hotel},
    ],
    'Repayment': [
      {'name': 'Credit Card', 'icon': Icons.credit_card},
      {'name': 'Loan', 'icon': Icons.account_balance_wallet},
      {'name': 'Mortgage', 'icon': Icons.home},
      {'name': 'Car Loan', 'icon': Icons.directions_car},
      {'name': 'Personal Loan', 'icon': Icons.person},
    ],
    'Other': [
      {'name': 'Miscellaneous', 'icon': Icons.more_horiz},
      {'name': 'Fine', 'icon': Icons.gavel},
      {'name': 'Tax', 'icon': Icons.request_quote},
      {'name': 'Service Fee', 'icon': Icons.receipt_long},
      {'name': 'Donation', 'icon': Icons.volunteer_activism},
      {'name': 'Lost', 'icon': Icons.search_off},
    ],
  };
  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }
  void switchTab(int index) {
    currentTabIndex.value = index;
    selectedCategory.value = '';
    selectedSubCategory.value = '';
  }
  void selectCategory(String category, bool hasSub) {
    selectedCategory.value = category;
    selectedSubCategory.value = '';
    if (hasSub) {
      _showSubCategoryDialog(category);
    }
  }
  void _showSubCategoryDialog(String category) {
    final subs = subCategories[category] ?? [];
    if (subs.isEmpty) {
      selectedSubCategory.value = '';
      return;
    }
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Select Subcategory',
                style: TextStyle(
                  color: const Color(0xFF212121),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: subs.length,
                itemBuilder: (context, index) {
                  final sub = subs[index];
                  final subName = sub['name'] as String;
                  final subIcon = sub['icon'] as IconData;
                  final themeColor = currentTabIndex.value == 0
                      ? const Color(0xFF1976D2)
                      : const Color(0xFF2E7D32);
                  return GestureDetector(
                    onTap: () {
                      selectedSubCategory.value = subName;
                      Get.back();
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F8FA),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(subIcon, color: themeColor, size: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subName,
                          style: const TextStyle(
                            color: Color(0xFF424242),
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
      enterBottomSheetDuration: const Duration(milliseconds: 250),
      exitBottomSheetDuration: const Duration(milliseconds: 200),
    ).then((_) {
    });
  }
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E7D32),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF212121),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }
  Future<void> onSaveTap() async {
    if (amount.value.isEmpty || double.tryParse(amount.value) == null) {
      utils.errorToast('Please enter amount');
      return;
    }
    final amountValue = double.parse(amount.value);
    if (amountValue <= 0) {
      utils.errorToast('Amount must be greater than 0');
      return;
    }
    if (selectedCategory.value.isEmpty) {
      utils.errorToast('Please select category');
      return;
    }
    final currentCategories = currentTabIndex.value == 0
        ? expenseCategories
        : incomeCategories;
    final categoryConfig = currentCategories.firstWhereOrNull(
      (cat) => cat['name'] == selectedCategory.value,
    );
    if (categoryConfig != null && categoryConfig['hasSub'] == true) {
      if (selectedSubCategory.value.isEmpty) {
        utils.errorToast('Please select subcategory');
        return;
      }
    }
    try {
      final now = DateTime.now().toIso8601String();
      if (_templateMode == 'template' || _templateMode == 'edit_template') {
        if (_templateName == null || _templateName!.isEmpty) {
          utils.errorToast('Template name is required');
          return;
        }
        final template = TemplateEntity(
          id: _editingTemplate?.id,
          name: _templateName!,
          type: currentTabIndex.value == 0 ? 'expense' : 'income',
          category: selectedCategory.value,
          subCategory: selectedSubCategory.value.isEmpty
              ? null
              : selectedSubCategory.value,
          amount: amountValue,
          note: note.value.isEmpty ? null : note.value,
          createdAt: _editingTemplate?.createdAt ?? now,
          updatedAt: now,
        );
        if (_templateMode == 'edit_template') {
          await _db.updateTemplate(template);
          utils.successToast('Template updated successfully');
        } else {
          await _db.insertTemplate(template);
          utils.successToast('Template created successfully');
        }
        Get.back(result: true);
        return;
      }
      final bill = BillEntity(
        type: currentTabIndex.value == 0 ? 'expense' : 'income',
        category: selectedCategory.value,
        subCategory: selectedSubCategory.value.isEmpty
            ? null
            : selectedSubCategory.value,
        amount: amountValue,
        date: utils.getDateString(selectedDate.value),
        note: note.value.isEmpty ? null : note.value,
        createdAt: now,
        updatedAt: now,
      );
      await _db.insertBill(bill);
      utils.successToast('Record saved successfully');
      Get.back(result: true);
    } catch (e) {
      utils.errorToast('Failed to save: $e');
    }
  }
  bool get isTemplateMode =>
      _templateMode == 'template' || _templateMode == 'edit_template';
  String get pageTitle {
    if (_templateMode == 'template') {
      return currentTabIndex.value == 0
          ? 'Create Expense Template'
          : 'Create Income Template';
    } else if (_templateMode == 'edit_template') {
      return 'Edit Template';
    }
    return currentTabIndex.value == 0 ? 'Add Expense' : 'Add Income';
  }
  void onCancelTap() {
    if (amount.value.isNotEmpty ||
        selectedCategory.value.isNotEmpty ||
        note.value.isNotEmpty) {
      Get.dialog(
        AlertDialog(
          title: const Text('Discard this record?'),
          content: const Text('Your changes will not be saved.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF757575)),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              child: const Text(
                'Discard',
                style: TextStyle(color: Color(0xFFD32F2F)),
              ),
            ),
          ],
        ),
      );
    } else {
      Get.back();
    }
  }
  String getDateText() {
    final now = DateTime.now();
    final selected = selectedDate.value;
    if (selected.year == now.year &&
        selected.month == now.month &&
        selected.day == now.day) {
      return 'Today';
    }
    return utils.getDateString(selected);
  }
  String getCategoryText() {
    if (selectedCategory.value.isEmpty) {
      return 'Please select';
    }
    if (selectedSubCategory.value.isEmpty) {
      return selectedCategory.value;
    }
    return '${selectedCategory.value}-${selectedSubCategory.value}';
  }
  void toggleCalculator() {
    showCalculator.value = !showCalculator.value;
    if (showCalculator.value) {
      if (amount.value.isNotEmpty) {
        calcDisplay.value = amount.value;
        _currentNumber = amount.value;
      } else {
        calcDisplay.value = '0';
        _currentNumber = '';
      }
      calcFormula.value = '';
      _operator = '';
      _firstNumber = 0;
    }
  }
  void onCalcButtonTap(String value) {
    switch (value) {
      case 'C':
        _clearCalculator();
        break;
      case '⌫':
        _deleteLastDigit();
        break;
      case '=':
        _calculate();
        break;
      case '+':
      case '-':
      case '×':
      case '÷':
        _handleOperator(value);
        break;
      case '.':
        _handleDecimalPoint();
        break;
      default:
        _handleNumber(value);
        break;
    }
  }
  void _clearCalculator() {
    calcDisplay.value = '0';
    calcFormula.value = '';
    _currentNumber = '';
    _operator = '';
    _firstNumber = 0;
  }
  void _deleteLastDigit() {
    if (_currentNumber.isEmpty) return;
    _currentNumber = _currentNumber.substring(0, _currentNumber.length - 1);
    calcDisplay.value = _currentNumber.isEmpty ? '0' : _currentNumber;
  }
  void _handleNumber(String num) {
    if (_currentNumber.contains('.')) {
      final parts = _currentNumber.split('.');
      if (parts.length > 1 && parts[1].length >= 2) {
        return;
      }
    }
    if (_currentNumber == '0' && num != '.') {
      _currentNumber = num;
    } else {
      _currentNumber += num;
    }
    calcDisplay.value = _currentNumber;
  }
  void _handleDecimalPoint() {
    if (!_currentNumber.contains('.')) {
      if (_currentNumber.isEmpty) {
        _currentNumber = '0.';
      } else {
        _currentNumber += '.';
      }
      calcDisplay.value = _currentNumber;
    }
  }
  void _handleOperator(String op) {
    if (_currentNumber.isEmpty && _operator.isEmpty) return;
    if (_operator.isNotEmpty && _currentNumber.isNotEmpty) {
      _calculate();
    }
    if (_currentNumber.isNotEmpty) {
      _firstNumber = double.tryParse(_currentNumber) ?? 0;
    }
    _operator = op;
    calcFormula.value =
        '${_firstNumber.toStringAsFixed(_firstNumber.truncateToDouble() == _firstNumber ? 0 : 2)} $op ';
    _currentNumber = '';
  }
  void _calculate() {
    if (_operator.isEmpty || _currentNumber.isEmpty) {
      if (_currentNumber.isNotEmpty) {
        final result = double.tryParse(_currentNumber) ?? 0;
        amount.value = result.toStringAsFixed(2);
        showCalculator.value = false;
      }
      return;
    }
    final secondNumber = double.tryParse(_currentNumber) ?? 0;
    double result = 0;
    switch (_operator) {
      case '+':
        result = _firstNumber + secondNumber;
        break;
      case '-':
        result = _firstNumber - secondNumber;
        break;
      case '×':
        result = _firstNumber * secondNumber;
        break;
      case '÷':
        if (secondNumber == 0) {
          utils.errorToast('Cannot divide by zero');
          return;
        }
        result = _firstNumber / secondNumber;
        break;
    }
    final formattedResult = result.toStringAsFixed(2);
    amount.value = formattedResult;
    calcDisplay.value = formattedResult;
    calcFormula.value = '';
    _currentNumber = formattedResult;
    _operator = '';
    _firstNumber = 0;
    showCalculator.value = false;
  }
}
