import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/core/utils/event_formatter.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/data/controller/events/my_events_controller.dart';
import 'event_preview_modal.dart';

class EventContextMenu extends StatelessWidget {
  final Map<String, dynamic> event;
  final MyEventsController controller;
  final VoidCallback onDeletePressed;

  const EventContextMenu({
    Key? key,
    required this.event,
    required this.controller,
    required this.onDeletePressed,
  }) : super(key: key);

  static void show(BuildContext context, Map<String, dynamic> event,
      MyEventsController controller, VoidCallback onDeletePressed) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return EventContextMenu(
          event: event,
          controller: controller,
          onDeletePressed: onDeletePressed,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.extraRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: Dimensions.shadowBlur,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: Dimensions.space40,
            height: Dimensions.badgeRadius,
            margin: const EdgeInsets.only(
                top: Dimensions.space12, bottom: Dimensions.space8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(Dimensions.space2),
            ),
          ),

          // Header with event info
          _buildHeader(context),

          // Menu options
          _buildMenuOptions(context),

          // Cancel button
          _buildCancelButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: MyColor.primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.extraRadius),
          topRight: Radius.circular(Dimensions.extraRadius),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event['eventName'] ?? 'Untitled Event',
            style: boldLarge.copyWith(
              color: MyColor.getTextColor(),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Dimensions.badgeRadius),
          if (event['dateTime'] != null)
            Text(
              EventFormatter.formatEventDateTime(event['dateTime']),
              style: regularSmall.copyWith(
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.space8),
      child: Column(
        children: [
          // Preview Event Option
          _buildMenuItem(
            icon: Icons.visibility,
            iconColor: Colors.teal.shade600,
            iconBgColor: Colors.teal.withOpacity(0.1),
            title: 'Preview Event',
            subtitle: 'View event details',
            onTap: () {
              Navigator.of(context).pop();
              EventPreviewModal.show(context, event);
            },
          ),

          // Edit Event Option
          _buildMenuItem(
            icon: Icons.edit,
            iconColor: Colors.blue.shade600,
            iconBgColor: Colors.blue.withOpacity(0.1),
            title: 'Edit Event',
            subtitle: 'Modify event details',
            onTap: () {
              Navigator.of(context).pop();
              Get.toNamed(RouteHelper.editEventForm, arguments: event);
            },
          ),

          // Activate/Deactivate Event Option
          _buildMenuItem(
            icon: _getStatusIcon(),
            iconColor: _getStatusIconColor(),
            iconBgColor: _getStatusIconColor().withOpacity(0.1),
            title: _getStatusTitle(),
            subtitle: _getStatusSubtitle(),
            onTap: () {
              Navigator.of(context).pop();
              _toggleEventStatus();
            },
          ),

          // Share Event Option
          _buildMenuItem(
            icon: Icons.share,
            iconColor: Colors.purple.shade600,
            iconBgColor: Colors.purple.withOpacity(0.1),
            title: 'Share Event',
            subtitle: 'Share event details with others',
            onTap: () {
              Navigator.of(context).pop();
              Get.snackbar(
                'Coming Soon',
                'Share functionality will be available soon',
                backgroundColor: MyColor.primaryColor.withOpacity(0.1),
                colorText: MyColor.primaryColor,
                duration: const Duration(seconds: 2),
              );
            },
          ),

          // Divider
          Divider(
            color: Colors.grey.withOpacity(0.2),
            height: 1,
          ),

          // Delete Event Option
          _buildMenuItem(
            icon: Icons.delete_outline,
            iconColor: Colors.red,
            iconBgColor: Colors.red.withOpacity(0.1),
            title: MyStrings.deleteEvent,
            subtitle: 'Remove this event permanently',
            titleColor: Colors.red,
            onTap: () {
              Navigator.of(context).pop();
              onDeletePressed();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: Dimensions.space15, vertical: Dimensions.badgeRadius),
      leading: Container(
        padding: const EdgeInsets.all(Dimensions.space8),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(Dimensions.cardRadius),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: Dimensions.space20,
        ),
      ),
      title: Text(
        title,
        style: regularDefault.copyWith(
          color: titleColor ?? MyColor.getTextColor(),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: regularSmall.copyWith(
          color: Colors.grey,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(Dimensions.space15, Dimensions.space8,
          Dimensions.space15, Dimensions.space25),
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.withOpacity(0.1),
          foregroundColor: MyColor.getTextColor(),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: Dimensions.space15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.largeRadius),
          ),
        ),
        child: Text(
          'Cancel',
          style: regularDefault.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Helper methods for activate/deactivate functionality
  String get _currentStatus => event['status'] ?? 'active';

  bool get _isActive => _currentStatus == 'active';

  IconData _getStatusIcon() {
    return _isActive ? Icons.pause_circle_outline : Icons.play_circle_outline;
  }

  Color _getStatusIconColor() {
    return _isActive ? Colors.orange.shade600 : Colors.green.shade600;
  }

  String _getStatusTitle() {
    return _isActive ? 'Deactivate Event' : 'Activate Event';
  }

  String _getStatusSubtitle() {
    return _isActive ? 'Make this event inactive' : 'Make this event active';
  }

  void _toggleEventStatus() {
    controller.toggleEventStatus(event['id'], _currentStatus);
  }
}
