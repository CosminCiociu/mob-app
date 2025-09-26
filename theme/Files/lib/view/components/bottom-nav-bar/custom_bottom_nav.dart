// ignore_for_file: must_be_immutable

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/data/model/global/bottom_nav_data_model/bottom_nav_data_model.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

enum BOTTOMNAVSTYLE { NONE, STYLE1, STYLE2, STYLE3 }

class CustomBottomNavBar extends StatefulWidget {
  List<BottomNavItemModel> items;
  Function onChange;
  BOTTOMNAVSTYLE? bottomNavStyle;
  TextStyle? labelStyle;
  Color? iconColor;
  Color? selectedIconColor;
  Color? selectedItemBGColor;
  Color? bottomNavBGColor;
  List<BoxShadow>? boxShadow;
  final bool showDot;
  final double radius;
  CustomBottomNavBar({
    super.key,
    required this.items,
    required this.onChange,
    this.bottomNavStyle = BOTTOMNAVSTYLE.NONE,
    this.labelStyle,
    this.iconColor = MyColor.iconColor,
    this.selectedIconColor = MyColor.colorBlack,
    this.selectedItemBGColor,
    this.bottomNavBGColor,
    this.boxShadow,
    this.showDot = false,
    this.radius = Dimensions.mediumRadius,
  })  : assert(items.length < 6 || items.isEmpty, "Items cannot be empty and not more than 5 "),
        assert(BOTTOMNAVSTYLE.STYLE3 != bottomNavStyle, "Bottom nav style3 is under construction");

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.bottomNavStyle == BOTTOMNAVSTYLE.STYLE1) {
      return styleOne(context);
    }
    if (widget.bottomNavStyle == BOTTOMNAVSTYLE.STYLE2) {
      return styleTwo(context);
    }
    if (widget.bottomNavStyle == BOTTOMNAVSTYLE.STYLE3) {
      return styleThree(context);
    } else {
      //default style
      return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: Dimensions.space15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.bottomNavBGColor ?? MyColor.getBottomNavBgColor(),
          borderRadius: BorderRadius.circular(widget.radius),
          boxShadow: widget.boxShadow ?? [BoxShadow(color: MyColor.getShadowColor(), offset: const Offset(-2, -2), blurRadius: 2)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(
            widget.items.length,
            (index) => InkWell(
              onTap: () {
                setState(() {
                  print("tap $currentIndex ");
                  currentIndex = widget.items[index].index;
                  widget.onChange(currentIndex);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  color: widget.selectedItemBGColor ?? MyColor.getTransparentColor(),
                  borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.items[index].isIconData == true) ...[
                      Icon(widget.items[index].icon)
                    ] else ...[
                      widget.items[index].image.contains('svg')
                          ? SvgPicture.asset(
                              widget.items[index].image,
                              colorFilter: ColorFilter.mode(
                                widget.items[index].index == currentIndex ? widget.selectedIconColor! : widget.iconColor!,
                                BlendMode.srcIn,
                              ),
                              width: 16,
                              height: 16,
                            )
                          : Image.asset(
                              widget.items[index].image,
                              color: widget.items[index].index == currentIndex ? widget.selectedIconColor : widget.iconColor,
                              width: 16,
                              height: 16,
                            ),
                    ],
                    if (widget.items[index].index == currentIndex) ...[
                      const SizedBox(height: Dimensions.space10 / 2),
                      Text(
                        widget.items[index].name.tr,
                        textAlign: TextAlign.center,
                        style: widget.labelStyle ?? regularSmall.copyWith(color: widget.items[index].index == currentIndex ? widget.selectedIconColor : MyColor.getTextColor()),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget styleThree(BuildContext context) {
    return AnimatedBottomNavigationBar(
      icons: const[
        Icons.home,
        Icons.transform,
        Icons.wallet,
        Icons.menu,
      ],
      activeIndex: currentIndex,
      onTap: (index) {
        setState(() {
          currentIndex = widget.items[index].index;
          widget.onChange(currentIndex);
        });
      },
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.verySmoothEdge,
      leftCornerRadius: 32,
      rightCornerRadius: 32,
      backgroundColor: MyColor.getAppBarColor(),
    );
  }

  Container styleTwo(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.space10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.bottomNavBGColor ?? MyColor.getBottomNavBgColor(),
        boxShadow: widget.boxShadow ?? [BoxShadow(color: MyColor.getShadowColor(), offset:const Offset(-2, -2), blurRadius: 2)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(
          widget.items.length,
          (index) => InkWell(
            onTap: () {
              setState(() {
                currentIndex = widget.items[index].index;
                widget.onChange(currentIndex);
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                color: MyColor.getTransparentColor(),
                borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(Dimensions.space8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.selectedItemBGColor ?? MyColor.getWhiteColor().withOpacity(0.1),
                    ),
                    child: widget.items[index].isIconData == true
                        ? Icon(widget.items[index].icon)
                        : widget.items[index].image.contains('svg')
                            ? SvgPicture.asset(
                                widget.items[index].image,
                                colorFilter: ColorFilter.mode(
                                  widget.items[index].index == currentIndex ? widget.selectedIconColor! : widget.iconColor!,
                                  BlendMode.srcIn,
                                ),
                                width: 16,
                                height: 16,
                              )
                            : Image.asset(
                                widget.items[index].image,
                                color: widget.items[index].index == currentIndex ? widget.selectedIconColor : widget.iconColor,
                                width: 16,
                                height: 16,
                              ),
                  ),
                  const SizedBox(height: Dimensions.space5),
                  if (widget.items[index].index == currentIndex) ...[
                    widget.showDot
                        ? Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.selectedIconColor,
                            ),
                          )
                        : Text(
                            widget.items[index].name.tr,
                            textAlign: TextAlign.center,
                            style: widget.labelStyle ?? regularSmall.copyWith(color: widget.items[index].index == currentIndex ? widget.selectedIconColor : widget.iconColor),
                          ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container styleOne(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space10),
      padding: const EdgeInsets.symmetric(vertical: Dimensions.space15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.bottomNavBGColor ?? MyColor.getBottomNavBgColor(),
        borderRadius: BorderRadius.circular(widget.radius),
        boxShadow: widget.boxShadow ?? [ BoxShadow(color: MyColor.getShadowColor(), offset:const Offset(-2, -2), blurRadius: 2)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(
          widget.items.length,
          (index) => InkWell(
            onTap: () {
              currentIndex = widget.items[index].index;
              setState(() {});
              widget.onChange(currentIndex);
            },
            child: AnimatedContainer(
              duration: const Duration(microseconds: 500),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space5),
              decoration: BoxDecoration(
                color: currentIndex == widget.items[index].index ? (widget.selectedItemBGColor ?? MyColor.getPrimaryColor()) : MyColor.getTransparentColor(),
                borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.items[index].isIconData == true) ...[
                    Icon(widget.items[index].icon)
                  ] else ...[
                    widget.items[index].image.contains('svg')
                        ? SvgPicture.asset(
                            widget.items[index].image,
                            colorFilter: ColorFilter.mode(
                              widget.items[index].index == currentIndex ? widget.selectedIconColor! : widget.iconColor!,
                              BlendMode.srcIn,
                            ),
                            width: 16,
                            height: 16,
                          )
                        : Image.asset(
                            widget.items[index].image,
                            color: widget.items[index].index == currentIndex ? widget.selectedIconColor : widget.iconColor,
                            width: 16,
                            height: 16,
                          ),
                  ],
                  if (widget.items[index].index == currentIndex) ...[
                    const SizedBox(width: Dimensions.space10 / 2),
                    Text(
                      widget.items[index].name.tr,
                      textAlign: TextAlign.center,
                      style: widget.labelStyle ?? regularSmall.copyWith(color: widget.items[index].index == currentIndex ? widget.selectedIconColor : MyColor.getPrimaryTextColor()),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
