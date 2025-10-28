import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_images.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../view/components/image/custom_svg_picture.dart';

class EventActionButtons extends StatelessWidget {
  final Map<String, dynamic> eventData;
  final VoidCallback? onDecline;
  final VoidCallback? onJoin;

  const EventActionButtons({
    Key? key,
    required this.eventData,
    this.onDecline,
    this.onJoin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.space20),
      decoration: BoxDecoration(
        color: MyColor.getScreenBgColor(),
        boxShadow: [
          BoxShadow(
            color: MyColor.colorBlack.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pass/Dismiss button (X) - Decline
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                HapticFeedback.lightImpact();
                if (onDecline != null) {
                  onDecline!();
                } else {
                  _defaultDeclineAction(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(Dimensions.space15),
                decoration: const BoxDecoration(
                  color: MyColor.lBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: const CustomSvgPicture(
                  image: MyImages.cancel,
                  color: MyColor.colorRed,
                  height: Dimensions.space12,
                ),
              ),
            ),
          ),

          // Join/Check button - Accept
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                HapticFeedback.lightImpact();
                if (onJoin != null) {
                  onJoin!();
                } else {
                  _defaultJoinAction(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(Dimensions.space15),
                decoration: BoxDecoration(
                  color: MyColor.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: MyColor.primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: CustomSvgPicture(
                  image: MyImages.like,
                  color: MyColor.primaryColor,
                  height: Dimensions.fontHeader + 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _defaultDeclineAction(BuildContext context) {
    Get.back();
    _showSnackBar(context, MyStrings.eventDeclined);
  }

  void _defaultJoinAction(BuildContext context) {
    _showJoinDialog(context);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: MyColor.primaryColor,
      ),
    );
  }

  void _showJoinDialog(BuildContext context) {
    final eventName = _getEventName();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(MyStrings.joinEventAction),
        content: Text('${MyStrings.wouldYouLikeToJoin} "$eventName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(MyStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSnackBar(context, MyStrings.successfullyJoinedEvent);
              // Here you would typically update the event data
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColor.primaryColor,
            ),
            child: Text(MyStrings.joinEventAction),
          ),
        ],
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
}
