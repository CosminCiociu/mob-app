import 'package:flutter/material.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../core/utils/style.dart';
import '../../../../core/utils/event_formatter.dart';

enum EventInfoSectionType {
  eventDetails,
  timeLocation,
  attendees,
  description,
  lookingFor,
}

class EventInfoSection extends StatelessWidget {
  final Map<String, dynamic> eventData;
  final EventInfoSectionType sectionType;

  const EventInfoSection({
    Key? key,
    required this.eventData,
    required this.sectionType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (sectionType) {
      case EventInfoSectionType.lookingFor:
        return _buildLookingForSection();
      case EventInfoSectionType.eventDetails:
        return _buildEventDetailsSection();
      case EventInfoSectionType.timeLocation:
        return _buildTimeLocationSection();
      case EventInfoSectionType.attendees:
        return _buildAttendeesSection();
      case EventInfoSectionType.description:
        return _buildDescriptionSection();
    }
  }

  Widget _buildLookingForSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.search,
              size: Dimensions.fontLarge + 3,
              color: MyColor.getTextColor().withOpacity(0.7),
            ),
            const SizedBox(width: Dimensions.space8),
            Text(
              MyStrings.lookingForText,
              style: regularDefault.copyWith(
                color: MyColor.getTextColor().withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.space8),
        Text(
          _getLookingForText(),
          style: boldDefault.copyWith(
            color: MyColor.getTextColor(),
            fontSize: Dimensions.fontLarge + 1,
          ),
        ),
      ],
    );
  }

  Widget _buildEventDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: MyColor.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(Dimensions.space12),
        border: Border.all(
          color: MyColor.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MyStrings.eventDetailsTitle,
            style: boldLarge.copyWith(
              color: MyColor.primaryColor,
              fontSize: Dimensions.fontLarge + 3,
            ),
          ),
          const SizedBox(height: Dimensions.space12),

          // Event type
          _buildDetailRow(
            Icons.category,
            MyStrings.categoryLabel,
            (eventData['categoryId'] ??
                    eventData['category'] ??
                    MyStrings.generalCategory)
                .toString(),
          ),

          // Event status
          _buildDetailRow(
            Icons.info_outline,
            MyStrings.status,
            _getEventStatus(),
          ),

          // Created by
          if (eventData['createdBy'] != null)
            _buildDetailRow(
              Icons.person_outline,
              MyStrings.organizedBy,
              _getOrganizerName(),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeLocationSection() {
    return Container(
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(Dimensions.space12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MyStrings.whenAndWhere,
            style: boldLarge.copyWith(
              color: Colors.blue.shade700,
              fontSize: Dimensions.fontLarge + 3,
            ),
          ),
          const SizedBox(height: Dimensions.space12),

          // Start time
          _buildDetailRow(
            Icons.access_time,
            MyStrings.startsAt,
            _formatFullDateTime(eventData['dateTime']),
          ),

          // End time
          if (eventData['endDateTime'] != null)
            _buildDetailRow(
              Icons.access_time_filled,
              MyStrings.endsAt,
              _formatFullDateTime(eventData['endDateTime']),
            ),

          // Location
          _buildDetailRow(
            Icons.location_on,
            MyStrings.location,
            _getLocationString(),
          ),

          // Event type (in-person/virtual)
          if (eventData['inPersonOrVirtual'] != null)
            _buildDetailRow(
              Icons.event_seat,
              MyStrings.eventType,
              eventData['inPersonOrVirtual'].toString(),
            ),
        ],
      ),
    );
  }

  Widget _buildAttendeesSection() {
    return Container(
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(Dimensions.space12),
        border: Border.all(
          color: Colors.green.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MyStrings.attendeesAndRequirements,
            style: boldLarge.copyWith(
              color: Colors.green.shade700,
              fontSize: Dimensions.fontLarge + 3,
            ),
          ),
          const SizedBox(height: Dimensions.space12),

          // Current attendees
          _buildDetailRow(
            Icons.people,
            MyStrings.attendeesCount,
            '${eventData['currentAttendees'] ?? 0}${eventData['maxAttendees'] != null ? '/${eventData['maxAttendees']}' : ''}',
          ),

          // Age restrictions
          if (eventData['minAge'] != null || eventData['maxAge'] != null)
            _buildDetailRow(
              Icons.person_outline,
              MyStrings.ageRangeText,
              _getAgeRangeString(),
            ),

          // Price
          if (eventData['price'] != null && eventData['price'] != 0)
            _buildDetailRow(
              Icons.attach_money,
              MyStrings.priceLabel,
              '\$${eventData['price']}',
            ),

          // Distance (if available)
          _buildDetailRow(
            Icons.straighten,
            MyStrings.distance,
            '${(eventData['distance'] ?? 0.5).toStringAsFixed(1)} ${MyStrings.kmAwayText}',
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    if (eventData['details'] == null ||
        eventData['details'].toString().isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          MyStrings.aboutThisEvent,
          style: boldLarge.copyWith(
            color: MyColor.getTextColor(),
            fontSize: Dimensions.fontLarge + 3,
          ),
        ),
        const SizedBox(height: Dimensions.space12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Dimensions.space15),
          decoration: BoxDecoration(
            color: MyColor.getScreenBgColor(),
            borderRadius: BorderRadius.circular(Dimensions.space12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            eventData['details'].toString(),
            style: regularDefault.copyWith(
              color: MyColor.getTextColor(),
              fontSize: Dimensions.fontLarge + 1,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: Dimensions.fontLarge + 5,
            color: MyColor.getTextColor().withOpacity(0.6),
          ),
          const SizedBox(width: Dimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: regularSmall.copyWith(
                    color: MyColor.getTextColor().withOpacity(0.6),
                    fontSize: Dimensions.fontSmall,
                  ),
                ),
                const SizedBox(height: Dimensions.space2),
                Text(
                  value,
                  style: boldDefault.copyWith(
                    color: MyColor.getTextColor(),
                    fontSize: Dimensions.fontDefault + 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getLookingForText() {
    final category = eventData['categoryId'] ?? eventData['category'];
    final attendees = eventData['currentAttendees'] ?? 0;

    if (category != null) {
      return '${MyStrings.peopleInterestedInText} ${category.toString().toLowerCase()} ${MyStrings.eventsText}';
    }

    if (attendees > 0) {
      return '$attendees ${MyStrings.peopleToJoinEvent}';
    }

    return MyStrings.funPeopleToJoinEvent;
  }

  String _getEventStatus() {
    final dateTime = eventData['dateTime'];
    if (dateTime == null) return MyStrings.eventScheduled;

    try {
      DateTime date;
      if (dateTime is DateTime) {
        date = dateTime;
      } else {
        date = DateTime.parse(dateTime.toString());
      }

      final now = DateTime.now();
      if (date.isAfter(now)) {
        return MyStrings.eventUpcoming;
      } else if (date.isBefore(now)) {
        final endTime = eventData['endDateTime'];
        if (endTime != null) {
          DateTime endDate;
          if (endTime is DateTime) {
            endDate = endTime;
          } else {
            endDate = DateTime.parse(endTime.toString());
          }
          if (endDate.isAfter(now)) {
            return MyStrings.eventLiveNow;
          }
        }
        return MyStrings.pastEvent;
      } else {
        return MyStrings.startingSoon;
      }
    } catch (e) {
      return MyStrings.eventScheduled;
    }
  }

  String _formatFullDateTime(dynamic dateTime) {
    if (dateTime == null) return 'TBD';

    try {
      DateTime date;
      if (dateTime is DateTime) {
        date = dateTime;
      } else {
        date = DateTime.parse(dateTime.toString());
      }

      final timeString =
          EventFormatter.formatEventTimeOnly(date.toIso8601String());
      final dateString =
          EventFormatter.formatEventDateOnly(date.toIso8601String());

      return '$dateString at $timeString';
    } catch (e) {
      return 'TBD';
    }
  }

  String _getLocationString() {
    final location = eventData['location'];
    if (location is Map<String, dynamic>) {
      final address = location['address'] as Map<String, dynamic>?;
      if (address != null) {
        final locality = address['locality'] as String?;
        final administrativeArea = address['administrativeArea'] as String?;
        if (locality != null && administrativeArea != null) {
          return '$locality, $administrativeArea';
        }
        return locality ?? administrativeArea ?? MyStrings.locationTBD;
      }
    }

    final locationName = eventData['locationName'];
    if (locationName != null && locationName.toString().isNotEmpty) {
      return locationName.toString();
    }

    return MyStrings.locationTBD;
  }

  String _getOrganizerName() {
    // Try to get organizer name from various possible fields
    if (eventData['organizerName']?.toString().isNotEmpty == true) {
      return eventData['organizerName'].toString();
    }

    if (eventData['creatorName']?.toString().isNotEmpty == true) {
      return eventData['creatorName'].toString();
    }

    // Check if userInfo exists and has a name
    final userInfo = eventData['userInfo'];
    if (userInfo is Map && userInfo['name']?.toString().isNotEmpty == true) {
      return userInfo['name'].toString();
    }
    if (userInfo is Map &&
        userInfo['displayName']?.toString().isNotEmpty == true) {
      return userInfo['displayName'].toString();
    }
    if (userInfo is Map &&
        userInfo['firstName']?.toString().isNotEmpty == true) {
      return userInfo['firstName'].toString();
    }

    // Fallback to user ID with nice formatting
    final userId = eventData['createdBy']?.toString() ??
        eventData['userId']?.toString() ??
        'Unknown';
    if (userId != 'Unknown' && userId.isNotEmpty) {
      if (userId.length > 10) {
        return 'User ${userId.substring(0, 8)}...'; // Show first 8 chars of ID
      }
      return 'User $userId';
    }

    return MyStrings.unknownOrganizerText;
  }

  String _getAgeRangeString() {
    final minAge = eventData['minAge'];
    final maxAge = eventData['maxAge'];

    if (minAge != null && maxAge != null) {
      return '$minAge - $maxAge ${MyStrings.yearsOld}';
    } else if (minAge != null) {
      return '$minAge+ ${MyStrings.yearsOld}';
    } else if (maxAge != null) {
      return '${MyStrings.underAge} $maxAge ${MyStrings.yearsOld}';
    }

    return MyStrings.allAgesWelcome;
  }
}
