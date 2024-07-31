import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mesme/screens/welcome.dart';
// Make sure the import is correct

class OnboardController extends GetxController {
  static OnboardController get instance => Get.find();

  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  void updatePageIndicator(int index) {
    currentPageIndex.value = index;
  }

  void dotNavigatorClick(int index) {
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  void nextPage(BuildContext context) {
    if (currentPageIndex.value == 2) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MeWelcome()),
        (route) => false,
      );
    } else {
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  void skipPage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MeWelcome()),
      (route) => false,
    );
  }
}
