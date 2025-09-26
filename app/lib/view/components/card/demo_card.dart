import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/core/utils/util.dart';
import 'package:ovo_meet/data/controller/common/theme_controller.dart';
import 'package:ovo_meet/view/components/image/my_image_widget.dart';
import 'package:get/get.dart';

class DemoCard extends StatelessWidget {
  DemoCard({super.key});
  ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space15),
      margin: const EdgeInsets.only(right: Dimensions.space10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: MyColor.getCardBgColor(),
        boxShadow: MyUtils.getShadow(color: MyColor.getShadowColor(), blurRadius: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const MyImageWidget(
            imageUrl: 'http://surl.li/rxexk',
            radius: 30,
            height: 55,
            width: 55,
          ),
          const SizedBox(height: Dimensions.space10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Dr. Kenny Adeola",
                // style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: Dimensions.fontLarge, fontWeight: FontWeight.w700),
                style: title.copyWith(color: MyColor.getTextColor(), fontSize: 15),
              ),
              const SizedBox(height: Dimensions.space2),
              Text("General Practitioner", style: regularSmall),
              const SizedBox(height: Dimensions.space5),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: MyColor.getPrimaryColor(),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                         Icon(
                          CupertinoIcons.star_fill,
                          color: MyColor.getPendingColor(),
                          size: 14,
                        ),
                        const SizedBox(width: Dimensions.space2),
                        Text(
                          '4.8',
                          style: regularSmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Dimensions.space10),
                  Text('(130 reviews)', style: regularSmall),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
