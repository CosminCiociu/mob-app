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
                              MyStrings.london,
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
                      controller.currentIndex ==
                              controller.girlsImages.length - 1
                          ? Container(
                              padding: const EdgeInsets.only(
                                  top: Dimensions.space200),
                              child: Text(
                                MyStrings.youareAllCaughtupforToday,
                                style: semiBoldOverLarge.copyWith(
                                    fontFamily: 'dancing',
                                    color: MyColor.buttonColor),
                              ),
                            )
                          : Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: Dimensions.space10),
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: TinderSwapCard(
                                swipeUp: true,
                                swipeDown: true,
                                orientation: AmassOrientation.bottom,
                                totalNum: controller.girlsImages.length,
                                stackNum: 3,
                                swipeEdge: 4.0,
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.9,
                                maxHeight:
                                    MediaQuery.of(context).size.width * 1.8,
                                minWidth:
                                    MediaQuery.of(context).size.width * 0.5,
                                minHeight:
                                    MediaQuery.of(context).size.width * 0.8,
                                cardBuilder: (context, index) => SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15.0),
                                    child: InkWell(
                                      onTap: () {
                                        Get.toNamed(
                                            RouteHelper.partnersProfileScreen);
                                      },
                                      child: Image.asset(
                                        controller.girlsImages[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                cardController: controller.cardController,
                                swipeUpdateCallback: (DragUpdateDetails details,
                                    Alignment align) {},
                                swipeCompleteCallback:
                                    (CardSwipeOrientation orientation,
                                        int index) {
                                  controller.currentIndex =
                                      index % controller.names.length;
                                  controller.currentIndex ==
                                          controller.girlsImages.length - 1
                                      ? Get.toNamed(RouteHelper.matchScreen)
                                      : null;

                                  controller.onSwipeComplete(
                                      orientation, index);
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
                              controller.names[controller.currentIndex],
                              style: boldOverLarge.copyWith(
                                  color: MyColor.colorWhite),
                            ),
                            Text(
                              MyStrings.uiuxDesigner,
                              style: regularLarge.copyWith(
                                  color: MyColor.colorWhite.withOpacity(.7)),
                            )
                          ],
                        ),
                      ),
                      controller.currentIndex ==
                              controller.girlsImages.length - 1
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
                                        image: MyImages.star,
                                        color: MyColor.goldenColor,
                                        height: Dimensions.space12,
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
}
