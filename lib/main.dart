import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_ledger/pages/pl_main/pl_main_binding.dart';
import 'package:pocket_ledger/pages/pl_main/pl_main_view.dart';
import 'package:pocket_ledger/pages/pl_add_record/pl_add_record_binding.dart';
import 'package:pocket_ledger/pages/pl_add_record/pl_add_record_view.dart';
import 'package:pocket_ledger/pages/pl_budget_setting/pl_budget_setting_binding.dart';
import 'package:pocket_ledger/pages/pl_budget_setting/pl_budget_setting_view.dart';
import 'package:pocket_ledger/pages/pl_mind/pl_mind_binding.dart';
import 'package:pocket_ledger/pages/pl_mind/pl_mind_view.dart';
import 'package:pocket_ledger/pages/pl_settings/pl_settings_leger.dart';
import 'package:pocket_ledger/pages/pl_template_manage/pl_template_manage_binding.dart';
import 'package:pocket_ledger/pages/pl_template_manage/pl_template_manage_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pocket_ledger/utils/colors.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Pocket Ledger',
          debugShowCheckedModeBanner: false,
          getPages: Pocket,
          initialRoute: '/',
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: PlColors.primary,
            scaffoldBackgroundColor: PlColors.bgColor,
            colorScheme: const ColorScheme.light(
              primary: PlColors.primary,
              secondary: PlColors.secondary,
              surface: Colors.white,
              error: PlColors.warning,
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: PlColors.textPrimary,
              ),
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(size: 22, color: PlColors.textPrimary),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedItemColor: PlColors.primary,
              unselectedItemColor: PlColors.textSecondary,
              elevation: 8,
              backgroundColor: Colors.white,
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            dividerTheme: DividerThemeData(
              thickness: 1,
              color: Colors.grey[200],
            ),
          ),
          builder: (context, child) {
            return GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: child,
            );
          },
        );
      },
    );
  }
}
List<GetPage<dynamic>> Pocket = [
  GetPage(
    name: '/',
    page: () => const PlMindView(),
    binding: PlMindBinding(),
  ),
  GetPage(
    name: '/main',
    page: () => const PlMainPage(),
    binding: PlMainBinding(),
  ),
  GetPage(
    name: '/add_record',
    page: () => const PlAddRecordPage(),
    binding: PlAddRecordBinding(),
  ),
  GetPage(
    name: '/setting_leger',
    page: () => const PlSettingsLeger(),
  ),
  GetPage(
    name: '/budget_setting',
    page: () => const PlBudgetSettingPage(),
    binding: PlBudgetSettingBinding(),
  ),
  GetPage(
    name: '/template_manage',
    page: () => const PlTemplateManagePage(),
    binding: PlTemplateManageBinding(),
  ),
];