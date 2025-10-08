import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/data/controller/home/home_controller.dart';
import 'package:get/get.dart';

class Locations extends StatelessWidget {
  const Locations({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) => Container(
        decoration: BoxDecoration(color: MyColor.getWhiteColor()),
        child: ListView.separated(
            separatorBuilder: (context, index) {
              return Container(height: .2, color: MyColor.getGreyColor());
            },
            padding: EdgeInsets.zero,
            itemCount: controller.addresses.length,
            shrinkWrap: true,
            itemBuilder: (context, i) {
              return Column(
                children: [
                  InkWell(
                      onTap: () {
                        controller.changeSelectedAddress(
                            controller.addresses[i]['street'].toString());
                        Get.back();
                      },
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.space10),
                          child: Text(
                              controller.addresses[i]['street'].toString()))),
                ],
              );
            }),
      ),
    );
  }
}
