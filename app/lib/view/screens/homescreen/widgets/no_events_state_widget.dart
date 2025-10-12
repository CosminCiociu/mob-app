import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/route/route.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../core/utils/style.dart';
import '../../../../data/controller/home/home_controller.dart';

class NoEventsStateWidget extends StatelessWidget {
  final HomeController controller;

  const NoEventsStateWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.space20,
        vertical: Dimensions.space100,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: MyColor.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              controller.nearbyEvents.isNotEmpty
                  ? Icons.check_circle_outline
                  : Icons.event_available,
              size: 60,
              color: MyColor.primaryColor,
            ),
          ),
          const SizedBox(height: Dimensions.space20),
          Text(
            controller.nearbyEvents.isNotEmpty
                ? MyStrings.allCaughtUp
                : MyStrings.noNearbyEvents,
            style: boldExtraLarge.copyWith(
              color: MyColor.getTextColor(),
            ),
          ),
          const SizedBox(height: Dimensions.space10),
          Text(
            controller.nearbyEvents.isNotEmpty
                ? MyStrings.allCaughtUpMessage
                : MyStrings.noNearbyEventsMessage,
            textAlign: TextAlign.center,
            style: regularDefault.copyWith(
              color: MyColor.getTextColor().withOpacity(0.7),
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: Dimensions.space20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Get.offAllNamed(RouteHelper.bottomNavBar, arguments: 1);
                },
                icon: const Icon(Icons.event),
                label: const Text('My Events'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColor.primaryColor,
                  foregroundColor: MyColor.colorWhite,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Get.toNamed(RouteHelper.createEventForm);
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Event'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColor.colorWhite,
                  foregroundColor: MyColor.primaryColor,
                  side: BorderSide(
                    color: MyColor.primaryColor,
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
