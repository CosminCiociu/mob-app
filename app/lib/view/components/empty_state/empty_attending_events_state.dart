import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/view/components/buttons/custom_gradiant_button.dart';

class EmptyAttendingEventsState extends StatelessWidget {
  const EmptyAttendingEventsState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.space40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: MyColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circles for depth
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: MyColor.primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(80),
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: MyColor.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(60),
                    ),
                  ),
                  // Main icon
                  Icon(
                    Icons.event_available_outlined,
                    size: 60,
                    color: MyColor.primaryColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: Dimensions.space30),

            // Title with emoji
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '⭐ ',
                  style: boldExtraLarge.copyWith(fontSize: 24),
                ),
                Flexible(
                  child: Text(
                    MyStrings.noAttendingEvents,
                    style: boldExtraLarge.copyWith(
                      fontSize: 20,
                      color: MyColor.getTextColor(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),

            const SizedBox(height: Dimensions.space15),

            // Subtitle
            Text(
              MyStrings.exploreEventsToStart,
              style: regularLarge.copyWith(
                color: MyColor.getTextColor().withOpacity(0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: Dimensions.space40),

            // Action Button
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: InkWell(
                onTap: () {
                  // Navigate to main screen/browse events
                  Get.offAllNamed(RouteHelper.bottomNavBar);
                },
                child: CustomGradiantButton(
                  text: MyStrings.browseEvents,
                  textColor: MyColor.colorWhite,
                  padding: 16,
                ),
              ),
            ),

            const SizedBox(height: Dimensions.space30),

            // Additional encouragement
            Container(
              padding: const EdgeInsets.all(Dimensions.space20),
              decoration: BoxDecoration(
                color: MyColor.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(Dimensions.space15),
                border: Border.all(
                  color: MyColor.primaryColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lightbulb_outlined,
                        color: MyColor.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: Dimensions.space8),
                      Text(
                        'Tip',
                        style: boldDefault.copyWith(
                          color: MyColor.primaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.space8),
                  Text(
                    'Join events that match your interests and start building meaningful connections with like-minded people in your area!',
                    style: regularDefault.copyWith(
                      color: MyColor.getTextColor().withOpacity(0.8),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
