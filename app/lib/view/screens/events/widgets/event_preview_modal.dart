import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/event_formatter.dart';
import 'package:ovo_meet/data/controller/events/my_events_controller.dart';
import 'package:ovo_meet/view/components/dialog/confirmation_dialog.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'event_context_menu.dart';

class EventPreviewModal extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventPreviewModal({
    Key? key,
    required this.event,
  }) : super(key: key);

  static void show(BuildContext context, Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventPreviewModal(event: event),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, String eventId, String eventName) {
    ConfirmationDialog.show(
      context: context,
      title: MyStrings.deleteEvent,
      message:
          'Are you sure you want to delete "$eventName"?\n\nThis action cannot be undone.',
      confirmText: 'Delete',
      cancelText: MyStrings.cancel,
      icon: Icons.delete_outline,
      onConfirm: () {
        final controller = Get.find<MyEventsController>();
        controller.deleteEvent(eventId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header with event gradient background
          Container(
            height: 240,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MyColor.primaryColor,
                  MyColor.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Back button and title
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.space15),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'Event Preview',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            final controller = Get.find<MyEventsController>();
                            EventContextMenu.show(
                              context,
                              event,
                              controller,
                              () => _showDeleteConfirmation(
                                context,
                                event['eventId'] ?? '',
                                event['eventName'] ?? 'Untitled Event',
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Event name and date
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.space20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['eventName'] ?? 'Untitled Event',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: Dimensions.space8),
                          Text(
                            EventFormatter.formatEventDateTime(
                                event['dateTime']),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: Dimensions.space8),
                          Text(
                            _getCategoryText(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar placeholder
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Looking for',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: Dimensions.space15),

                  Text(
                    'People interested in ${_getCategoryText().toLowerCase()} events',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: Dimensions.space25),

                  // Event Details Section
                  Text(
                    'Event Details',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: Dimensions.space15),

                  // Details list
                  _buildDetailItem(
                    icon: Icons.category,
                    label: 'Category',
                    value: _getCategoryText(),
                  ),

                  _buildDetailItem(
                    icon: Icons.info_outline,
                    label: 'Status',
                    value: _getStatusText(),
                  ),

                  _buildDetailItem(
                    icon: Icons.person,
                    label: 'Organized by',
                    value: _getOrganizerText(),
                  ),

                  if (event['location'] != null) ...[
                    _buildDetailItem(
                      icon: Icons.location_on,
                      label: 'Location',
                      value: _getLocationText(),
                    ),
                  ],

                  if (event['maxAttendees'] != null) ...[
                    _buildDetailItem(
                      icon: Icons.people,
                      label: 'Max Attendees',
                      value: '${event['maxAttendees']} people',
                    ),
                  ],

                  _buildDetailItem(
                    icon: Icons.how_to_reg,
                    label: 'Join Approval',
                    value: _getApprovalText(),
                  ),

                  if (event['details'] != null &&
                      event['details'].toString().isNotEmpty) ...[
                    const SizedBox(height: Dimensions.space15),
                    Text(
                      'Description',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: Dimensions.space8),
                    Text(
                      event['details'] ?? '',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom action buttons
          Container(
            padding: const EdgeInsets.all(Dimensions.space20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Dislike button
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade100,
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Add dislike functionality here
                    },
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey.shade600,
                      size: 24,
                    ),
                  ),
                ),

                // Like button
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: MyColor.primaryColor.withOpacity(0.1),
                    border: Border.all(
                      color: MyColor.primaryColor,
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Add like functionality here
                    },
                    icon: Icon(
                      Icons.favorite_outline,
                      color: MyColor.primaryColor,
                      size: 24,
                    ),
                  ),
                ),

                // Join/Accept button
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.green,
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Add join/accept functionality here
                    },
                    icon: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.space12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: Dimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryText() {
    final categoryId = event['categoryId'] ?? '';
    final subcategoryId = event['subcategoryId'] ?? '';

    if (categoryId.isNotEmpty && subcategoryId.isNotEmpty) {
      return '${categoryId.toUpperCase()}_${subcategoryId.toUpperCase()}';
    } else if (categoryId.isNotEmpty) {
      return categoryId.toUpperCase();
    } else {
      return 'GENERAL';
    }
  }

  String _getStatusText() {
    final status = event['status'] ?? 'active';
    switch (status.toLowerCase()) {
      case 'active':
        return 'Past event';
      case 'upcoming':
        return 'Upcoming';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _getOrganizerText() {
    final createdBy = event['createdBy'] ?? '';
    // For now, show a formatted user ID. In a real app, you'd fetch the user's name
    if (createdBy.isNotEmpty && createdBy.length > 8) {
      return 'User ${createdBy.substring(0, 8).toUpperCase()}...';
    }
    return 'Unknown User';
  }

  String _getLocationText() {
    final location = event['location'];
    if (location != null && location is Map<String, dynamic>) {
      final address = location['address'];
      if (address != null && address is Map<String, dynamic>) {
        final locality = address['locality'] ?? '';
        final adminArea = address['administrativeArea'] ?? '';
        if (locality.isNotEmpty && adminArea.isNotEmpty) {
          return '$locality, $adminArea';
        } else if (locality.isNotEmpty) {
          return locality;
        } else if (adminArea.isNotEmpty) {
          return adminArea;
        }
      }
    }
    return 'Location not specified';
  }

  String _getApprovalText() {
    final requiresApproval = event['requiresApproval'] ?? true;
    return requiresApproval ? 'Approval required' : 'Auto-accept';
  }
}
