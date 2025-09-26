import 'package:flutter/material.dart';
import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/view/components/custom_loader/custom_loader.dart';
import 'package:ovo_meet/view/screens/auth/two_factor/two_factor_setup_screen/sections/two_factor_enable_section.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/my_color.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../data/controller/account/profile_controller.dart';
import '../../../../../data/controller/auth/two_factor_controller.dart';




class TwoFactorSetupScreen extends StatefulWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  State<TwoFactorSetupScreen> createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends State<TwoFactorSetupScreen> {
  @override
  void initState() {
    
    
    final controller = Get.put(TwoFactorController());
   
    final pcontroller = Get.put(ProfileController());
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TwoFactorController>(builder: (controller) {
      return GetBuilder<ProfileController>(builder: (profileController) {
        return Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          appBar: CustomAppBar(
            isShowBackBtn: true,
            title: MyStrings.twoFactorAuth.tr,
          ),
          body: profileController.isLoading
              ? const CustomLoader():
               TwoFactorEnableSection()
        );
      });
    });
  }
}
