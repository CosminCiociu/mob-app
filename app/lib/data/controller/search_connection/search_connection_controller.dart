import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:get/get.dart';

class SearchConnectionController extends GetxController {
  List<Widget> buildCircleImages(
      Size size, List<double> radii, List<String> imagePaths, context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.portrait) {
      print("Screen is in vertical orientation (Portrait)");
    } else if (orientation == Orientation.landscape) {
      print("Screen is in horizontal orientation (Landscape)");
    }

    int itemCount = imagePaths.length;

    List<Widget> positionedImages = [];

    for (int i = 0; i < itemCount; i++) {
      double angle = (2 * pi * i) / itemCount;

      double radius = radii[i];

      double x = radius * cos(angle);
      double y = radius * sin(angle);

      positionedImages.add(
        Positioned(
          left: (size.width / 2) + x - 30,
          top: (size.height / 2) + y - 30,
          child: CircleAvatar(
              backgroundImage: AssetImage(imagePaths[i]),
              radius: orientation == Orientation.portrait ? 30 : 20),
        ),
      );
    }

    return positionedImages;
  }

  List<String> imagePaths = [
    MyImages.girl1,
    MyImages.girl2,
    MyImages.girl1,
    MyImages.girl2,
    MyImages.girl1,
    MyImages.girl2,
  ];
}
