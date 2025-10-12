import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../core/utils/style.dart';

class EventImageHeader extends StatelessWidget {
  final Map<String, dynamic> eventData;

  const EventImageHeader({
    Key? key,
    required this.eventData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = eventData['imageUrl'] as String?;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          if (imageUrl != null && imageUrl.isNotEmpty)
            Image.file(
              File(imageUrl),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackImage();
              },
            )
          else
            _buildFallbackImage(),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  MyColor.colorBlack.withOpacity(0.3),
                  MyColor.colorBlack.withOpacity(0.7),
                ],
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),

          // Event title and basic info overlay
          Positioned(
            bottom: Dimensions.space20,
            left: Dimensions.space20,
            right: Dimensions.space20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event name
                Text(
                  _getEventName(),
                  style: boldExtraLarge.copyWith(
                    color: MyColor.colorWhite,
                    fontSize: Dimensions.fontHeader + 4,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Dimensions.space8),

                // Quick info row
                Row(
                  children: [
                    // Date
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.space12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: MyColor.primaryColor,
                        borderRadius: BorderRadius.circular(Dimensions.space15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: Dimensions.fontDefault + 1,
                            color: MyColor.colorWhite,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(eventData['dateTime']),
                            style: boldSmall.copyWith(
                              color: MyColor.colorWhite,
                              fontSize: Dimensions.fontSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Dimensions.space10),

                    // Category
                    if (eventData['categoryId'] != null ||
                        eventData['category'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.space12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: MyColor.colorWhite.withOpacity(0.9),
                          borderRadius:
                              BorderRadius.circular(Dimensions.space15),
                        ),
                        child: Text(
                          (eventData['categoryId'] ?? eventData['category'])
                              .toString()
                              .toUpperCase(),
                          style: boldSmall.copyWith(
                            color: MyColor.primaryColor,
                            fontSize: Dimensions.fontSmall,
                          ),
                        ),
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

  Widget _buildFallbackImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MyColor.primaryColor.withOpacity(0.8),
            MyColor.primaryColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event,
              size: Dimensions.space80,
              color: MyColor.colorWhite,
            ),
            const SizedBox(height: Dimensions.space15),
            Text(
              MyStrings.eventImageAlt,
              style: boldLarge.copyWith(
                color: MyColor.colorWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEventName() {
    final eventName = eventData['eventName'];
    if (eventName != null && eventName.toString().trim().isNotEmpty) {
      return eventName.toString().trim();
    }

    // Fallback to category if no name
    final category = eventData['categoryId'] ?? eventData['category'];
    if (category != null) {
      return '${category.toString()} Event';
    }

    return MyStrings.untitledEventText;
  }

  String _formatDate(dynamic dateTime) {
    if (dateTime == null) return MyStrings.dateTBD;

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
        return MyStrings.eventToday;
      } else if (eventDate == today.add(const Duration(days: 1))) {
        return MyStrings.eventTomorrow;
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
      return MyStrings.dateTBD;
    }
  }
}
