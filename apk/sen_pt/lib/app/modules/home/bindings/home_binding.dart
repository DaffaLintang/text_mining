import 'package:get/get.dart';

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
    Get.lazyPut<ResultPageController>(
      () => ResultPageController(),
      fenix: true,
    );
  }
}
