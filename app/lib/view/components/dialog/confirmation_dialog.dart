import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/style.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final IconData? icon;
  final Color? iconColor;
  final Color? confirmButtonColor;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmText = MyStrings.confirm,
    this.cancelText = MyStrings.cancel,
    this.icon,
    this.iconColor,
    this.confirmButtonColor,
    this.onCancel,
  }) : super(key: key);

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = MyStrings.confirm,
    String cancelText = MyStrings.cancel,
    IconData? icon,
    Color? iconColor,
    Color? confirmButtonColor,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ConfirmationDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        iconColor: iconColor,
        confirmButtonColor: confirmButtonColor,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: MyColor.getCardColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.cardRadius),
      ),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon!,
              color: iconColor ?? MyColor.cookingColor,
              size: Dimensions.iconSize + 4,
            ),
            SizedBox(width: Dimensions.space12),
          ],
          Expanded(
            child: Text(
              title,
              style: boldLarge.copyWith(
                color: MyColor.colorWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: regularDefault.copyWith(
          color: MyColor.colorWhite,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            onCancel?.call();
          },
          child: Text(
            cancelText,
            style: regularDefault.copyWith(
              color: MyColor.colorWhite.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmButtonColor ?? MyColor.getRedColor(),
            foregroundColor: MyColor.colorWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.cardRadius),
            ),
          ),
          child: Text(
            confirmText,
            style: regularDefault.copyWith(
              color: MyColor.colorWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
