import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/route/route.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/style.dart';
import '../../../../data/controller/home/home_controller.dart';

class EventCardWidget extends StatelessWidget {
  final HomeController controller;
  final int index;

  const EventCardWidget({
    Key? key,
    required this.controller,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (index >= controller.nearbyEvents.length) return const SizedBox();

    final eventData =
        controller.nearbyEvents[index].data() as Map<String, dynamic>;
    final imageUrl = eventData['imageUrl'] is String
        ? eventData['imageUrl'] as String
        : null;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.width * 0.7,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: InkWell(
          onTap: () {
            Get.toNamed(
              RouteHelper.eventDetailsScreen,
              arguments: {
                ...eventData,
                'id': controller.nearbyEvents[index].id,
              },
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              if (imageUrl != null && imageUrl.isNotEmpty)
                Image.file(
                  File(imageUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildFallbackBackground();
                  },
                )
              else
                _buildFallbackBackground(),

              // Enhanced gradient overlay for better readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      MyColor.colorBlack.withOpacity(0.3),
                      MyColor.colorBlack.withOpacity(0.6),
                      MyColor.colorBlack.withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.3, 0.6, 0.85, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(Dimensions.extraRadius),
                ),
              ),

              // Top badges (Status, Category)
              Positioned(
                top: Dimensions.space15,
                left: Dimensions.space15,
                right: Dimensions.space15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 2,
                      child: _buildCategoryBadge(eventData),
                    ),
                    const SizedBox(width: Dimensions.space8),
                    Flexible(
                      flex: 1,
                      child: _buildStatusBadge(eventData),
                    ),
                  ],
                ),
              ),

