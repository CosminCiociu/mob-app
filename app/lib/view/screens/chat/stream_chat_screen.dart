import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Temporarily commented to avoid translation issues
// import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:ovo_meet/data/controller/chat/chat_controller.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/view/components/text-field/label_text_field.dart';

class ChatScreen extends StatefulWidget {
  final String? otherUserId;
  final String? otherUserName;
  final String? otherUserImage;

  const ChatScreen({
    super.key,
    this.otherUserId,
    this.otherUserName,
    this.otherUserImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    Get.put(ChatController());

    // Setup chat with the other user if parameters are provided
    if (widget.otherUserId != null && widget.otherUserName != null) {
      _setupChat();
    }
  }

  void _setupChat() {
    final controller = Get.find<ChatController>();
    controller.setupChatWithUser(
      otherUserId: widget.otherUserId!,
      otherUserName: widget.otherUserName!,
      otherUserImage: widget.otherUserImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          appBar: CustomAppBar(
            title: controller.person['name'] ?? 'Chat',
            isShowBackBtn: true,
          ),
          body: controller.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : controller.currentChannel != null
                  ? _buildStreamChatUI(controller)
                  : _buildFallbackChatUI(controller),
        );
      },
    );
  }

  Widget _buildStreamChatUI(ChatController controller) {
    // Temporarily using fallback UI to avoid Stream Chat translation issues
    return _buildFallbackChatUI(controller);
  }

  Widget _buildFallbackChatUI(ChatController controller) {
    return Column(
      children: [
        // Connection Status Banner
        if (!controller.isConnected.value)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.orange,
            child: const Text(
              'Connecting to chat...',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),

        // Messages List (using mock data)
        Expanded(
          child: Obx(() {
            final messages = controller.mockMessages;

            return ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                final isFromCurrentUser =
                    controller.isMessageFromCurrentUser(message);

                return _buildMessageBubble(
                  message: message,
                  isFromCurrentUser: isFromCurrentUser,
                  controller: controller,
                );
              },
            );
          }),
        ),

        // Message Input
        Container(
          padding: const EdgeInsets.all(Dimensions.space8),
          decoration: BoxDecoration(
            color: MyColor.getCardBgColor(),
            border: Border(
              top: BorderSide(
                color: MyColor.getBorderColor().withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: LabelTextField(
                  labelText: "",
                  hintText: MyStrings.typeaMessage.tr,
                  textInputType: TextInputType.text,
                  inputAction: TextInputAction.send,
                  controller: controller.chatController,
                  onChanged: (value) {
                    return;
                  },
                ),
              ),
              const SizedBox(width: Dimensions.space8),
              GestureDetector(
                onTap: () => _sendMessage(controller),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: MyColor.buttonColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble({
    required Map<String, dynamic> message,
    required bool isFromCurrentUser,
    required ChatController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.space12,
        vertical: 4,
      ),
      child: Align(
        alignment:
            isFromCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isFromCurrentUser
                ? MyColor.buttonColor
                : MyColor.getCardBgColor(),
            borderRadius: BorderRadius.circular(20),
            border: !isFromCurrentUser
                ? Border.all(
                    color: MyColor.getBorderColor().withOpacity(0.1),
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: isFromCurrentUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                message['message'] ?? '',
                style: TextStyle(
                  color:
                      isFromCurrentUser ? Colors.white : MyColor.getTextColor(),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                controller.formatMessageTime(DateTime.now()
                    .subtract(Duration(minutes: message['timeAgo'] ?? 0))),
                style: TextStyle(
                  fontSize: 10,
                  color: isFromCurrentUser
                      ? Colors.white70
                      : MyColor.getGreyText(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage(ChatController controller) {
    final text = controller.chatController.text.trim();
    if (text.isEmpty) return;

    if (controller.currentChannel != null) {
      // Send via Stream Chat
      controller.sendMessage();
    } else {
      // Fallback: Add to mock messages for demo
      controller.sendMockMessage();
    }
  }
}
