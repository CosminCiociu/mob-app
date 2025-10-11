import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:get/get.dart';

class DeleteAccountBottomsheetBody extends StatefulWidget {
  const DeleteAccountBottomsheetBody({
    super.key,
  });

  @override
  State<DeleteAccountBottomsheetBody> createState() =>
      _DeleteAccountBottomsheetBodyState();
}

class _DeleteAccountBottomsheetBodyState
    extends State<DeleteAccountBottomsheetBody> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      return SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: Dimensions.space25),
            Image.asset(
              MyImages.userdeleteImage,
              width: 120,
              height: 120,
              // fit: BoxFit.cover,
            ),
            const SizedBox(height: Dimensions.space25),
            Text(
              MyStrings.deleteYourAccount.tr,
              style: mediumDefault.copyWith(
                  color: MyColor.getBlackColor(),
                  fontSize: Dimensions.fontLarge),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.space25),
            Text(
              MyStrings.deleteBottomSheetSubtitle.tr,
              style: regularDefault.copyWith(
                  color: MyColor.getGreyColor().withOpacity(0.8),
                  fontSize: Dimensions.fontLarge),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.space40),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: context.width,
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.space15,
                    vertical: Dimensions.space17),
                decoration: BoxDecoration(
                  color: MyColor.getDeleteButtonColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    MyStrings.deleteAccount.tr,
                    style: mediumDefault.copyWith(
                        color: MyColor.getDeleteButtonTextColor(),
                        fontSize: Dimensions.fontLarge),
                  ),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.space10),
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Container(
                width: context.width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: MyColor.getGreyColor().withOpacity(.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    MyStrings.cancel.tr,
                    style: mediumDefault.copyWith(
                        color: MyColor.getBlackColor(),
                        fontSize: Dimensions.fontLarge),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
