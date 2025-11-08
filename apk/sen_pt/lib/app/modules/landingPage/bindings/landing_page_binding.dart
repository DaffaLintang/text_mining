import 'package:get/get.dart';
import 'package:sen_pt/app/data/providers/analyzeProvider.dart';

import '../controllers/landing_page_controller.dart';

class LandingPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LandingPageController>(
      () => LandingPageController(),
    );

    Get.lazyPut<AnalysisProvider>(
      () => AnalysisProvider(),
    );
  }
}
