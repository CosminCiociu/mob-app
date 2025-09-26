import 'package:flutter/material.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/view/components/buttons/custom_gradiant_button.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/data/controller/account/profile_controller.dart';
import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/view/components/custom_loader/custom_loader.dart';
import 'package:ovo_meet/view/screens/Profile/widget/profile_top_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    Get.put(ProfileController());
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) => Scaffold(
        appBar: CustomAppBar(
          isTitleCenter: true,
          title: MyStrings.profile.tr,
          bgColor: MyColor.getAppBarColor(),
        ),
        body: controller.isLoading
            ? const CustomLoader()
            :  Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  padding:const EdgeInsets.only(left: Dimensions.space15, right: Dimensions.space15, top: Dimensions.space20, bottom: Dimensions.space20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     const ProfileTopSection(),
                    const SizedBox(height: Dimensions.space150),
                       InkWell(
          onTap: () {
            Get.offAllNamed(RouteHelper.loginScreen);
          },
          child: Container(margin: const EdgeInsets.symmetric(vertical: Dimensions.space80, horizontal: Dimensions.defaultScreenPadding), height: Dimensions.space60, child: const CustomGradiantButton(text: MyStrings.logout)),
        ),
                    ],
                  ),
                ),
              ),
      
      ),
    );
  }
}
