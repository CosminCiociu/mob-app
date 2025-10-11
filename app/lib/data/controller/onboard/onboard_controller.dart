import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/data/model/onboard/onboard_model.dart';
import 'package:get/get.dart';

class OnBoardController extends GetxController {
  List<OnBoardModel> appBanners = [
    OnBoardModel(
      title: "Find your partner with us   .",
      subtitle: "Abra ka dabra gili gili asjsdslakdjsalkdjsladjsladjsjdsad ",
      image: MyImages.onBoardImageThree,
      isSvg: true,
      bgcolor: const Color(0xffb25cea),
      icon: Icons.photo,
    ),
    OnBoardModel(
      image: MyImages.onBoardImageOne,
      title: "Dating better than before ",
      subtitle: "Make sure to take a look my uplab profile every tuesday",
      isSvg: true,
      bgcolor: const Color(0xffff5c9d),
      icon: Icons.favorite,
    ),
    OnBoardModel(
      title: "Find your perfect match!",
      subtitle:
          "You can follow me if you wantand comment on any to get some freebies",
      image: MyImages.onBoardImageTwo,
      isSvg: true,
      bgcolor: const Color(0xff006bcc),
      icon: Icons.share,
    )
  ];

  int currentIndex = 0;
  PageController? controller = PageController();

  void setCurrentIndex(int index) {
    currentIndex = index;
    update();
  }

  LinearGradient generateGradientVariation(
      Color baseColor, GradientIntensity intensity) {
    Color generateVariation() {
      final int variation =
          intensity.index * 50; // Adjust the factor based on intensity levels
      final int red = min(255, baseColor.red + variation);
      final int green = min(255, baseColor.green + variation);
      final int blue = min(255, baseColor.blue + variation);

      return Color.fromRGBO(red, green, blue, 1.0);
    }

    final Color color1 = baseColor;
    final Color color2 = generateVariation();

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color2,
        color1,
      ],
    );
  }
}

enum GradientIntensity { accent, soft, medium, hard }
