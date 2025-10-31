import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
import '../../../data/controller/event_members_controller.dart';
import '../../screens/event/event_members_screen_v2.dart';

class EventMembersButton extends StatelessWidget {
  final String eventId;
  final String? eventCreatorId;
  final bool showOnlyForCreator;
  final ButtonStyle? customStyle;
  final String? customText;
  final IconData? customIcon;

  const EventMembersButton({
    Key? key,
    required this.eventId,
    this.eventCreatorId,
    this.showOnlyForCreator = true,
    this.customStyle,
    this.customText,
    this.customIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isEventCreator = currentUser?.uid == eventCreatorId;

    // If set to show only for creator and user is not creator, don't show button
    if (showOnlyForCreator && !isEventCreator) {
      return const SizedBox.shrink();
    }

    return ElevatedButton.icon(
      onPressed: () => _openEventMembersScreen(),
      icon: Icon(customIcon ?? Icons.group_outlined),
      label: Text(customText ?? MyStrings.viewMembers),
      style: customStyle ??
          ElevatedButton.styleFrom(
            backgroundColor: MyColor.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.space15,
              vertical: Dimensions.space10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.space8),
            ),
          ),
    );
  }

  void _openEventMembersScreen() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      Get.snackbar(
        'Error',
        'You must be logged in to view members',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Initialize the controller with event data
    final controller = Get.put(EventMembersController());
    controller.eventId.value = eventId;
    controller.currentUserId.value = currentUserId;

    // Navigate to members screen
    Get.to(() => const EventMembersScreen());
  }
}

// Alternative compact icon button version
class EventMembersIconButton extends StatelessWidget {
  final String eventId;
  final String? eventCreatorId;
  final bool showOnlyForCreator;
  final Color? iconColor;
  final double? iconSize;

  const EventMembersIconButton({
    Key? key,
    required this.eventId,
    this.eventCreatorId,
    this.showOnlyForCreator = true,
    this.iconColor,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isEventCreator = currentUser?.uid == eventCreatorId;

    // If set to show only for creator and user is not creator, don't show button
    if (showOnlyForCreator && !isEventCreator) {
      return const SizedBox.shrink();
    }

    return IconButton(
      onPressed: () => _openEventMembersScreen(),
      icon: Icon(
        Icons.group_outlined,
        color: iconColor ?? MyColor.primaryColor,
        size: iconSize ?? 24,
      ),
      tooltip: MyStrings.viewMembers,
    );
  }

  void _openEventMembersScreen() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      Get.snackbar(
        'Error',
        'You must be logged in to view members',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Initialize the controller with event data
    final controller = Get.put(EventMembersController());
    controller.eventId.value = eventId;
    controller.currentUserId.value = currentUserId;

    // Navigate to members screen
    Get.to(() => const EventMembersScreen());
  }
}
