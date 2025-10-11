import 'package:flutter/material.dart';
import 'package:ovo_meet/core/helper/string_format_helper.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/view/components/image/my_image_widget.dart';
import 'package:get/get.dart';

class DrawerUserCard extends StatelessWidget {
  final String? username, fullName, subtitle;
  final String? image;
  final bool isAsset;
  final bool noAvatar;
  final TextStyle? titleStyle, subtitleStyle;
  final Widget? rightWidget;
  final Widget? imgWidget;
  final double? imgHeight;
  final double? imgWidth;
  const DrawerUserCard({
    super.key,
    this.username,
    this.fullName,
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.image = MyImages.user,
    this.isAsset = true,
    this.noAvatar = false,
    this.rightWidget,
    this.imgHeight,
    this.imgWidth,
    this.imgWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                imgWidget == null
                    ? MyImageWidget(
                        imageUrl: image.toString(),
                        isProfile: true,
                        height: imgHeight,
                        width: imgWidth,
                      )
                    : imgWidget!,
                const SizedBox(
                  width: Dimensions.space15 + 1,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          "$fullName".toCapitalized().tr,
                          style: titleStyle ??
                              boldDefault.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontSize: Dimensions.fontLarge + 3,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(
                        height: Dimensions.space3,
                      ),
                      Text(
                        "$username".tr,
                        style: titleStyle ??
                            regularDefault.copyWith(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: Dimensions.fontSmall,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: Dimensions.space5,
                      ),
                      Text(
                        subtitle?.tr ?? "",
                        style: subtitleStyle ??
                            regularDefault.copyWith(
                              fontSize: Dimensions.fontSmall,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          rightWidget ?? const SizedBox.shrink()
        ],
      ),
    );
  }
}