              // Main event information at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(Dimensions.space20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        eventData['eventName'] ?? 'Untitled Event',
                        style: boldExtraLarge.copyWith(
                          color: MyColor.colorWhite,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Dimensions.space8),
                      _buildDateTimeInfo(eventData),
                      const SizedBox(height: Dimensions.space8),
                      _buildLocationInfo(eventData),
                      const SizedBox(height: Dimensions.space12),
                      _buildEventDetailsRow(eventData),
                    ],
                  ),
                ),
              ),

              // Age restriction badge (top right if applicable)
              if (_hasAgeRestriction(eventData))
                Positioned(
                  top: Dimensions.space60,
                  right: Dimensions.space15,
                  child: _buildAgeRestrictionBadge(eventData),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: MyColor.primaryGradient,
        borderRadius: BorderRadius.circular(Dimensions.extraRadius),
      ),
    );
  }

  Widget _buildCategoryBadge(Map<String, dynamic> eventData) {
    final category = eventData['categoryId'] ?? eventData['category'];
    if (category == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: MyColor.colorWhite.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        category.toString().toUpperCase(),
        style: boldSmall.copyWith(
          color: MyColor.primaryColor,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStatusBadge(Map<String, dynamic> eventData) {
    final isUpcoming = _isEventUpcoming(eventData);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isUpcoming
            ? Colors.green.withOpacity(0.9)
            : Colors.orange.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: MyColor.colorBlack.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        isUpcoming ? 'UPCOMING' : 'ACTIVE',
        style: boldSmall.copyWith(
          color: MyColor.colorWhite,
          fontSize: Dimensions.fontExtraSmall,
          letterSpacing: 0.5,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDateTimeInfo(Map<String, dynamic> eventData) {
    final dateTime = eventData['dateTime'];
    final endDateTime = eventData['endDateTime'];

    if (dateTime == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.space12, vertical: Dimensions.space8),
      decoration: BoxDecoration(
        color: MyColor.colorBlack.withOpacity(0.3),
        borderRadius: BorderRadius.circular(Dimensions.space12),
        border: Border.all(
          color: MyColor.colorWhite.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: Dimensions.fontSmall + 3,
            color: MyColor.colorWhite,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(dateTime),
                  style: boldSmall.copyWith(
                    color: MyColor.colorWhite,
                    fontSize: Dimensions.fontSmall,
                  ),
                ),
                if (endDateTime != null) ...[
                  const SizedBox(height: Dimensions.space2),
                  Text(
                    '${_formatTime(dateTime)} - ${_formatTime(endDateTime)}',
                    style: regularSmall.copyWith(
                      color: MyColor.colorWhite.withOpacity(0.8),
                      fontSize: Dimensions.fontExtraSmall,
                    ),
                  ),
                ] else
                  Text(
                    _formatTime(dateTime),
                    style: regularSmall.copyWith(
                      color: MyColor.colorWhite.withOpacity(0.8),
                      fontSize: Dimensions.fontExtraSmall,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(Map<String, dynamic> eventData) {
    final location = _getLocationString(eventData);

    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: Dimensions.fontSmall + 3,
          color: MyColor.colorWhite.withOpacity(0.9),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            location,
            style: regularDefault.copyWith(
              color: MyColor.colorWhite.withOpacity(0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEventDetailsRow(Map<String, dynamic> eventData) {
    return Row(
      children: [
        _buildAttendeesInfo(eventData),
        const SizedBox(width: 15),
        if (eventData['price'] != null && eventData['price'] != 0)
          _buildPriceInfo(eventData),
      ],
    );
  }

  Widget _buildAttendeesInfo(Map<String, dynamic> eventData) {
    final currentAttendees = eventData['currentAttendees'] ?? 0;
    final maxAttendees = eventData['maxAttendees'] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: MyColor.colorWhite.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people,
            size: 16,
            color: MyColor.colorWhite,
          ),
          const SizedBox(width: 4),
          Text(
            maxAttendees > 0
                ? '$currentAttendees/$maxAttendees'
                : '$currentAttendees',
            style: boldSmall.copyWith(
              color: MyColor.colorWhite,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(Map<String, dynamic> eventData) {
    final price = eventData['price'] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.attach_money,
            size: 16,
            color: MyColor.colorWhite,
          ),
          Text(
            price.toString(),
            style: boldSmall.copyWith(
              color: MyColor.colorWhite,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeRestrictionBadge(Map<String, dynamic> eventData) {
    final minAge = eventData['minAge'];
    final maxAge = eventData['maxAge'];

    String ageText = '';
    if (minAge != null && maxAge != null) {
      ageText = '$minAge-$maxAge';
    } else if (minAge != null) {
      ageText = '$minAge+';
    } else if (maxAge != null) {
      ageText = 'Under $maxAge';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
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
            Icons.cake,
            size: 14,
            color: MyColor.colorWhite,
          ),
          const SizedBox(width: 4),
          Text(
            ageText,
            style: boldSmall.copyWith(
              color: MyColor.colorWhite,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  bool _isEventUpcoming(Map<String, dynamic> eventData) {
    final dateTime = eventData['dateTime'];
    if (dateTime == null) return true;

    try {
      DateTime eventDate;
      if (dateTime is DateTime) {
        eventDate = dateTime;
      } else {
        eventDate = DateTime.parse(dateTime.toString());
      }
      return eventDate.isAfter(DateTime.now());
    } catch (e) {
      return true;
    }
  }

  bool _hasAgeRestriction(Map<String, dynamic> eventData) {
    return eventData['minAge'] != null || eventData['maxAge'] != null;
  }

  String _formatDate(dynamic dateTime) {
    try {
      DateTime date;
      if (dateTime is DateTime) {
        date = dateTime;
      } else {
        date = DateTime.parse(dateTime.toString());
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final eventDate = DateTime(date.year, date.month, date.day);

      if (eventDate == today) {
        return 'Today';
      } else if (eventDate == today.add(const Duration(days: 1))) {
        return 'Tomorrow';
      } else {
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        return '${months[date.month - 1]} ${date.day}';
      }
    } catch (e) {
      return 'Date TBD';
    }
  }

  String _formatTime(dynamic time) {
    try {
      DateTime dateTime;
      if (time is DateTime) {
        dateTime = time;
      } else {
        dateTime = DateTime.parse(time.toString());
      }

      final hour = dateTime.hour;
      final minute = dateTime.minute;
      final amPm = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

      return '${displayHour}:${minute.toString().padLeft(2, '0')} $amPm';
    } catch (e) {
      return 'Time TBD';
    }
  }

  String _getLocationString(Map<String, dynamic> eventData) {
    final location = eventData['location'];
    if (location == null) return 'Location TBD';

    if (location is Map<String, dynamic>) {
      final address = location['address'] as Map<String, dynamic>?;
      if (address != null) {
        final locality = address['locality'] as String?;
        final administrativeArea = address['administrativeArea'] as String?;

        if (locality != null && administrativeArea != null) {
          return '$locality, $administrativeArea';
        }
        return locality ?? administrativeArea ?? 'Location TBD';
      }

      // If no structured address, check for any readable location info
      final locationStr = location.toString();
      return locationStr.length > 50 ? 'Location available' : locationStr;
    }

    return location.toString();
  }
}
