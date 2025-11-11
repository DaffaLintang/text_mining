import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:sen_pt/app/widgets/pieChart.dart';
import 'package:sen_pt/app/widgets/result.dart';

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
              Obx(() => ResultWidget(
                    itemCount: controller.itemCount.value,
                    productName: controller.productName.value,
                    comments: controller.comments,
                    sentimen: controller.sentimen,
                    jobId: controller.jobId.value,
                    filename: controller.filename.value,
                    resultPageController: controller,
                  )),
              SizedBox(height: 20),
              Obx(() => PieChartWidget(
                    positifCount: controller.positifCount.value,
                    negatifCount: controller.negatifCount.value,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
