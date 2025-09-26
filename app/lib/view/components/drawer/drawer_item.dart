import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/view/components/image/custom_svg_picture.dart';
import 'package:get/get.dart';

class DrawerItem extends StatelessWidget {
  String svgIcon, name;
  Color? iconColor;
  TextStyle? titleStyle;
  VoidCallback onTap;
  DrawerItem({super.key, required this.svgIcon, required this.name, required this.onTap, this.iconColor, this.titleStyle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              svgIcon.contains('.svg')
                  ? CustomSvgPicture(
                      image: svgIcon,
                      color: iconColor ?? (MyColor.getIconColor()),
                      height: 20,
                    )
                  : Image.asset(
                      svgIcon,
                      color: iconColor ?? MyColor.getIconColor(),
                      height: 20,
                    ),
              const SizedBox(
                width: Dimensions.space8,
              ),
              Text(
                name.tr,
                style: titleStyle ?? regularSmall,
              ),
            ],
          ),
          
        ],
      ),
    );
  }
}
