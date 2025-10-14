import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/data/controller/events/my_events_controller.dart';

class EventActionMenu extends StatelessWidget {
  final Map<String, dynamic> eventData;
  final MyEventsController controller;

  const EventActionMenu({
    Key? key,
    required this.eventData,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: MyColor.getPrimaryColor(),
      ),
      onSelected: (String value) {
        switch (value) {
          case 'deactivate':
            _toggleEventStatus();
            break;
          case 'delete':
            _showDeleteConfirmation();
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'deactivate',
          child: Row(
            children: [
              Icon(
                _isEventActive()
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
                color: _isEventActive()
                    ? Colors.orange.shade600
                    : Colors.green.shade600,
                size: Dimensions.space20,
              ),
              const SizedBox(width: Dimensions.space12),
              Text(
                _isEventActive()
                    ? MyStrings.deactivateEvent
                    : MyStrings.activateEvent,
                style: TextStyle(
                  color: _isEventActive()
                      ? Colors.orange.shade600
                      : Colors.green.shade600,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: Dimensions.space20,
              ),
              const SizedBox(width: Dimensions.space12),
              Text(
                MyStrings.deleteEvent,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isEventActive() {
    final currentStatus = eventData['status'] ?? 'active';
    return currentStatus == 'active';
  }

  void _toggleEventStatus() {
    final eventId = eventData['id'];
    final currentStatus = eventData['status'] ?? 'active';

    // Show loading indicator
    Get.dialog(
      Center(
        child: CircularProgressIndicator(
          color: MyColor.getPrimaryColor(),
        ),
      ),
      barrierDismissible: false,
    );

    controller.toggleEventStatus(eventId, currentStatus).then((_) {
      // Close loading dialog
      Get.back();

      // Update local event data
      eventData['status'] = _isEventActive() ? 'inactive' : 'active';

      // The service already shows success/error messages via CustomSnackBar
      // No need to show additional snackbar here
    }).catchError((error) {
      // Close loading dialog
      Get.back();

      // The service already shows error messages via CustomSnackBar
      // No need to show additional snackbar here
    });
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: Text(
          MyStrings.deleteEvent,
          style: TextStyle(
            color: MyColor.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          MyStrings.deleteEventConfirmation,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              MyStrings.cancel,
              style: TextStyle(color: MyColor.greyColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              _deleteEvent();
            },
            child: Text(
              MyStrings.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteEvent() {
    final eventId = eventData['id'];

    // Show loading indicator
    Get.dialog(
      Center(
        child: CircularProgressIndicator(
          color: MyColor.getPrimaryColor(),
        ),
      ),
      barrierDismissible: false,
    );

    controller.deleteEvent(eventId).then((_) {
      // Close loading dialog
      Get.back();

      // Navigate back to events list
      // The service already shows success message via CustomSnackBar
      Get.back();
    }).catchError((error) {
      // Close loading dialog
      Get.back();

      // The service already shows error message via CustomSnackBar
      // No need to show additional snackbar here
    });
  }
}
