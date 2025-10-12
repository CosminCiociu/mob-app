import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/data/controller/events/my_events_controller.dart';
import 'event_card.dart';

class EventsList extends StatelessWidget {
  final MyEventsController controller;
  final Function(Map<String, dynamic>) onEventLongPress;
  final Function(Map<String, dynamic>)? onEventTap;

  const EventsList({
    Key? key,
    required this.controller,
    required this.onEventLongPress,
    this.onEventTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: Dimensions.screenPadding,
      child: Column(
        children: [
          ListView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: controller.userEvents.length,
            itemBuilder: (context, index) {
              final event = controller.userEvents[index];
              return EventCard(
                event: event,
                onLongPress: () => onEventLongPress(event),
                onTap: onEventTap != null ? () => onEventTap!(event) : null,
              );
            },
          ),
          const SizedBox(height: Dimensions.space100),
        ],
      ),
    );
  }
}
