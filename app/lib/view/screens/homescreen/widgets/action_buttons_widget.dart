import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_images.dart';
import '../../../../data/controller/home/home_controller.dart';
import '../../../components/image/custom_svg_picture.dart';

class ActionButtonsWidget extends StatefulWidget {
  final HomeController controller;

  const ActionButtonsWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<ActionButtonsWidget> createState() => _ActionButtonsWidgetState();
}

class _ActionButtonsWidgetState extends State<ActionButtonsWidget> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        // Calculate like button intensity based on swipe progress
        final swipeProgress = controller.swipeProgress;
        final likeIntensity = swipeProgress > 0 ? swipeProgress : 0.0;
        final rejectIntensity = swipeProgress < 0 ? -swipeProgress : 0.0;

        return Padding(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * .67,
              right: 70,
              left: 70),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Reject Button
              InkWell(
                onTap: () {
                  controller.cardController?.triggerLeft();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  padding: const EdgeInsets.all(Dimensions.space15),
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      MyColor.lBackgroundColor,
                      MyColor.colorRed.withOpacity(0.3),
                      rejectIntensity.clamp(0.0, 1.0),
                    ),
                    shape: BoxShape.circle,
                    border: rejectIntensity > 0.3
                        ? Border.all(
                            color: MyColor.colorRed
                                .withOpacity(rejectIntensity.clamp(0.0, 1.0)),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Transform.scale(
                    scale: 1.0 + (rejectIntensity * 0.2),
                    child: CustomSvgPicture(
                      image: MyImages.cancel,
                      color: Color.lerp(
                        MyColor.colorRed,
                        MyColor.colorRed,
                        rejectIntensity.clamp(0.0, 1.0),
                      ),
                      height: Dimensions.space12,
                    ),
                  ),
                ),
              ),

              // Like Button
              InkWell(
                onTap: () {
                  controller.cardController?.triggerRight();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  padding: const EdgeInsets.all(Dimensions.space15),
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      MyColor.lBackgroundColor,
                      MyColor.travelColor.withOpacity(0.3),
                      likeIntensity.clamp(0.0, 1.0),
                    ),
                    shape: BoxShape.circle,
                    border: likeIntensity > 0.3
                        ? Border.all(
                            color: MyColor.travelColor
                                .withOpacity(likeIntensity.clamp(0.0, 1.0)),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Transform.scale(
                    scale: 1.0 + (likeIntensity * 0.2),
                    child: CustomSvgPicture(
                      image: MyImages.like,
                      color: Color.lerp(
                        MyColor.travelColor,
                        MyColor.travelColor,
                        likeIntensity.clamp(0.0, 1.0),
                      ),
                      height: Dimensions.space20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
