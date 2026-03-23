import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:sen_pt/app/widgets/pieChart.dart';
import 'package:sen_pt/app/widgets/resume.dart';
import 'package:sen_pt/app/widgets/result.dart';
import 'package:sen_pt/app/widgets/star_rating.dart';

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
              SizedBox(height: 20),
              Obx(() {
                final pos = controller.topPhrasesPositif.toList();
                final neg = controller.topPhrasesNegatif.toList();
                return ResumeWidget(
                  topPhrasesPositif: pos,
                  topPhrasesNegatif: neg,
                );
              }),
              SizedBox(height: 20),
              Obx(() => StarRatingWidget(
                    star5: controller.star5Count.value,
                    star4: controller.star4Count.value,
                    star3: controller.star3Count.value,
                    star2: controller.star2Count.value,
                    star1: controller.star1Count.value,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
