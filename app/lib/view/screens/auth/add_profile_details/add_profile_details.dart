import 'package:flutter/material.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/data/controller/auth/auth/add_profile_details.dart';
import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/view/components/buttons/custom_gradiant_button.dart';
import 'package:ovo_meet/view/components/text-field/label_text_field.dart';
import 'package:ovo_meet/view/screens/auth/add_profile_details/widgets/pick_image.dart';
import 'package:get/get.dart';

class AddProfileDetailsScreen extends StatefulWidget {
  const AddProfileDetailsScreen({super.key});

  @override
  State<AddProfileDetailsScreen> createState() => _AddProfileDetailsScreenState();
}

class _AddProfileDetailsScreenState extends State<AddProfileDetailsScreen> {
  @override
  void initState() {
    Get.put(AddProfileDetailsController());

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "",
      ),
      body: GetBuilder<AddProfileDetailsController>(
        builder: (controller) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.defaultScreenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              
                Text(
                  MyStrings.addProfileDetails,
                  style: boldOverLarge.copyWith(fontSize: Dimensions.space20),
                ),
                const SizedBox(height: Dimensions.space10),
                Text(
                  MyStrings.pleaseAddYourProfileDetrailsHere,
                  style: regularDefault.copyWith(color: MyColor.getSecondaryTextColor()),
                ),
                const SizedBox(height: Dimensions.space20),
                PickImageWidget(isEdit: true, imagePath: controller.imageUrl, onClicked: () async {}),
                const SizedBox(height: Dimensions.space20),
                LabelTextField(
                  onChanged: (v) {},
                  labelText: MyStrings.name,
                  hintText: MyStrings.enterYourPhoneNumber,
                  controller: controller.nameController,
                  textInputType: TextInputType.phone,
                  inputAction: TextInputAction.next,
                ),
                const SizedBox(height: Dimensions.space10),
                LabelTextField(
                  onChanged: (v) {},
                  labelText: MyStrings.emailAddress,
                  hintText: MyStrings.enterYourEmail,
                  controller: controller.nameController,
                  textInputType: TextInputType.phone,
                  inputAction: TextInputAction.next,
                ),
                const SizedBox(height: Dimensions.space10),
                LabelTextField(
                  onChanged: (v) {},
                  labelText: MyStrings.phoneNo,
                  hintText: MyStrings.enterYourPhoneNumber,
                  controller: controller.nameController,
                  textInputType: TextInputType.phone,
                  inputAction: TextInputAction.next,
                ),
                const SizedBox(height: Dimensions.space10),
                LabelTextField(
                  readOnly: true,
                  onChanged: (v) {},
                  labelText: MyStrings.dateofBirth,
                  hintText: MyStrings.enterYourEmail,
                  controller: controller.dateController,
                  textInputType: TextInputType.phone,
                  inputAction: TextInputAction.next,
                  onTap: () {
                    controller.selectDate(context);
                  },
                  suffixIcon: Container(
                    padding: const EdgeInsets.all(Dimensions.space12),
                    child: Image.asset(
                      MyImages.calander,
                      height: 10,
                      width: 10,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.space10),
                LabelTextField(
                  onChanged: (v) {},
                  labelText: MyStrings.enterAddress,
                  hintText: MyStrings.enterYourAddress,
                  controller: controller.addressController,
                  textInputType: TextInputType.emailAddress,
                  inputAction: TextInputAction.next,
                ),
                const SizedBox(height: Dimensions.space30),
                InkWell(
                    onTap: () {
                      Get.toNamed(RouteHelper.selectGenderScreen);
                    },
                    child: const CustomGradiantButton(text: MyStrings.continues)),
                      const SizedBox(height: Dimensions.space30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
