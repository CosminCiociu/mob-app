import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/core/utils/event_formatter.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/controller/event_members_controller.dart';
import '../../event/event_members_screen.dart';

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onLongPress;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onTap;

  const EventCard({
    Key? key,
    required this.event,
    required this.onLongPress,
    this.onLongPressStart,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isUpcoming = EventFormatter.isUpcoming(event['dateTime']);
    final Color cardColor =
        isUpcoming ? MyColor.colorWhite : MyColor.colorWhite.withOpacity(0.95);

    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        HapticFeedback.mediumImpact();
        onLongPress();
      },
      onLongPressStart: (details) {
        HapticFeedback.selectionClick();
        onLongPressStart?.call();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.space20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(Dimensions.space20),
          boxShadow: [
            BoxShadow(
              color: MyColor.primaryColor.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: isUpcoming
                ? MyColor.primaryColor.withOpacity(0.15)
                : Colors.grey.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image and Header
            _buildImageHeader(context, isUpcoming),

            // Event Details
            Padding(
              padding: const EdgeInsets.all(Dimensions.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventTitle(isUpcoming),
                  const SizedBox(height: Dimensions.space12),
                  _buildDateTime(isUpcoming),
                  const SizedBox(height: Dimensions.space10),
                  _buildLocation(),
                  const SizedBox(height: Dimensions.space15),
                  _buildDescription(),
                  const SizedBox(height: Dimensions.space15),
                  _buildConstraintsBadges(),
                  const SizedBox(height: Dimensions.space12),
                  _buildFooterActions(isUpcoming),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context, bool isUpcoming) {
    return Stack(
      children: [
        // Background Image or Gradient
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(Dimensions.space20),
              topRight: Radius.circular(Dimensions.space20),
            ),
            gradient: _buildEventGradient(isUpcoming),
          ),
          child: event['imageUrl'] != null &&
                  event['imageUrl'].toString().isNotEmpty
              ? _buildEventImage()
              : _buildDefaultImageContent(),
        ),

        // Status Badge
        Positioned(
          top: Dimensions.space15,
          right: Dimensions.space15,
          child: _buildStatusBadge(isUpcoming),
        ),

        // Category Badge
        if (event['categoryId'] != null)
          Positioned(
            top: Dimensions.space15,
            left: Dimensions.space15,
            child: _buildCategoryBadge(),
          ),
      ],
    );
  }

  Widget _buildEventImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(Dimensions.space20),
        topRight: Radius.circular(Dimensions.space20),
      ),
      child: event['imageUrl'].toString().startsWith('/')
          ? Image.file(
              File(event['imageUrl']),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultImageContent();
              },
            )
          : Image.asset(
              event['imageUrl'],
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultImageContent();
              },
            ),
    );
  }

  Widget _buildDefaultImageContent() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.space20),
          topRight: Radius.circular(Dimensions.space20),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MyColor.primaryColor.withOpacity(0.8),
            MyColor.primaryColor.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event,
              size: 40,
              color: MyColor.colorWhite,
            ),
            const SizedBox(height: Dimensions.space8),
            Text(
              'Event',
              style: boldDefault.copyWith(
                color: MyColor.colorWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _buildEventGradient(bool isUpcoming) {
    if (isUpcoming) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          MyColor.primaryColor.withOpacity(0.1),
          MyColor.primaryColor.withOpacity(0.05),
        ],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.grey.withOpacity(0.1),
          Colors.grey.withOpacity(0.05),
        ],
      );
    }
  }

  Widget _buildStatusBadge(bool isUpcoming) {
    final String eventStatus = event['status'] ?? 'active';
    final bool isActive = eventStatus == 'active';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Active/Inactive Status Badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.space10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.green.withOpacity(0.9)
                : Colors.red.withOpacity(0.9),
            borderRadius: BorderRadius.circular(Dimensions.space15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? Icons.visibility : Icons.visibility_off,
                size: 12,
                color: MyColor.colorWhite,
              ),
              const SizedBox(width: 4),
              Text(
                isActive ? 'ACTIVE' : 'INACTIVE',
                style: boldSmall.copyWith(
                  color: MyColor.colorWhite,
                  fontSize: 9,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // Time Status Badge (Upcoming/Past)
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.space10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: isUpcoming
                ? Colors.blue.withOpacity(0.9)
                : Colors.orange.withOpacity(0.9),
            borderRadius: BorderRadius.circular(Dimensions.space15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            isUpcoming ? 'UPCOMING' : 'PAST',
            style: boldSmall.copyWith(
              color: MyColor.colorWhite,
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.space10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: MyColor.colorWhite.withOpacity(0.9),
        borderRadius: BorderRadius.circular(Dimensions.space15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        event['categoryId'].toString().toUpperCase(),
        style: boldSmall.copyWith(
          color: MyColor.primaryColor,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEventTitle(bool isUpcoming) {
    return Text(
      event['eventName'] ?? 'Untitled Event',
      style: boldExtraLarge.copyWith(
        color: isUpcoming
            ? MyColor.getTextColor()
            : MyColor.getTextColor().withOpacity(0.8),
        fontSize: 20,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDateTime(bool isUpcoming) {
    if (event['dateTime'] == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(Dimensions.space12),
      decoration: BoxDecoration(
        color: isUpcoming
            ? MyColor.primaryColor.withOpacity(0.08)
            : Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(Dimensions.space12),
        border: Border.all(
          color: isUpcoming
              ? MyColor.primaryColor.withOpacity(0.2)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 18,
                color: isUpcoming ? MyColor.primaryColor : Colors.grey.shade600,
              ),
              const SizedBox(width: Dimensions.space8),
              Expanded(
                child: Text(
                  EventFormatter.formatEventDateTime(event['dateTime']),
                  style: boldDefault.copyWith(
                    color: isUpcoming
                        ? MyColor.primaryColor
                        : Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (EventFormatter.getRelativeTime(event['dateTime']).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 26, top: 4),
              child: Text(
                EventFormatter.getRelativeTime(event['dateTime']),
                style: regularSmall.copyWith(
                  color: isUpcoming
                      ? Colors.green.shade600
                      : Colors.orange.shade600,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocation() {
    return Container(
      padding: const EdgeInsets.all(Dimensions.space10),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(Dimensions.space10),
        border: Border.all(
          color: Colors.grey.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: Dimensions.space8),
          Expanded(
            child: Text(
              EventFormatter.formatEventLocationShort(
                event['location'],
                event['inPersonOrVirtual'],
              ),
              style: regularDefault.copyWith(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    if (event['details'] == null || event['details'].toString().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(Dimensions.space12),
      decoration: BoxDecoration(
        color: MyColor.primaryColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(Dimensions.space10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: boldSmall.copyWith(
              color: MyColor.primaryColor,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            event['details'],
            style: regularDefault.copyWith(
              color: MyColor.getTextColor(),
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildConstraintsBadges() {
    final List<Widget> badges = [];

    // Age Range Badge
    if (EventFormatter.formatAgeRange(event['minAge'], event['maxAge']) !=
        null) {
      badges.add(_buildAgeBadge());
    }

    // Max Persons Badge
    if (EventFormatter.formatMaxPersons(event['maxAttendees']) != null) {
      badges.add(_buildMaxPersonsBadge());
    }

    // Price Badge (if available)
    if (event['price'] != null && event['price'] != 0) {
      badges.add(_buildPriceBadge());
    }

    // Approval Badge
    badges.add(_buildApprovalBadge());

    if (badges.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: Dimensions.space8,
      runSpacing: 6,
      children: badges,
    );
  }

  Widget _buildAgeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.space12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.space20),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            MyStrings.age_between,
            style: boldSmall.copyWith(
              color: Colors.blue.shade600,
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            EventFormatter.formatAgeRange(event['minAge'], event['maxAge'])!,
            style: boldSmall.copyWith(
              color: Colors.blue.shade600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaxPersonsBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.space12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.space20),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.group,
            size: 14,
            color: Colors.orange.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            EventFormatter.formatMaxPersons(event['maxAttendees'])!,
            style: boldSmall.copyWith(
              color: Colors.orange.shade600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.space12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.space20),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.attach_money,
            size: 14,
            color: Colors.green.shade600,
          ),
          const SizedBox(width: 2),
          Text(
            '\$${event['price']}',
            style: boldSmall.copyWith(
              color: Colors.green.shade600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalBadge() {
    final requiresApproval = event['requiresApproval'] ?? true;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.space10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: requiresApproval
            ? Colors.purple.withOpacity(0.1)
            : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.space20),
        border: Border.all(
          color: requiresApproval
              ? Colors.purple.withOpacity(0.3)
              : Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            requiresApproval ? Icons.how_to_reg : Icons.check_circle_outline,
            size: 14,
            color: requiresApproval
                ? Colors.purple.shade600
                : Colors.blue.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            requiresApproval ? 'Approval' : 'Auto-join',
            style: boldSmall.copyWith(
              color: requiresApproval
                  ? Colors.purple.shade600
                  : Colors.blue.shade600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterActions(bool isUpcoming) {
    return Column(
      children: [
        // Attendees count info
        _buildAttendeesInfo(),

        const SizedBox(height: Dimensions.space15),

        // Action buttons row
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // View Members Button
        _buildActionButton(
          icon: Icons.group,
          label: 'View Members',
          color: Colors.blue.shade600,
          onTap: () => _openEventMembersScreen(),
        ),

        // Edit Event Button
        _buildActionButton(
          icon: Icons.edit_outlined,
          label: 'Edit Event',
          color: Colors.orange.shade600,
          onTap: () => _editEvent(),
        ),

        // Delete Event Button
        _buildActionButton(
          icon: Icons.delete_outline,
          label: 'Delete Event',
          color: Colors.red.shade600,
          onTap: () => _deleteEvent(),
        ),
      ],
    );
  }

  Widget _buildAttendeesInfo() {
    final int currentAttendees = event['currentAttendees'] ?? 0;
    final int maxAttendees = event['maxAttendees'] ?? 0;

    return Row(
      children: [
        Icon(
          Icons.person_outline,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          maxAttendees > 0
              ? '$currentAttendees/$maxAttendees'
              : '$currentAttendees joined',
          style: regularSmall.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.space10,
            horizontal: Dimensions.space8,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(Dimensions.space12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: boldSmall.copyWith(
                  color: color,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEventMembersScreen() {
    final eventId = event['id']?.toString();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (eventId == null || currentUserId == null) {
      Get.snackbar(
        'Error',
        'Unable to load event members',
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

  void _editEvent() {
    final eventId = event['id']?.toString();
    if (eventId != null) {
      Get.toNamed(RouteHelper.editEventForm, arguments: event);
    } else {
      Get.snackbar(
        'Error',
        'Unable to edit event. Event ID not found.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _deleteEvent() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Event'),
        content: Text(
          'Are you sure you want to delete "${event['eventName'] ?? 'this event'}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // Here you would typically call a method from the controller
              // For now, we'll show a snackbar
              Get.snackbar(
                'Feature Coming Soon',
                'Delete functionality will be available soon.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
