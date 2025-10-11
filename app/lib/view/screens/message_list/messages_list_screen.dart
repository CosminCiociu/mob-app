import 'package:flutter/material.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/data/controller/message_list/message_list_controller.dart';
import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/view/components/divider/custom_divider.dart';
import 'package:ovo_meet/view/components/image/custom_svg_picture.dart';
import 'package:ovo_meet/view/components/text-field/label_text_field.dart';
import 'package:get/get.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  @override
  void initState() {
    Get.put(MessageListController());
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageListController>(
      builder: (controller) => Scaffold(
        appBar:
            const CustomAppBar(title: MyStrings.message, isTitleCenter: true),
        backgroundColor: MyColor.getScreenBgColor(),
        body: SingleChildScrollView(
            padding: Dimensions.screenPadding,
            child: Column(
              children: [
                LabelTextField(
                  labelText: "",
                  hideLabel: true,
                  hintText: MyStrings.search.tr,
                  textInputType: TextInputType.text,
                  inputAction: TextInputAction.next,
                  controller: controller.searchController,
                  onChanged: (value) {
                    return;
                  },
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: CustomSvgPicture(
                        image: MyImages.search, color: MyColor.buttonColor),
                  ),
                ),
                const SizedBox(height: Dimensions.space20),
                ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) {
                      return const CustomDivider(space: Dimensions.space8);
                    },
                    shrinkWrap: true,
                    itemCount: controller.chatList.length,
                    itemBuilder: (context, i) => ListTile(
                          onTap: () {
                            Get.toNamed(RouteHelper.chatScreen);
                          },
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                backgroundImage: AssetImage(controller
                                    .chatList[i]['profilePicture']
                                    .toString()),
                                radius: 24,
                              ),
                              controller.chatList[i]['isActive']
                                  ? Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: MyColor.greenP,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                          contentPadding: EdgeInsets.zero,
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(controller.chatList[i]['name'].toString(),
                                  style: regularLarge),
                              const SizedBox(height: Dimensions.space5),
                              Text(
                                  controller.chatList[i]['lastMessage']
                                      .toString(),
                                  style: regularSmall.copyWith(
                                      color: controller.chatList[i]
                                                      ['pendingMessages']
                                                  .toString() !=
                                              "0"
                                          ? MyColor.buttonColor
                                          : MyColor.getGreyText1()
                                              .withOpacity(.4))),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              controller.chatList[i]['pendingMessages']
                                          .toString() !=
                                      "0"
                                  ? const SizedBox()
                                  : Text("2 min ago",
                                      style: regularDefault.copyWith(
                                          color: MyColor.getGreyText1()
                                              .withOpacity(.2))),
                              controller.chatList[i]['pendingMessages']
                                          .toString() !=
                                      "0"
                                  ? CircleAvatar(
                                      backgroundColor: MyColor.buttonColor,
                                      radius: Dimensions.space12,
                                      child: Text(
                                        controller.chatList[i]
                                                ['pendingMessages']
                                            .toString(),
                                        style: regularDefault.copyWith(
                                            color: MyColor.colorWhite),
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ))
              ],
            )),
      ),
    );
  }
}
