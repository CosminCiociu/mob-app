import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/data/controller/home/home_controller.dart';
import 'package:get/get.dart';

class Locations extends StatelessWidget {
  const Locations({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        // Create a list of available location options
        final List<Map<String, String>> locationOptions = [
          {
            'label': 'Current Location',
            'address': controller.addressController.text.isNotEmpty
                ? controller.addressController.text
                : 'Getting current location...'
          },
          {'label': 'Use Custom Address', 'address': 'Enter your own address'}
        ];

        return Container(
          decoration: BoxDecoration(color: MyColor.getWhiteColor()),
          child: ListView.separated(
              separatorBuilder: (context, index) {
                return Container(height: .2, color: MyColor.getGreyColor());
              },
              padding: EdgeInsets.zero,
              itemCount: locationOptions.length,
              shrinkWrap: true,
              itemBuilder: (context, i) {
                final option = locationOptions[i];
                return Column(
                  children: [
                    InkWell(
                        onTap: () {
                          if (i == 0) {
                            // Use current location
                            final currentAddress =
                                controller.addressController.text.isNotEmpty
                                    ? controller.addressController.text
                                    : MyStrings.locationServicesDisabled;
                            controller.changeSelectedAddress(currentAddress);
                          } else {
                            // Allow custom address input
                            controller.changeSelectedAddress('Custom Location');
                          }
                          Get.back();
                        },
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.space15,
                                horizontal: Dimensions.space10),
                            child: Row(
                              children: [
                                Icon(
                                  i == 0
                                      ? Icons.my_location
                                      : Icons.edit_location,
                                  color: MyColor.getPrimaryColor(),
                                  size: 20,
                                ),
                                const SizedBox(width: Dimensions.space10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        option['label']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        option['address']!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: MyColor.getGreyColor(),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ))),
                  ],
                );
              }),
        );
      },
    );
  }
}
