import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/data/controller/home/home_controller.dart';
import 'package:ovo_meet/data/controller/events/my_events_controller.dart';
import 'package:ovo_meet/data/controller/events/attending_events_controller.dart';
import 'package:ovo_meet/view/screens/homescreen/home_screen.dart';
import 'package:ovo_meet/view/screens/message_list/messages_list_screen.dart';
import 'package:ovo_meet/view/screens/events/my_events_screen.dart';
import 'package:ovo_meet/view/screens/events/attending_events_screen.dart';
import 'package:ovo_meet/view/screens/profile/profile_screen.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class BottomNavbarScreen extends StatefulWidget {
  const BottomNavbarScreen({super.key});

  @override
  State<BottomNavbarScreen> createState() => _BottomNavbarScreenState();
}

class _BottomNavbarScreenState extends State<BottomNavbarScreen> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    // Get initial tab index from arguments, default to 0 (home tab)
    int initialTab =
        Get.arguments != null && Get.arguments is int ? Get.arguments : 0;
    _controller = PersistentTabController(initialIndex: initialTab);
    Get.put(HomeController());
    setState(() {});
  }

  List<Widget> _buildScreens() {
    return [
      const HomeScreen(),
      const AttendingEventsScreen(),
      const MessageListScreen(),
      const MyEventsScreen(),
      const ProfileScreen()
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Image.asset(MyImages.presistentOnBoardImageOne,
            color: _controller.index == 0
                ? MyColor.buttonColor
                : MyColor.greyColor),
        activeColorPrimary: MyColor.buttonColor,
        inactiveColorPrimary: MyColor.greyColor,
      ),
      PersistentBottomNavBarItem(
        icon: Image.asset(MyImages.presistentOnBoardImageTwo,
            color: _controller.index == 1
                ? MyColor.buttonColor
                : MyColor.greyColor),
        activeColorPrimary: MyColor.buttonColor,
        inactiveColorPrimary: MyColor.greyColor,
      ),
      PersistentBottomNavBarItem(
        icon: Image.asset(MyImages.presistentOnBoardImageFour,
            color: _controller.index == 2
                ? MyColor.buttonColor
                : MyColor.greyColor),
        activeColorPrimary: MyColor.buttonColor,
        inactiveColorPrimary: MyColor.greyColor,
      ),
      PersistentBottomNavBarItem(
        icon: Image.asset(MyImages.presistentOnBoardImageThree,
            color: _controller.index == 3
                ? MyColor.buttonColor
                : MyColor.greyColor),
        activeColorPrimary: MyColor.buttonColor,
        inactiveColorPrimary: MyColor.greyColor,
      ),
      PersistentBottomNavBarItem(
        icon: Image.asset(MyImages.presistentOnBoardImageFive,
            color: _controller.index == 4
                ? MyColor.buttonColor
                : MyColor.greyColor),
        activeColorPrimary: MyColor.buttonColor,
        inactiveColorPrimary: MyColor.greyColor,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      onItemSelected: (value) {
        setState(() {
          _controller.index = value;
          Get.find<HomeController>().currentIndex = 0;
          Get.find<HomeController>().update();

          // Refresh events data when My Events tab (index 3) is selected
          if (value == 3) {
            // Schedule refresh for next frame to ensure UI updates properly
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Get.isRegistered<MyEventsController>()) {
                print("🔄 BottomNav: Refreshing events due to tab selection");
                Get.find<MyEventsController>().fetchMyEvents();
              }
            });
          }

          // Refresh attending events data when Attending Events tab (index 1) is selected
          if (value == 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                final attendingController =
                    Get.find<AttendingEventsController>();
                attendingController.fetchAttendingEvents();
                print(
                    "🔄 BottomNav: Refreshing attending events due to tab selection");
              } catch (e) {
                print("⚠️ AttendingEventsController not found: $e");
              }
            });
          }
        });
      },
      screens: _buildScreens(),
      items: _navBarsItems(),

      confineToSafeArea: true,
      backgroundColor: MyColor.colorWhite, // Default is Colors.white.
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset:
          true, // This needs to be true if you want to move up the screen when the keyboard appears.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardAppears:
          true, // Recommended to set 'true' to avoid bottom nav bar interfering with typing.

      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: MyColor.colorWhite,
      ),
      navBarStyle:
          NavBarStyle.style3, // Choose the nav bar style with pre-built styles.
    );
  }
}
