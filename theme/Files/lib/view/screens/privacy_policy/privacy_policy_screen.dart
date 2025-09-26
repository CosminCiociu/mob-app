import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:const CustomAppBar(title: MyStrings.privacyPolicy,isTitleCenter: true,),
      body: SingleChildScrollView(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.defaultScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(MyStrings.lastUpdate+MyStrings.demoDate,style: regularDefault.copyWith(color: MyColor.getGreyText1(),)),
          const SizedBox(height: Dimensions.space15),
         const Text(MyStrings.pleaseReadThesePrivacyPolicy),
          const SizedBox(height: Dimensions.space15),
          Text(MyStrings.privacyPolicy,style: boldExtraLarge.copyWith(color: MyColor.buttonColor)),
          const SizedBox(height: Dimensions.space15),
         const Text(MyStrings.policiesofUse),
        ]),
      ),),
    );
  }
}