import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ovo_meet/data/controller/home/home_controller.dart';
import 'package:ovo_meet/view/screens/homescreen/widgets/drawer_menu.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import '../../../core/utils/my_color.dart';
import 'widgets/location_header_widget.dart';
import 'widgets/search_filter_row_widget.dart';
import 'widgets/events_content_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set up card controller after frame is built to avoid multiple calls
      final controller = Get.find<HomeController>();
      controller.initializeCardController();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: WillPopScope(
          onWillPop: () async {
            if (Platform.isAndroid) {
              SystemNavigator.pop();
            }
            return false;
          },
          child: ZoomDrawer(
            controller: controller.drawerController,
            menuScreen: const DrawerMenu(),
            mainScreen: _buildMainScreen(controller),
            borderRadius: 24.0,
            showShadow: true,
            angle: -12.0,
            drawerShadowsBackgroundColor: Colors.grey[300]!,
            slideWidth: MediaQuery.of(context).size.width * 0.65,
            menuBackgroundColor: MyColor.colorWhite,
          ),
        ),
      ),
    );
  }

  Widget _buildMainScreen(HomeController controller) {
    return Scaffold(
      backgroundColor: MyColor.colorWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Location Header
            LocationHeaderWidget(controller: controller),

            // Search and Filter Row
            const SearchFilterRowWidget(),

            // Main Content Area
            Expanded(
              child: EventsContentWidget(controller: controller),
            ),
          ],
        ),
      ),
    );
  }
}
