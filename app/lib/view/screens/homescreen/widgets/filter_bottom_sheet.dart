import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/data/controller/home/home_controller.dart';
import 'package:ovo_meet/view/components/alert-dialog/custom_alert_dialog.dart';
import 'package:ovo_meet/view/components/bottom-sheet/bottom_sheet_bar.dart';
import 'package:ovo_meet/view/components/buttons/custom_gradiant_button.dart';
import 'package:ovo_meet/view/components/divider/custom_divider.dart';
import 'package:ovo_meet/view/components/image/custom_svg_picture.dart';
import 'package:ovo_meet/view/components/text-field/label_text_field.dart';
import 'package:ovo_meet/view/screens/homescreen/widgets/locations.dart';
import 'package:get/get.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              const BottomSheetBar(),
              Align(
                  alignment: Alignment.topLeft,
                  child: Text(MyStrings.filter, style: boldOverLarge)),
              const CustomDivider(),
              LabelTextField(
                readOnly: true,
                onChanged: (v) {},
                labelText: MyStrings.location,
                hintText: MyStrings.enterAddress,
                controller: controller.addressController,
                textInputType: TextInputType.phone,
                inputAction: TextInputAction.next,
                onTap: () {
                  CustomAlertDialog(child: const Locations())
                      .customAlertDialog(context);
                },
                suffixIcon: Container(
                  padding: const EdgeInsets.all(Dimensions.space15),
                  child: const CustomSvgPicture(
                    image: MyImages.arrowDown,
                    height: 5,
                    width: 5,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.space20),
              Align(
                  alignment: Alignment.topLeft,
                  child: Text(MyStrings.distance, style: boldOverLarge)),
              Slider(
                activeColor: MyColor.buttonColor,
                divisions: 25,
                label: "${controller.distance} Km",
                value: controller.distance.toDouble(),
                onChanged: (value) {
                  controller.distance = value.toInt();
                  controller.update();
                },
                min: 5,
                max: 500,
              ),
              const SizedBox(height: Dimensions.space15),
              Align(
                  alignment: Alignment.topLeft,
                  child: Text(MyStrings.age, style: boldOverLarge)),
              RangeSlider(
                activeColor: MyColor.buttonColor,
                inactiveColor: MyColor.appBarColor,
                labels: RangeLabels(
                  "${controller.rangeValues.start.round()} Km",
                  "${controller.rangeValues.end.round()} Km",
                ),
                values: controller.rangeValues,
                onChanged: (RangeValues values) {
                  controller.rangeValues = values;
                  controller.update();
                },
                min: 5,
                max: 100,
                divisions: 95,
              ),
              Align(
                  alignment: Alignment.topLeft,
                  child: Text(MyStrings.interstedIn, style: boldOverLarge)),
              const SizedBox(height: Dimensions.space20),
              GridView.builder(
                  shrinkWrap: true,
                  itemCount: controller.interestedIn.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 3,
                      crossAxisSpacing: 10),
                  itemBuilder: (context, i) {
                    return InkWell(
                      onTap: () {
                        controller.changeStatus(i);
                      },
                      child: CustomGradiantButton(
                        text: controller.interestedIn[i]['genders'].toString(),
                        hasBorder:
                            controller.interestedIn[i]['status'] ? true : false,
                        textColor: controller.interestedIn[i]['status']
                            ? MyColor.buttonColor
                            : MyColor.colorWhite,
                        padding: 10,
                      ),
                    );
                  }),
              const SizedBox(height: Dimensions.space25),
              Row(
                children: [
                  Expanded(
                      child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: const CustomGradiantButton(
                      text: MyStrings.other,
                      hasBorder: true,
                      textColor: MyColor.buttonColor,
                      padding: 13,
                    ),
                  )),
                  const SizedBox(width: Dimensions.space15),
                  Expanded(
                      child: InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: const CustomGradiantButton(
                              text: MyStrings.apply))),
                ],
              ),
              const SizedBox(height: Dimensions.space15),
            ],
          ),
        ),
      ),
    );
  }
}
