import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/data/controller/home/home_controller.dart';
import 'package:ovo_meet/view/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:ovo_meet/view/components/image/custom_svg_picture.dart';
import 'package:ovo_meet/view/screens/homescreen/widgets/drawer_menu.dart';
import 'package:ovo_meet/view/screens/homescreen/widgets/filter_bottom_sheet.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import 'widgets/swipe_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    final controller = Get.put(HomeController());
    super.initState();
    controller.cardController = CardController();
    controller.resetCardController();
    const SystemUiOverlayStyle(statusBarColor: MyColor.transparentColor);

    // Update user location only once when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.updateUserLocation();
      // Use manual method to avoid geo query issues
      controller.fetchNearbyEventsManual();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) => ZoomDrawer(
        showShadow: true,
        style: DrawerStyle.defaultStyle,
        menuBackgroundColor: MyColor.buttonColor,
        menuScreenTapClose: true,
        menuScreenWidth: MediaQuery.of(context).size.width,
        duration: const Duration(milliseconds: 500),
        slideWidth: MediaQuery.of(context).size.width * 0.65,
        angle: 0,
        controller: controller.drawerController,
        menuScreen: const DrawerMenu(),
        mainScreen: Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          body: GetBuilder<HomeController>(
            builder: (controller) => SingleChildScrollView(
              padding: Dimensions.screenPadding,
              child: Column(
                children: [
                  Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: Dimensions.space5),
                    padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.space15,
                        horizontal: Dimensions.space10),
                    decoration: BoxDecoration(
                        border: Border.all(color: MyColor.colorWhite),
                        color: MyColor.colorWhite,
                        borderRadius:
                            BorderRadius.circular(Dimensions.space10)),
                    child: Row(children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Dimensions.space8),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFF76F96),
                              Color(0xFFF66D95),
                              Color(0xFFEB507E),
                              Color(0xFFE64375),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(Dimensions.space8),
                          child: CustomSvgPicture(
                            image: MyImages.pinImage,
                            color: MyColor.colorWhite,
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.space10),
                      SizedBox(
                        width: Dimensions.space200 + Dimensions.space20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              MyStrings.location,
                              style: boldLarge,
                            ),
                            Text(
                              controller.addressController.text,
                              style: regularDefault.copyWith(
                                  color: MyColor.getSecondaryTextColor()),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                          onTap: () {
                            controller.drawerController.toggle!();
                          },
                          child: Image.asset(
                            MyImages.burgerMenu,
                            color: MyColor.buttonColor,
                            height: Dimensions.space20,
                          )),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.space10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Get.toNamed(RouteHelper.searchConnectionScreen);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.space10,
                                  vertical: Dimensions.space10),
                              decoration: BoxDecoration(
                                  color: MyColor.greyColor.withOpacity(.12),
                                  borderRadius:
                                      BorderRadius.circular(Dimensions.space8)),
                              child: const Row(
                                children: [
                                  CustomSvgPicture(image: MyImages.search),
                                  SizedBox(width: Dimensions.space10),
                                  Text(MyStrings.search)
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.space10),
                        InkWell(
                          onTap: () {
                            CustomBottomSheet(child: const FilterBottomSheet())
                                .customBottomSheet(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.space8),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFF76F96),
                                  Color(0xFFF66D95),
                                  Color(0xFFEB507E),
                                  Color(0xFFE64375),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(Dimensions.space8),
                              child: CustomSvgPicture(
                                image: MyImages.filter,
                                color: MyColor.colorWhite,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Dimensions.space10),
                  Stack(
                    children: [
                      // Loading state
                      if (controller.isLoadingEvents)
                        Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: MyColor.buttonColor,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Loading nearby events...',
                                  style: TextStyle(
                                    color: MyColor.buttonColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      // End of cards message - show when finished all events or no events at all
                      else if ((controller.nearbyEvents.isNotEmpty &&
                              controller.hasFinishedAllEvents) ||
                          (controller.nearbyEvents.isEmpty &&
                              controller.currentIndex >=
                                  controller.names.length - 1))
                        Container(
                          padding:
                              const EdgeInsets.only(top: Dimensions.space200),
                          child: Text(
                            controller.nearbyEvents.isNotEmpty
                                ? "No more events nearby"
                                : MyStrings.youareAllCaughtupforToday,
                            style: semiBoldOverLarge.copyWith(
                                fontFamily: 'dancing',
                                color: MyColor.buttonColor),
                          ),
                        )
                      // TinderSwapCard for events or default images
                      else
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: Dimensions.space10),
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: TinderSwapCard(
                            swipeUp: true,
                            swipeDown: true,
                            orientation: AmassOrientation.bottom,
                            totalNum: controller.nearbyEvents.isNotEmpty
                                ? controller.nearbyEvents.length
                                : controller.names.length,
                            stackNum: 3,
                            swipeEdge: 4.0,
                            maxWidth: MediaQuery.of(context).size.width * 0.9,
                            maxHeight: MediaQuery.of(context).size.width * 1.8,
                            minWidth: MediaQuery.of(context).size.width * 0.5,
                            minHeight: MediaQuery.of(context).size.width * 0.8,
                            cardBuilder: (context, index) => controller
                                    .nearbyEvents.isNotEmpty
                                ? _buildEventCard(context, controller, index)
                                : _buildDefaultCard(context, controller, index),
                            cardController: controller.cardController,
                            swipeUpdateCallback:
                                (DragUpdateDetails details, Alignment align) {},
                            swipeCompleteCallback:
                                (CardSwipeOrientation orientation, int index) {
                              final maxLength =
                                  controller.nearbyEvents.isNotEmpty
                                      ? controller.nearbyEvents.length
                                      : controller.names.length;

                              // Don't reset currentIndex to 0, let the controller handle it
                              controller.onSwipeComplete(orientation, index);

                              // Check if we've reached the end
                              if (controller.currentIndex >= maxLength - 1) {
                                // Show "no more events" message
                                // Or navigate to match screen for default behavior
                                if (controller.nearbyEvents.isEmpty) {
                                  Get.toNamed(RouteHelper.matchScreen);
                                }
                              }

                              controller.resetCardController();
                              controller.update();
                            },
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * .6,
                            left: MediaQuery.of(context).size.width * .15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.nearbyEvents.isNotEmpty
                                  ? (controller.getCurrentEventData()?[
                                          'eventName'] ??
                                      'Event Name')
                                  : controller.names[controller.currentIndex],
                              style: boldOverLarge.copyWith(
                                  color: MyColor.colorWhite),
                            ),
                            Text(
                              controller.nearbyEvents.isNotEmpty
                                  ? controller.getCurrentEventLocation()
                                  : MyStrings.uiuxDesigner,
                              style: regularLarge.copyWith(
                                  color: MyColor.colorWhite.withOpacity(.7)),
                            ),
                            if (controller.nearbyEvents.isNotEmpty)
                              Text(
                                controller.getCurrentEventCategory(),
                                style: regularDefault.copyWith(
                                    color: MyColor.colorWhite.withOpacity(.8)),
                              ),
                          ],
                        ),
                      ),
                      // Hide buttons when finished all events or loading
                      (controller.isLoadingEvents ||
                              (controller.nearbyEvents.isNotEmpty &&
                                  controller.hasFinishedAllEvents) ||
                              (controller.nearbyEvents.isEmpty &&
                                  controller.currentIndex >=
                                      controller.names.length - 1))
                          ? const SizedBox()
                          : Padding(
                              padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height * .67,
                                  right: 70,
                                  left: 70),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      controller.cardController?.triggerLeft();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                          Dimensions.space15),
                                      decoration: const BoxDecoration(
                                          color: MyColor.lBackgroundColor,
                                          shape: BoxShape.circle),
                                      child: const CustomSvgPicture(
                                        image: MyImages.cancel,
                                        color: MyColor.colorRed,
                                        height: Dimensions.space12,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      controller.cardController?.triggerUp();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                          Dimensions.space20),
                                      decoration: const BoxDecoration(
                                          color: MyColor.lBackgroundColor,
                                          shape: BoxShape.circle),
                                      child: const CustomSvgPicture(
                                        image: MyImages.heart,
                                        color: MyColor.colorRed,
                                        height: Dimensions.space25,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      controller.cardController?.triggerRight();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                          Dimensions.space15),
                                      decoration: const BoxDecoration(
                                          color: MyColor.lBackgroundColor,
                                          shape: BoxShape.circle),
                                      child: const CustomSvgPicture(
                                        image: MyImages.like,
                                        color: MyColor.travelColor,
                                        height: Dimensions.space20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(
      BuildContext context, HomeController controller, int index) {
    if (index >= controller.nearbyEvents.length) return const SizedBox();

    final eventData =
        controller.nearbyEvents[index].data() as Map<String, dynamic>;
    final eventName = eventData['eventName'] as String? ?? 'Event';
    final location = eventData['location'] as Map<String, dynamic>?;
    final address = location?['address'] as Map<String, dynamic>?;
    final administrativeArea =
        address?['administrativeArea'] as String? ?? 'Location';
    final imageUrl = eventData['imageUrl'] as String?;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.width * 0.7,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: InkWell(
          onTap: () {
            // Navigate to event details screen
            // Get.toNamed(RouteHelper.eventDetailsScreen);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              if (imageUrl != null && imageUrl.isNotEmpty)
                Image.file(
                  File(imageUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to gradient if image fails to load
                    return Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFF76F96),
                            Color(0xFFF66D95),
                            Color(0xFFEB507E),
                            Color(0xFFE64375),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    );
                  },
                )
              else
                // Fallback gradient if no image URL
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFF76F96),
                        Color(0xFFF66D95),
                        Color(0xFFEB507E),
                        Color(0xFFE64375),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),

              // Dark overlay for better text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ],
          ),
        ),
      ),
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
            Get.toNamed(RouteHelper.partnersProfileScreen);
          },
          child: Container(
            color: Colors.grey[300],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.grey[600],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Image Available',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
