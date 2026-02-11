import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../components/text_field.dart';
import '../../utils/colors.dart';
import 'pl_add_record_logic.dart';

class PlAddRecordPage extends GetView<PlAddRecordLogic> {
  const PlAddRecordPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlColors.bgColor,
      body: Obx(() {
        final isExpense = controller.currentTabIndex.value == 0;
        final themeColor = isExpense ? PlColors.secondary : PlColors.primary;
        return Column(
          children: [
            _buildHeader(isExpense, themeColor),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 12.h),
                    child: Text(
                      'Select Category',
                      style: TextStyle(
                        color: PlColors.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildCategoryGrid(
                      isExpense
                          ? controller.expenseCategories
                          : controller.incomeCategories,
                      themeColor,
                    ),
                  ),
                ],
              ),
            ),
            Obx(() {
              final keyboardVisible =
                  MediaQuery.of(context).viewInsets.bottom > 0;
              return controller.showCalculator.value && !keyboardVisible
                  ? _buildCalculator(themeColor)
                  : const SizedBox.shrink();
            }),
            Obx(() {
              return controller.showCalculator.value
                  ? const SizedBox.shrink()
                  : _buildBottomInfo(context, themeColor);
            }),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(bool isExpense, Color themeColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [themeColor, themeColor.withOpacity(0.85)],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 12.h,
            ).copyWith(left: 12.w, top: 40.h),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: controller.onCancelTap,
                ),
                const Spacer(),
                Obx(() {
                  controller.currentTabIndex.value;
                  return Text(
                    controller.pageTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.save, color: Colors.white),
                  onPressed: controller.onSaveTap,
                  tooltip: 'Save',
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    'Expense',
                    !isExpense,
                    () => controller.switchTab(0),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildTabButton(
                    'Income',
                    isExpense,
                    () => controller.switchTab(1),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 28.h),
          Padding(
            padding: EdgeInsets.only(left: 24.w),
            child: Column(
              children: [
                Text(
                  isExpense ? 'Expense Amount' : 'Income Amount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '\$',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Flexible(
                      child: Obx(
                        () => MyTextField(
                          value: controller.amount.value,
                          onChange: (val) => controller.amount.value = val,
                          isNumber: true,
                          hintText: '0.00',
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          textStyle: TextStyle(
                            fontSize: 48.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          hintStyle: TextStyle(
                            fontSize: 48.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.calculate_outlined,
                        color: Colors.white,
                        size: 28.w,
                      ),
                      onPressed: controller.toggleCalculator,
                      tooltip: 'Calculator',
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Obx(
                  () => controller.selectedCategory.value.isNotEmpty
                      ? Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          margin: EdgeInsets.only(bottom: 16.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20.w),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.category,
                                color: Colors.white,
                                size: 16.w,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                controller.getCategoryText(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, bool isInactive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: isInactive
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.w),
          border: Border.all(
            color: Colors.white.withOpacity(isInactive ? 0.3 : 0.6),
            width: isInactive ? 1 : 2,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: isInactive ? FontWeight.normal : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(
    List<Map<String, dynamic>> categories,
    Color themeColor,
  ) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 20.h,
        crossAxisSpacing: 16.w,
        childAspectRatio: 0.75,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Obx(() {
          final isSelected =
              controller.selectedCategory.value == category['name'];
          final Color categoryColor = category['color'] as Color;
          return _buildCategoryItem(
            category['name'] as String,
            category['icon'] as IconData,
            categoryColor,
            isSelected,
            themeColor,
            () => controller.selectCategory(
              category['name'] as String,
              category['hasSub'] as bool,
            ),
          );
        });
      },
    );
  }

  Widget _buildCategoryItem(
    String name,
    IconData icon,
    Color color,
    bool isSelected,
    Color themeColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: isSelected ? themeColor : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? themeColor : color.withOpacity(0.3),
                width: isSelected ? 3 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: themeColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 28.w,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            name,
            style: TextStyle(
              color: isSelected ? themeColor : PlColors.textPrimary,
              fontSize: 11.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCalculator(Color themeColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: controller.toggleCalculator,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: PlColors.bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 20.w,
                    color: PlColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          Obx(
            () => Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Text(
                controller.calcFormula.value.isEmpty
                    ? ' '
                    : controller.calcFormula.value,
                style: TextStyle(
                  color: PlColors.textSecondary,
                  fontSize: 14.sp,
                  height: 1.2,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          Obx(
            () => Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              child: Text(
                controller.calcDisplay.value,
                style: TextStyle(
                  color: themeColor,
                  fontSize: 32.sp,
                  height: 1.2,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          _buildCalculatorButtons(themeColor),
        ],
      ),
    );
  }

  Widget _buildCalculatorButtons(Color themeColor) {
    final buttons = [
      ['C', '⌫', '÷', '×'],
      ['7', '8', '9', '-'],
      ['4', '5', '6', '+'],
      ['1', '2', '3', '='],
      ['0', '.', '', ''],
    ];
    return Column(
      children: buttons.asMap().entries.map((entry) {
        final rowIndex = entry.key;
        final row = entry.value;
        return Padding(
          padding: EdgeInsets.only(
            bottom: rowIndex == buttons.length - 1 ? 0 : 8.h,
          ),
          child: Row(
            children: row.asMap().entries.map((btnEntry) {
              final colIndex = btnEntry.key;
              final btn = btnEntry.value;
              if (btn.isEmpty) return const Expanded(child: SizedBox());
              final isEquals = btn == '=' && rowIndex == 3;
              final isZero = btn == '0' && rowIndex == 4;
              return Expanded(
                flex: (isEquals || isZero) && colIndex == 0 ? 2 : 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: _buildCalcButton(btn, themeColor),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalcButton(String text, Color themeColor) {
    Color bgColor;
    Color textColor;
    if (text == '=') {
      bgColor = themeColor;
      textColor = Colors.white;
    } else if (text == 'C') {
      bgColor = const Color(0xFFE53935);
      textColor = Colors.white;
    } else if (['+', '-', '×', '÷'].contains(text)) {
      bgColor = PlColors.bgColor;
      textColor = themeColor;
    } else if (text == '⌫') {
      bgColor = PlColors.bgColor;
      textColor = PlColors.textSecondary;
    } else {
      bgColor = PlColors.bgColor;
      textColor = PlColors.textPrimary;
    }
    return GestureDetector(
      onTap: () => controller.onCalcButtonTap(text),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: text == '⌫' ? 20.sp : 18.sp,
              fontWeight: text == '=' || text == 'C'
                  ? FontWeight.bold
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInfo(BuildContext context, Color themeColor) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.w)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!controller.isTemplateMode)
            GestureDetector(
              onTap: () => controller.selectDate(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: PlColors.bgColor,
                  borderRadius: BorderRadius.circular(12.w),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 20.w,
                      color: themeColor,
                    ),
                    SizedBox(width: 12.w),
                    Obx(
                      () => Text(
                        controller.getDateText(),
                        style: TextStyle(
                          color: PlColors.textPrimary,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      size: 20.w,
                      color: PlColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          if (!controller.isTemplateMode) SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: PlColors.bgColor,
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Icon(
                    Icons.edit_note_outlined,
                    color: PlColors.textSecondary,
                    size: 22.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextField(
                    controller: controller.noteController,
                    maxLines: 2,
                    minLines: 1,
                    style: TextStyle(
                      color: PlColors.textPrimary,
                      fontSize: 14.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add a note (optional)',
                      hintStyle: TextStyle(
                        color: PlColors.textSecondary.withOpacity(0.6),
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                    ),
                    onChanged: (value) => controller.note.value = value,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom > 0 ? 8.h : 0,
          ),
        ],
      ),
    );
  }
}
