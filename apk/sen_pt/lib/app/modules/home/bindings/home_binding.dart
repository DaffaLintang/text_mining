import 'package:get/get.dart';
import 'package:sen_pt/app/data/providers/analyzeProvider.dart';

import '../controllers/home_controller.dart';
import 'package:sen_pt/app/modules/landingPage/controllers/landing_page_controller.dart';
import 'package:sen_pt/app/modules/resultPage/controllers/result_page_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut<LandingPageController>(
      () => LandingPageController(),
      fenix: true,
    );
    // Use a single permanent instance so it won't be disposed/recreated
    Get.put<ResultPageController>(ResultPageController(), permanent: true);
    Get.lazyPut<AnalysisProvider>(
      () => AnalysisProvider(),
      fenix: true,
    );
  }
}
