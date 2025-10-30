import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/core/utils/event_formatter.dart';

class AttendingEventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback? onTap;
  final VoidCallback? onLeave;
  final VoidCallback? onToggleReminder;
  final VoidCallback? onChatWithHost;
  final VoidCallback? onViewMap;
  final bool isPending;

  const AttendingEventCard({
    Key? key,
    required this.event,
    this.onTap,
    this.onLeave,
    this.onToggleReminder,
    this.onChatWithHost,
    this.onViewMap,
    this.isPending = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isUpcoming = EventFormatter.isUpcoming(event['dateTime']);
    final bool isActive = _isEventActive();

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.space15),
        decoration: BoxDecoration(
          color: MyColor.colorWhite,
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
            color: isPending
                ? Colors.orange.withOpacity(0.3)
                : isActive
                    ? Colors.green.withOpacity(0.3)
                    : MyColor.primaryColor.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image Header
            _buildImageHeader(context, isUpcoming, isActive),

            // Event Content
            Padding(
              padding: const EdgeInsets.all(Dimensions.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventTitle(),
                  const SizedBox(height: Dimensions.space12),
                  _buildDateTime(),
                  const SizedBox(height: Dimensions.space10),
                  _buildHostInfo(),
                  const SizedBox(height: Dimensions.space10),
                  _buildLocationInfo(),
                  const SizedBox(height: Dimensions.space15),
                  _buildAttendeesInfo(),
                  const SizedBox(height: Dimensions.space15),
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader(
      BuildContext context, bool isUpcoming, bool isActive) {
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
            gradient: _buildEventGradient(isUpcoming, isActive),
          ),
          child: _buildEventImage(),
        ),

        // Status Badge
        Positioned(
          top: Dimensions.space15,
          right: Dimensions.space15,
          child: _buildStatusBadge(isUpcoming, isActive),
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
      child:
          event['imageUrl'] != null && event['imageUrl'].toString().isNotEmpty
              ? Image.network(
                  event['imageUrl'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultImageContent();
                  },
                )
              : _buildDefaultImageContent(),
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

  LinearGradient _buildEventGradient(bool isUpcoming, bool isActive) {
    if (isPending) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.orange.withOpacity(0.1),
          Colors.orange.withOpacity(0.05),
        ],
      );
    } else if (isActive) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.green.withOpacity(0.1),
          Colors.green.withOpacity(0.05),
        ],
      );
    } else if (isUpcoming) {
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

  Widget _buildStatusBadge(bool isUpcoming, bool isActive) {
    Color badgeColor;
    String statusText;
    IconData statusIcon;

    if (isPending) {
      badgeColor = Colors.orange;
      statusText = 'PENDING';
      statusIcon = Icons.hourglass_empty;
    } else if (isActive) {
      badgeColor = Colors.green;
      statusText = 'ACTIVE';
      statusIcon = Icons.play_circle_filled;
    } else if (isUpcoming) {
      badgeColor = Colors.blue;
      statusText = 'UPCOMING';
      statusIcon = Icons.schedule;
    } else {
      badgeColor = Colors.grey;
      statusText = 'PAST';
      statusIcon = Icons.history;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.space10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.9),
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
            statusIcon,
            size: 12,
            color: MyColor.colorWhite,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: boldSmall.copyWith(
              color: MyColor.colorWhite,
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
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

  Widget _buildEventTitle() {
    return Text(
      event['eventName'] ?? 'Untitled Event',
      style: boldExtraLarge.copyWith(
        color: MyColor.getTextColor(),
        fontSize: 20,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDateTime() {
    if (event['dateTime'] == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(Dimensions.space12),
      decoration: BoxDecoration(
        color: MyColor.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(Dimensions.space12),
        border: Border.all(
          color: MyColor.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            size: 18,
            color: MyColor.primaryColor,
          ),
          const SizedBox(width: Dimensions.space8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  EventFormatter.formatEventDateTime(event['dateTime']),
                  style: boldDefault.copyWith(
                    color: MyColor.primaryColor,
                    fontSize: 14,
                  ),
                ),
                if (EventFormatter.getRelativeTime(event['dateTime'])
                    .isNotEmpty)
                  Text(
                    EventFormatter.getRelativeTime(event['dateTime']),
                    style: regularSmall.copyWith(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostInfo() {
    return Container(
      padding: const EdgeInsets.all(Dimensions.space12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(Dimensions.space12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Host Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue.withOpacity(0.2),
            backgroundImage: event['hostAvatar'] != null
                ? NetworkImage(event['hostAvatar'])
                : null,
            child: event['hostAvatar'] == null
                ? Icon(
                    Icons.person,
                    color: Colors.blue.shade600,
                  )
                : null,
          ),
          const SizedBox(width: Dimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MyStrings.hostedBy,
                  style: regularSmall.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event['hostName'] ?? 'Unknown Host',
                        style: boldDefault.copyWith(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (event['hostVerified'] == true)
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: Colors.blue.shade600,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
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
                event['locationData'],
                event['locationName'] ??
                    event['inPersonOrVirtual'] ??
                    'Location TBD',
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

  Widget _buildAttendeesInfo() {
    final int currentAttendees = event['currentAttendees'] ?? 0;
    final int maxAttendees = event['maxAttendees'] ?? 0;
    final int spotsLeft =
        maxAttendees > 0 ? maxAttendees - currentAttendees : 0;

    return Container(
      padding: const EdgeInsets.all(Dimensions.space12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(Dimensions.space12),
        border: Border.all(
          color: Colors.green.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.group,
            size: 18,
            color: Colors.green.shade600,
          ),
          const SizedBox(width: Dimensions.space8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  maxAttendees > 0
                      ? '$currentAttendees/$maxAttendees joined'
                      : '$currentAttendees joined',
                  style: boldDefault.copyWith(
                    color: Colors.green.shade700,
                    fontSize: 14,
                  ),
                ),
                if (maxAttendees > 0 && spotsLeft > 0)
                  Text(
                    '$spotsLeft ${MyStrings.spotsAvailable}',
                    style: regularSmall.copyWith(
                      color: Colors.green.shade600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Leave/Unsave Button
        _buildActionButton(
          icon: Icons.heart_broken,
          label: MyStrings.leaveEvent,
          color: Colors.red.shade600,
          onTap: onLeave,
        ),

        // Reminder Toggle
        _buildActionButton(
          icon: event['hasReminder'] == true
              ? Icons.notifications_active
              : Icons.notifications_none,
          label: event['hasReminder'] == true
              ? MyStrings.reminderOn
              : MyStrings.reminderOff,
          color: Colors.orange.shade600,
          onTap: onToggleReminder,
        ),

        // Chat with Host
        _buildActionButton(
          icon: Icons.chat_bubble_outline,
          label: MyStrings.chatWithHost,
          color: Colors.blue.shade600,
          onTap: onChatWithHost,
        ),

        // View on Map
        _buildActionButton(
          icon: Icons.map_outlined,
          label: MyStrings.viewOnMap,
          color: Colors.green.shade600,
          onTap: onViewMap,
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

  bool _isEventActive() {
    final eventDateTime = _parseEventDateTime(event['dateTime']);
    if (eventDateTime == null) return false;

    final now = DateTime.now();
    final eventEndTime =
        eventDateTime.add(const Duration(hours: 4)); // Assume 4-hour events

    return eventDateTime.isBefore(now) && eventEndTime.isAfter(now);
  }

  DateTime? _parseEventDateTime(dynamic dateTime) {
    if (dateTime == null) return null;

    if (dateTime is String) {
      try {
        return DateTime.parse(dateTime);
      } catch (e) {
        return null;
      }
    }

    return null;
  }
}
