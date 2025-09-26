import 'package:flutter/material.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/data/controller/chat/chat_controller.dart';
import 'package:ovo_meet/view/components/image/custom_svg_picture.dart';
import 'package:ovo_meet/view/components/text-field/label_text_field.dart';
import 'package:get/get.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    Get.put(ChatController());
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(
      builder: (controller) => GestureDetector(
        onTap: () {
           FocusScope.of(context).unfocus(); 
        },
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(controller.person['profilePicture']),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.person['name'],
                      style: regularMediumLarge,
                    ),
                    Text(
                      controller.person['isActive'] ? 'Active now' : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: controller.person['isActive'] ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.call),
                onPressed: () {
                  Get.toNamed(RouteHelper.audioCallScreen);
                },
              ),
              IconButton(
                icon: const Icon(Icons.videocam),
                onPressed: () { Get.toNamed(RouteHelper.audioCallScreen);},
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    bool isSentByMe = controller.messages[index]['isSentByMe'];
                    return Padding(
                      padding: const EdgeInsets.all(Dimensions.space8),
                      child: Align(
                        alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSentByMe ? MyColor.buttonColor : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.messages[index]['message'],
                                style: TextStyle(
                                  color: isSentByMe ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                controller.messages[index]['time'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSentByMe ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Dimensions.space8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: LabelTextField(
                        labelText: "",
                        hintText: MyStrings.typeaMessage.tr,
                        textInputType: TextInputType.text,
                        inputAction: TextInputAction.next,
                        controller: controller.chatController,
                        onChanged: (value) {
                          return;
                        },
                      ),
                    ),
                    const SizedBox(width: Dimensions.space10),
                    const Padding(
                      padding: EdgeInsets.only(top: Dimensions.space20),
                      child: CustomSvgPicture(
                        image: MyImages.send,
                        color: MyColor.buttonColor,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
