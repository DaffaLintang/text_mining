import 'package:get/get.dart';
import 'package:sen_pt/app/data/models/analysis_models.dart';

class ResultPageController extends GetxController {
  //TODO: Implement ResultPageController

  final itemCount = 0.obs;
  final productName = ''.obs;
  final comments = <String>[].obs;
  final sentimen = <String>[].obs;
  final positifCount = 0.obs;
  final negatifCount = 0.obs;

  void updateFromResult(AnalysisResult result) {
    productName.value = result.productName;
    itemCount.value = result.items.length;
    comments.assignAll(result.items.map((e) => e.review));
    sentimen.assignAll(result.items.map((e) => e.sentiment));


    // hitung jumlah positif & negatif
    int pos = 0;
    int neg = 0;
    for (final s in result.items.map((e) => (e.sentiment).toString())) {
      final v = s.trim().toLowerCase();
      if (v == 'positif' || v == 'positive') {
        pos++;
      } else if (v == 'negatif' || v == 'negative') {
        neg++;
      }
    }
    positifCount.value = pos;
    negatifCount.value = neg;
  }
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}
