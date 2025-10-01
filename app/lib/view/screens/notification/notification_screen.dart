import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';

import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/view/components/custom_loader/custom_loader.dart';
import 'package:ovo_meet/view/components/no_notification_screen.dart';
import 'package:get/get.dart';

import '../../../core/helper/date_converter.dart';
import '../../../core/utils/my_color.dart';
import '../../../data/controller/notifications/notification_controller.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    final controller = Get.put(NotificationsController());

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.lBackgroundColor,
      appBar: const CustomAppBar(
          title: MyStrings.myNotifications, isTitleCenter: true),
      body: GetBuilder<NotificationsController>(
        builder: (controller) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: Dimensions.space15, horizontal: Dimensions.space10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Dimensions.space10),
                Text(
                  MyStrings.today,
                  style: regularDefault.copyWith(color: MyColor.getGreyText()),
                ),
                const SizedBox(height: Dimensions.space10),
                ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: Dimensions.space10),
                    itemCount: controller.notifications.length,
                    itemBuilder: (context, i) => ListTile(
                          shape: BeveledRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.space8)),
                          tileColor: MyColor.colorWhite,
                          leading: SizedBox(
                            width: Dimensions.space70,
                            height: Dimensions.space100,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.asset(
                                    controller.notifications[i]['image']
                                        .toString(),
                                    fit: BoxFit.cover)),
                          ),
                          title: Text(
                            controller.notifications[i]['notification']
                                .toString(),
                            style: boldDefault.copyWith(
                                fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            controller.notifications[i]['time'].toString(),
                            style: regularSmall.copyWith(
                                color: MyColor.getGreyText1()),
                          ),
                        )),
                const SizedBox(height: Dimensions.space10),
                Text(
                  MyStrings.today,
                  style: regularDefault.copyWith(color: MyColor.getGreyText()),
                ),
                const SizedBox(height: Dimensions.space10),
                ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: Dimensions.space10),
                    itemCount: controller.notifications.length,
                    itemBuilder: (context, i) => ListTile(
                          shape: BeveledRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.space8)),
                          tileColor: MyColor.colorWhite,
                          leading: SizedBox(
                            width: Dimensions.space70,
                            height: Dimensions.space100,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.asset(
                                    controller.notifications[i]['image']
                                        .toString(),
                                    fit: BoxFit.cover)),
                          ),
                          title: Text(
                            controller.notifications[i]['notification']
                                .toString(),
                            style: boldDefault.copyWith(
                                fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            controller.notifications[i]['time'].toString(),
                            style: regularSmall.copyWith(
                                color: MyColor.getGreyText1()),
                          ),
                        )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
