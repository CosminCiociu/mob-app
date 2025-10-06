import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/view/components/dialog/exit_dialog.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool isShowBackBtn;
  final Color? bgColor;
  final bool isShowActionBtn;
  final bool isTitleCenter;
  final bool fromAuth;
  final bool isProfileCompleted;
  final List<Widget>? action;
  final VoidCallback? backButtonOnPress;

  const CustomAppBar({
    super.key,
    this.isProfileCompleted = false,
    this.fromAuth = false,
    this.isTitleCenter = false,
    this.bgColor,
    this.isShowBackBtn = true,
    required this.title,
    this.isShowActionBtn = false,
    this.action,
    this.backButtonOnPress,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size(double.maxFinite, 60);
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool hasNotification = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      systemOverlayStyle: widget.isShowBackBtn
          ? const SystemUiOverlayStyle(
              statusBarColor: MyColor.transparentColor,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            )
          : SystemUiOverlayStyle(
              statusBarColor: MyColor.transparentColor,
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarColor: MyColor.transparentColor,
              systemNavigationBarIconBrightness: Theme.of(context).brightness,
            ),
      elevation: 0,
      shadowColor: MyColor.getBlackColor().withOpacity(0.1),
      titleSpacing: 0,
      surfaceTintColor: MyColor.getTransparentColor(),
      leading: widget.isShowBackBtn
          ? IconButton(
              onPressed: () {
                if (widget.backButtonOnPress == null) {
                  if (widget.fromAuth) {
                    Get.offAllNamed(RouteHelper.loginScreen);
                  } else if (widget.isProfileCompleted) {
                    showExitDialog(Get.context!);
                  } else {
                    String previousRoute = Get.previousRoute;
                    if (previousRoute == '/splash-screen') {
                      Get.offAndToNamed(RouteHelper.bottomNavBar);
                    } else {
                      Get.back();
                    }
                  }
                } else {
                  widget.backButtonOnPress!();
                }
              },
              icon: Icon(Icons.arrow_back_ios_new,
                  color: Theme.of(context).appBarTheme.foregroundColor,
                  size: 20))
          : null, // Hide the back button if isShowBackBtn is false
      backgroundColor:
          widget.bgColor ?? Theme.of(context).appBarTheme.backgroundColor,
      title: Text(
        widget.title.tr,
        style: boldOverLarge.copyWith(
          color: Theme.of(context).appBarTheme.foregroundColor,
        ),
      ),
      centerTitle: widget.isTitleCenter,
      actions: widget.action,
      automaticallyImplyLeading: false, // Prevents default back button
    );
  }
}
