import 'package:flutter/material.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';

class EventPreviewCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final double? height;
  final double? width;

  const EventPreviewCard({
    Key? key,
    required this.event,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? MediaQuery.of(context).size.height * 0.6,
      width: width ?? MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MyColor.primaryColor,
            MyColor.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(Dimensions.extraRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Category badge (top left)
          Positioned(
            top: Dimensions.space15,
            left: Dimensions.space15,
            child: _buildCategoryBadge(),
          ),

          // Status badge (top right)
          Positioned(
            top: Dimensions.space15,
            right: Dimensions.space15,
            child: _buildStatusBadge(),
          ),

          // Attendees badge (bottom right)
          if (event['maxAttendees'] != null)
            Positioned(
              bottom: Dimensions.space100,
              right: Dimensions.space15,
              child: _buildAttendeesBadge(),
            ),

          // Event info at bottom with more compact padding
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.space20,
                vertical: Dimensions.space25,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(Dimensions.extraRadius),
                  bottomRight: Radius.circular(Dimensions.extraRadius),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event['eventName'] ?? 'Untitled Event',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Dimensions.space10),
                  _buildDateTimeInfo(),
                  const SizedBox(height: Dimensions.space5),
                  _buildLocationInfo(),
                  const SizedBox(height: Dimensions.space15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge() {
    final category = _getCategoryText();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.space12,
        vertical: Dimensions.space5,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(Dimensions.space12),
      ),
      child: Text(
        category,
        style: const TextStyle(
          color: MyColor.primaryColor,
          fontSize: Dimensions.fontExtraSmall,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final status = _getStatusText();
    final isUpcoming = status.toLowerCase() == 'upcoming';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.space10,
        vertical: Dimensions.space5,
      ),
      decoration: BoxDecoration(
        color: isUpcoming ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(Dimensions.space10),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: Dimensions.fontExtraSmall,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAttendeesBadge() {
    final maxAttendees = event['maxAttendees'] ?? 0;
    final currentAttendees = event['currentAttendees'] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.space10,
        vertical: Dimensions.space5,
      ),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(Dimensions.space10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.people,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: Dimensions.space3),
          Text(
            '$currentAttendees/$maxAttendees',
            style: const TextStyle(
              color: Colors.white,
              fontSize: Dimensions.fontExtraSmall,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.space12,
        vertical: Dimensions.space5,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(Dimensions.space12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: Dimensions.space5),
          Text(
            _getFormattedDateTime(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: Dimensions.fontSmall,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Row(
      children: [
        const Icon(
          Icons.location_on,
          color: Colors.white70,
          size: 16,
        ),
        const SizedBox(width: Dimensions.space5),
        Expanded(
          child: Text(
            _getLocationText(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: Dimensions.fontSmall,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
        return 'Active';
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

  String _getFormattedDateTime() {
    // Simple date/time formatting - you can enhance this
    final dateTime = event['dateTime'];
    if (dateTime != null) {
      try {
        if (dateTime is DateTime) {
          return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
        } else {
          final parsed = DateTime.parse(dateTime.toString());
          return '${parsed.day}/${parsed.month} ${parsed.hour}:${parsed.minute.toString().padLeft(2, '0')}';
        }
      } catch (e) {
        return 'Date TBD';
      }
    }
    return 'Date TBD';
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
    return 'Location TBD';
  }
}
