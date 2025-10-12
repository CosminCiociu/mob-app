import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/route/route.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_images.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../components/bottom-sheet/custom_bottom_sheet.dart';
import '../../../components/image/custom_svg_picture.dart';
import 'filter_bottom_sheet.dart';

class SearchFilterRowWidget extends StatelessWidget {
  const SearchFilterRowWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                Get.toNamed(RouteHelper.searchConnectionScreen);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.space10,
                    vertical: Dimensions.space10),
                decoration: BoxDecoration(
                    color: MyColor.greyColor.withOpacity(.12),
                    borderRadius: BorderRadius.circular(Dimensions.space8)),
                child: const Row(
                  children: [
                    CustomSvgPicture(image: MyImages.search),
                    SizedBox(width: Dimensions.space10),
                    Text(MyStrings.search)
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: Dimensions.space10),
          InkWell(
            onTap: () {
              CustomBottomSheet(child: const FilterBottomSheet())
                  .customBottomSheet(context);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.space8),
                gradient: MyColor.primaryGradient,
              ),
              child: const Padding(
                padding: EdgeInsets.all(Dimensions.space8),
                child: CustomSvgPicture(
                  image: MyImages.filter,
                  color: MyColor.colorWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
