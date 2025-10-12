import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/route/route.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../core/utils/style.dart';
import '../../../../data/controller/home/home_controller.dart';
import 'action_buttons_widget.dart';
import 'event_card_widget.dart';
import 'loading_state_widget.dart';
import 'no_events_state_widget.dart';
import 'swipe_image.dart';

class EventsContentWidget extends StatelessWidget {
  final HomeController controller;

  const EventsContentWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Loading state
        if (controller.isLoadingEvents)
          const LoadingStateWidget()
        // End of cards message - show when finished all events or no events at all
        else if ((controller.nearbyEvents.isNotEmpty &&
                controller.hasFinishedAllEvents) ||
            (controller.nearbyEvents.isEmpty && controller.currentIndex >= 0))
          NoEventsStateWidget(controller: controller)
        // TinderSwapCard for events or default images
        else
          Container(
            margin: const EdgeInsets.symmetric(vertical: Dimensions.space10),
            height: MediaQuery.of(context).size.height * 0.7,
            child: TinderSwapCard(
              swipeUp: true,
              swipeDown: true,
              orientation: AmassOrientation.bottom,
              totalNum: controller.nearbyEvents.isNotEmpty
                  ? controller.nearbyEvents.length
                  : 1, // Default to 1 when no events
              stackNum: 3,
              swipeEdge: 4.0,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.width * 1.8,
              minWidth: MediaQuery.of(context).size.width * 0.5,
              minHeight: MediaQuery.of(context).size.width * 0.8,
              cardBuilder: (context, index) =>
                  controller.nearbyEvents.isNotEmpty
                      ? EventCardWidget(controller: controller, index: index)
                      : _buildDefaultCard(context, controller, index),
              cardController: controller.cardController,
              swipeUpdateCallback:
                  (DragUpdateDetails details, Alignment align) {},
              swipeCompleteCallback:
                  (CardSwipeOrientation orientation, int index) {
                final maxLength = controller.nearbyEvents.isNotEmpty
                    ? controller.nearbyEvents.length
                    : 1; // Default to 1 when no events

                // Don't reset currentIndex to 0, let the controller handle it
                controller.onSwipeComplete(orientation, index);

                // Check if we've reached the end
                if (controller.currentIndex >= maxLength - 1) {
                  // Show "no more events" message
                  // Or navigate to ideal match screen for default behavior
                  if (controller.nearbyEvents.isEmpty) {
                    Get.toNamed(RouteHelper.idealMatchScreen);
                  }
                }

                controller.resetCardController();
                controller.update();
              },
            ),
          ),

        // Hide buttons when finished all events or loading
        (controller.isLoadingEvents ||
                (controller.nearbyEvents.isNotEmpty &&
                    controller.hasFinishedAllEvents) ||
                (controller.nearbyEvents.isEmpty &&
                    controller.currentIndex >= 0))
            ? const SizedBox()
            : ActionButtonsWidget(controller: controller),
      ],
    );
  }

  Widget _buildDefaultCard(
      BuildContext context, HomeController controller, int index) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.width * 0.7,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: InkWell(
          onTap: () {
            // Navigate to events screen to create or view events
            Get.toNamed(RouteHelper.bottomNavBar, arguments: 1);
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MyColor.primaryColor.withOpacity(0.8),
                  MyColor.primaryColor.withOpacity(0.6),
                  MyColor.primaryColor,
                ],
              ),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Stack(
              children: [
                // Background pattern or decoration
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          MyColor.colorBlack.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),

                // Content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: MyColor.colorWhite.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.event_available,
                          size: 60,
                          color: MyColor.colorWhite,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Discover Events',
                        style: boldExtraLarge.copyWith(
                          color: MyColor.colorWhite,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          MyStrings.noEventsFoundTapToCreate,
                          textAlign: TextAlign.center,
                          style: regularLarge.copyWith(
                            color: MyColor.colorWhite.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
