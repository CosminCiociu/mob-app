import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/data/controller/events/events_controller.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/view/components/image/custom_svg_picture.dart';
import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/view/components/app-bar/action_button_icon_widget.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  void initState() {
    Get.put(EventsController());
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EventsController>(
      builder: (controller) => Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: CustomAppBar(
          title: MyStrings.myEvents,
          isTitleCenter: true,
          isShowBackBtn: false,
          // Add icon button
          action: [
            ActionButtonIconWidget(
              icon: Icons.add,
              iconColor: MyColor.colorBlack,
              backgroundColor: MyColor.colorWhite,
              size: 60,
              pressed: () {
                Get.toNamed(RouteHelper.createEventForm);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
            padding: Dimensions.screenPadding,
            child: Column(
              children: [
                GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: controller.favouritePersons.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(Dimensions.space5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: InkWell(
                          onTap: () {
                            Get.toNamed(RouteHelper.partnersProfileScreen);
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                controller.favouritePersons[index]['image']
                                    .toString(),
                                fit: BoxFit.cover,
                              ),
                              const CustomSvgPicture(
                                image: MyImages.black,
                                color: MyColor.colorBlack,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                bottom: 20,
                                left: 10,
                                child: Text(
                                  controller.favouritePersons[index]['name']
                                      .toString(),
                                  style: boldLarge.copyWith(
                                      color: MyColor.colorWhite),
                                ),
                              ),
                              Positioned(
                                bottom: 5,
                                left: 10,
                                child: Text(
                                  controller.favouritePersons[index]
                                          ['occupation']
                                      .toString(),
                                  style: regularSmall.copyWith(
                                      color: MyColor.colorWhite),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: Dimensions.space100)
              ],
            )),
      ),
    );
  }
}
