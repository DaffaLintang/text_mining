import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sen_pt/app/data/models/analysis_models.dart';
import 'package:sen_pt/app/data/providers/downloadProvider.dart';

class ResultPageController extends GetxController {
  //TODO: Implement ResultPageController

  final itemCount = 0.obs;
  final productName = ''.obs;
  final comments = <String>[].obs;
  final sentimen = <String>[].obs;
  final positifCount = 0.obs;
  final negatifCount = 0.obs;
  final topPhrasesPositif = <String>[].obs;
  final topPhrasesNegatif = <String>[].obs;
  final jobId = ''.obs;
  final filename = ''.obs;

  void updateFromResult(AnalysisResult result) {
    productName.value = result.productName;
    itemCount.value = result.items.length;
    comments.assignAll(result.items.map((e) => e.review));
    sentimen.assignAll(result.items.map((e) => e.sentiment));

    // always set filename from product name as requested
    if (productName.value.isNotEmpty) {
      filename.value = _sanitize(productName.value) + '.pdf';
    }

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

  void updateFromResume(Resume resume) {
    // counts from summary (more authoritative than recalculating from items)
    if (resume.positif > 0 || resume.negatif > 0) {
      positifCount.value = resume.positif;
      negatifCount.value = resume.negatif;
    }
    topPhrasesPositif.assignAll(resume.topPhrasesPositif);
    topPhrasesNegatif.assignAll(resume.topPhrasesNegatif);
  }

  void downloadPdf([String? inJobId, String? inFilename]) async {
    final jid = (inJobId != null && inJobId.isNotEmpty) ? inJobId : jobId.value;
    final fname = (inFilename != null && inFilename.isNotEmpty)
        ? inFilename
        : (filename.value.isNotEmpty
            ? filename.value
            : (_sanitize(productName.value.isEmpty ? 'hasil_$jid' : productName.value) + '.pdf'));

    final provider = Downloadprovider();
    if (jobId.value.isEmpty || filename.value.isEmpty) {
      Get.snackbar('Gagal','Input Link Terlebih Dahulu.',
                  backgroundColor: Colors.red, colorText: Colors.white);
    } else {
    await provider.downloadAndSave(jid, fname);
    Get.snackbar('Sukses','File berhasil diunduh.',
                  backgroundColor: Colors.green, colorText: Colors.white);
    }
  }

  String _sanitize(String s) {
    return s.replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');
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
