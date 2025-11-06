import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sen_pt/app/modules/home/controllers/home_controller.dart';
import 'package:sen_pt/app/modules/landingPage/views/landing_page_view.dart';
import 'package:sen_pt/app/modules/resultPage/views/result_page_view.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

class HomeView extends GetView<HomeController> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SenPT', 
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
        titleSpacing: 20,
        automaticallyImplyLeading: false,
      ),
      body: PageView(
        controller: controller.pageController,
        onPageChanged: controller.changePage,
        children: _listOfPages(),
      ),
      bottomNavigationBar: Obx(
        () => SlidingClippedNavBar(
          backgroundColor: Colors.white,
          onButtonPressed: (index) {
            controller.changePage(index);
            controller.pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuad,
            );
          },
          activeColor: Colors.blue,
          inactiveColor: Colors.grey,
          selectedIndex: controller.onSelectedIndex.value,
          iconSize: 30,
          barItems: [
            BarItem(
              icon: Icons.search_rounded,
              title: 'Input Link',
            ),
            BarItem(
              icon: Icons.bar_chart_rounded,
              title: 'Result',
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _listOfPages() {
    return [
      const LandingPageView(),
      const ResultPageView(),
    ];
  }
}