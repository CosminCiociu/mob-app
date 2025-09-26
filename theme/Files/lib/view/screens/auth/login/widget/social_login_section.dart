import 'package:flutter/material.dart';
import 'package:ovo_meet/data/controller/auth/social_login_controller.dart';

import 'package:get/get.dart';

import '../../../../../core/utils/my_color.dart';
import '../../../../../core/utils/my_images.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../core/utils/style.dart';
import '../../../../components/buttons/custom_outlined_button.dart';

class SocialLoginSection extends StatefulWidget {
  const SocialLoginSection({super.key});

  @override
  State<SocialLoginSection> createState() => _SocialLoginSectionState();
}

class _SocialLoginSectionState extends State<SocialLoginSection> {

  @override
  void initState() {
    
    Get.put(SocialLoginController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SocialLoginController>(builder: (controller){
      return Visibility(
        visible: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(child: Container(height: 1,width: double.infinity,color: MyColor.getGreyColor().withOpacity(.2))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    MyStrings.orSignupWith.tr,
                    style: lightDefault.copyWith(color: MyColor.getSecondaryTextColor()),
                  ),
                ),
                Expanded(child: Container(height: 1,width: double.infinity,color: MyColor.getGreyColor().withOpacity(.2))),
              ],
            ),
         
              const SizedBox(height: 15),
             Row(children: [ Expanded(
               child: CustomOutlinedBtn(
                  btnText: MyStrings.google.tr,
                  onTap: () {
                  },
                  isLoading: controller.isGoogleSignInLoading,
                  textColor: MyColor.getPrimaryTextColor(),
                  radius: 10,
                  height: 55,
                  icon: Image.asset(
                    MyImages.google,
                    height: 22,
                    width: 22,
                  ),
                ),
             ),
           
             
           
              const SizedBox(width: 15),
              Expanded(
                child: CustomOutlinedBtn(
                  btnText: MyStrings.facebook.tr,
                  onTap: () {},
                  textColor: MyColor.getPrimaryTextColor(),
                  radius: 10,
                  height: 55,
                  icon: Image.asset(
                    MyImages.facebook,
                    height: 22,
                    width: 22,
                  ),
                ),
              ),],)
         
          ],
        ),
      );
    });
  }
}
