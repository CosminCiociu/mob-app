import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/data/controller/onboard/onboard_controller.dart';
import 'package:ovo_meet/data/model/onboard/onboard_model.dart';
import 'package:get/get.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

class OnBoardRippleBody extends StatelessWidget {
  OnBoardModel data;
  OnBoardController controller;
  OnBoardRippleBody({
    super.key,
    required this.data,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: MyColor.primaryColor,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            context.isLandscape
                ? const SizedBox(height: 20)
                : const SizedBox(height: 100),
            Container(
              width: context.width,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: MyColor.primaryColor),
              child: Container(
                width: context.width,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: MyColor.primaryColor),
                child: RippleAnimation(
                  color: MyColor.primaryColor,
                  delay: const Duration(milliseconds: 300),
                  repeat: false,
                  minRadius: 85,
                  ripplesCount: 6,
                  duration: const Duration(milliseconds: 6 * 300),
                  child: Image.asset(
                    data.image,
                    height: context.isLandscape
                        ? context.height / 4
                        : context.height / 3,
                  ),
                ),
              ),
            ),
            SizedBox(height: context.height * 0.1),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
