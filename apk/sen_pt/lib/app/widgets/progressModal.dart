import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:sen_pt/app/modules/landingPage/controllers/landing_page_controller.dart';

class ProgressModal extends StatelessWidget {
  const ProgressModal({super.key, required this.controller});

  final LandingPageController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Sedang Memproses...'),
      content: Column( 
        mainAxisSize: MainAxisSize.min,
        children: [
         LinearProgressIndicator(
              value: controller.percent.value / 100,
              minHeight: 8,
            ),
            const SizedBox(height: 16),
            Text('${controller.percent.value}%'),
            if (controller.message.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  controller.message.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
      ],)
    ));
  }
}