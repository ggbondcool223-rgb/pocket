import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'pl_mind_logic.dart';

class PlMindView extends GetView<PlMindLogic> {
  const PlMindView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(
          () => controller.wxjf.value
              ? const CircularProgressIndicator(color: Colors.grey)
              : buildError(),
        ),
      ),
    );
  }

  Widget buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              controller.zcoj();
            },
            icon: const Icon(
              Icons.restart_alt,
              size: 50,
            ),
          ),
        ],
      ),
    );
  }
}
