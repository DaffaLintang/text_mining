import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:sen_pt/app/widgets/linkTextField.dart';
import 'package:sen_pt/app/widgets/submitButton.dart';

import '../controllers/landing_page_controller.dart';

class LandingPageView extends GetView<LandingPageController> {
  const LandingPageView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Link Produk',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              LinkTextField(controller: controller.linkController),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SubmitButton(
                      onPressed: controller.createJob,
                      label: 'Naive Bayes',
                      colors: const [Color(0xFF6C63FF), Color(0xFF48CAE4)],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SubmitButton(
                      onPressed: controller.createJobVader,
                      label: 'VADER',
                      colors: const [Color(0xFFF2994A), Color(0xFFF2C94C)],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
