import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/view/components/image/custom_svg_picture.dart';
import 'action_buttons_widget.dart';
import '../../../components/card/event_preview_card.dart';

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
      child: Stack(
        children: [
          // Title
          Positioned(
            top: Dimensions.space20,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: Text(
                  MyStrings.eventPreview,
                  style: boldOverLarge.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // Close button
          Positioned(
            top: Dimensions.space10,
            right: Dimensions.space10,
            child: SafeArea(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ),
            ),
          ),

          // Event card centered with minimal padding (adjusted for title)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(
                left: Dimensions.space15,
                right: Dimensions.space15,
                top: Dimensions.space60, // More top padding for title
                bottom: Dimensions.space30,
              ),
              child: EventPreviewCard(
                event: event,
                height: MediaQuery.of(context).size.height *
                    0.6, // Slightly smaller to account for title
                width: MediaQuery.of(context).size.width * 0.9,
              ),
            ),
          ),

          // Bottom action buttons (higher overlap)
          Positioned(
            bottom: Dimensions.space60,
            left: 0,
            right: 0,
            child: EventActionButtonsWidget(
              onDecline: () {
                Navigator.of(context).pop();
                // Add dislike/decline logic here if needed
              },
              onJoin: () {
                Navigator.of(context).pop();
                // Add like/join logic here if needed
              },
            ),
          ),
        ],
      ),
    );
  }
}
