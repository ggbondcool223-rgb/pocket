import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../db_pl/data.dart';
import '../../db_pl/db_pl_entity.dart';
import '../../utils/index.dart' as utils;

class PlTemplateManageLogic extends GetxController {
  final PlDatabase _db = PlDatabase();
  final RxList<TemplateEntity> templates = <TemplateEntity>[].obs;
  final RxBool isLoading = false.obs;
  @override
  void onInit() {
    super.onInit();
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    try {
      isLoading.value = true;
      templates.value = await _db.getAllTemplates();
    } catch (e) {
      utils.errorToast('Failed to load templates: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTemplate(int id) async {
    try {
      await _db.deleteTemplate(id);
      templates.removeWhere((t) => t.id == id);
      utils.successToast('Template deleted successfully');
    } catch (e) {
      utils.errorToast('Failed to delete template: $e');
    }
  }

  void showAddTemplateDialog() {
    final TextEditingController nameController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Create Template'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Template name (e.g., Monthly Rent)',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                utils.errorToast('Please enter template name');
                return;
              }
              Get.back();
              _navigateToCreateTemplate(name);
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateTemplate(String templateName) async {
    final result = await Get.toNamed(
      '/add_record',
      arguments: {'mode': 'template', 'templateName': templateName},
    );
    if (result == true) {
      loadTemplates();
    }
  }

  void showEditTemplateDialog(TemplateEntity template) async {
    final result = await Get.toNamed(
      '/add_record',
      arguments: {'mode': 'edit_template', 'template': template},
    );
    if (result == true) {
      loadTemplates();
    }
  }

  String getCategoryText(TemplateEntity template) {
    if (template.subCategory != null && template.subCategory!.isNotEmpty) {
      return '${template.category}-${template.subCategory}';
    }
    return template.category;
  }

  String getTypeText(TemplateEntity template) {
    return template.type == 'expense' ? 'Expense' : 'Income';
  }

  Color getTypeColor(TemplateEntity template) {
    return template.type == 'expense'
        ? const Color(0xFFE53935)
        : const Color(0xFF2E7D32);
  }
}
