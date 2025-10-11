import 'package:flutter/material.dart';
import 'package:ovo_meet/view/components/custom_loader/custom_loader.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/my_color.dart';

class RoundedButton extends StatelessWidget {
  final bool isColorChange;
  final String text;
  final VoidCallback press;
  final Color color;
  final Color? textColor;
  final double width;
  final double horizontalPadding;
  final double verticalPadding;
  final double cornerRadius;
  final bool isOutlined;
  final Widget? child;
  final bool isLoading;

  const RoundedButton({
    super.key,
    this.isColorChange = false,
    this.width = 1,
    this.child,
    this.cornerRadius = 6,
    required this.text,
    required this.press,
    this.isOutlined = false,
    this.horizontalPadding = 35,
    this.verticalPadding = 18,
    this.color = MyColor.primaryColor,
    this.textColor = MyColor.colorWhite,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return child != null
        ? InkWell(
            onTap: press,
            splashColor: MyColor.getScreenBgColor(),
            child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, vertical: verticalPadding),
                width: size.width * width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(cornerRadius),
                    color: isColorChange
                        ? color
                        : MyColor.getPrimaryButtonColor()),
                child: Center(
                    child: isLoading
                        ? CustomLoader(
                            loaderColor: textColor ?? MyColor.getCardColor())
                        : Text(text.tr,
                            style: TextStyle(
                                color: isColorChange
                                    ? textColor
                                    : MyColor.getTextColor(),
                                fontSize: 14,
                                fontWeight: FontWeight.w500)))),
          )
        : isOutlined
            ? Material(
                child: InkWell(
                  onTap: press,
                  splashColor: MyColor.getScreenBgColor(),
                  child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: verticalPadding),
                      width: size.width * width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(cornerRadius),
                          color: isColorChange
                              ? color
                              : MyColor.getPrimaryButtonColor()),
                      child: Center(
                          child: isLoading
                              ? CustomLoader(
                                  loaderColor:
                                      textColor ?? MyColor.getCardColor())
                              : Text(text.tr,
                                  style: TextStyle(
                                      color: isColorChange
                                          ? textColor
                                          : MyColor.getPrimaryTextColor(),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)))),
                ),
              )
            : SizedBox(
                width: size.width * width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(cornerRadius),
                  child: ElevatedButton(
                    onPressed: press,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        shadowColor: MyColor.getTransparentColor(),
                        padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: verticalPadding),
                        textStyle: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    child: isLoading
                        ? CustomLoader(
                            loaderColor: textColor ?? MyColor.getCardColor())
                        : Text(
                            text.tr,
                            style: TextStyle(color: textColor),
                          ),
                  ),
                ),
              );
  }
}
