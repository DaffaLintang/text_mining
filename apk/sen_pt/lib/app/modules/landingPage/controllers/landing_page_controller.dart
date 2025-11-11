import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sen_pt/app/data/models/analysis_models.dart';
import 'package:sen_pt/app/data/providers/analyzeProvider.dart';
import 'package:sen_pt/app/modules/home/controllers/home_controller.dart';
import 'package:sen_pt/app/widgets/progressModal.dart';
import 'package:sen_pt/app/modules/resultPage/controllers/result_page_controller.dart';

class LandingPageController extends GetxController {
  //TODO: Implement LandingPageController

  TextEditingController linkController = TextEditingController();
  final tokopediaPattern = RegExp(r'^https:\/\/tk\.tokopedia\.com\/[A-Za-z0-9]+\/?$');

  var percent  = 0.obs;
  var message = ''.obs;
  var isCompleted = false.obs;
  var isLoading = false.obs;

  StreamSubscription<AnalysisProgress>? _progressSub;

  @override
  void onInit() {
    super.onInit();

    ever(isCompleted, (done) {
      if (done == true && Get.isDialogOpen == true) {
        Get.back();
        Get.snackbar('Selesai', 'Analisis selesai!',
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    });
  }

  @override
  void onClose() {
    _progressSub?.cancel();
    super.onClose();
  }

  Future<void> createJob() async {
    try {
    if (isLoading.value) {
      return;
    }
    if(linkController.text.isEmpty){
      Get.snackbar('Warning', 'Silahkan Input Link',
        backgroundColor: Colors.amber, colorText: Colors.white);
    } else if(!tokopediaPattern.hasMatch(linkController.text)){
      Get.snackbar('Error', 'Link Tidak Valid',
        backgroundColor: Colors.red, colorText: Colors.white);
    } else {
      // reset and show progress modal
      isLoading.value = true;
      isCompleted.value = false;
      percent.value = 0;
      message.value = '';
      if (Get.isDialogOpen != true) {
        Get.dialog(ProgressModal(controller: this), barrierDismissible: false);
      }
      final job = await Get.find<AnalysisProvider>().createJob({
      'shortlink': linkController.text,
        });

        if (job != null) {
          // Simpan jobId (dan filename default) ke ResultPageController
          final rc = Get.find<ResultPageController>();
          rc.jobId.value = job.jobId;
          // Cancel previous subscription if any to avoid multiple listeners
          await _progressSub?.cancel();
          final stream = Get.find<AnalysisProvider>()
              .getProgress(job.jobId)
              .asBroadcastStream();
          _progressSub = stream.listen((AnalysisProgress data) {
            percent.value = data.percent;
            message.value = data.message;
            // Push incremental result if present
            if (data.result != null) {
              try {
                final r = data.result!;
                print('About to update ResultPageController: product=${r.productName}, items=${r.items.length}');
                Get.find<ResultPageController>().updateFromResult(r);
                print('Called updateFromResult successfully');
              } catch (e, st) {
                print('Failed to update ResultPageController: $e');
                print(st);
              }
            } else {
              print('No result field in this tick');
            }
            print('Progress tick: ${data.percent}% - ${data.message}');

            final status = data.status.toLowerCase();
            if (status == 'failed') {
              isLoading.value = false;
              if (Get.isDialogOpen == true) {
                Get.back();
              }
              Get.snackbar('Gagal', data.message.isEmpty ? 'Terjadi kesalahan.' : data.message,
                  backgroundColor: Colors.red, colorText: Colors.white);
              _progressSub?.cancel();
              return;
            }

            if (status == 'completed' || data.percent >= 100) {
              isCompleted.value = true;
              isLoading.value = false;
              // push parsed result into ResultPageController if available
              final res = data.result;
              if (res != null) {
                Get.find<ResultPageController>().updateFromResult(res);
              }
              // Navigate to Result page with animation
              final homeC = Get.find<HomeController>();
              homeC.changePage(1);
              homeC.pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutQuad,
              );
            }
          }, onError: (e, st) {
            print('Progress stream error: $e');
          });
        } else {
          // failed to create job
          isLoading.value = false;
          if (Get.isDialogOpen == true) {
            Get.back();
          }
        }
    }
    } catch (e, stackTrace) {
      print('Exception occurred: $e\n$stackTrace');
      isLoading.value = false;
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    }
  }
}
