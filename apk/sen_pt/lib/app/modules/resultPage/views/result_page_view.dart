import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/result_page_controller.dart';

class ResultPageView extends GetView<ResultPageController> {
  const ResultPageView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // ResultWidget(itemCount: controller.itemCount, productName: controller.productName, comments: controller.comments, sentimen: controller.sentimen),
              // PieChartWidget(positifCount: controller.positifCount, negatifCount: controller.negatifCount),
            ],
          ),
        ),
      ),
    );
  }
}
