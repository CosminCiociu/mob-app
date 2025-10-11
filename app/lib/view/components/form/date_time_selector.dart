import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/view/components/bottom-sheet/date_time_selection_bottom_sheet.dart';

class DateTimeSelector extends StatefulWidget {
  final DateTime? initialStartDateTime;
  final DateTime? initialEndDateTime;
  final Function(DateTime? startDateTime, DateTime? endDateTime)
      onSelectionChanged;
  final String? label;

  const DateTimeSelector({
    Key? key,
    this.initialStartDateTime,
    this.initialEndDateTime,
    required this.onSelectionChanged,
    this.label,
  }) : super(key: key);

  @override
  State<DateTimeSelector> createState() => _DateTimeSelectorState();
}

class _DateTimeSelectorState extends State<DateTimeSelector> {
  DateTime? startDateTime;
  DateTime? endDateTime;

  @override
  void initState() {
    super.initState();
    startDateTime = widget.initialStartDateTime;
    endDateTime = widget.initialEndDateTime;
  }

  @override
  void didUpdateWidget(DateTimeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStartDateTime != widget.initialStartDateTime ||
        oldWidget.initialEndDateTime != widget.initialEndDateTime) {
      setState(() {
        startDateTime = widget.initialStartDateTime;
        endDateTime = widget.initialEndDateTime;
      });
    }
  }

  String _formatDateTimeShort(DateTime? dateTime) {
    if (dateTime == null) return '';

    final date = '${dateTime.day}/${dateTime.month}';
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  void _showDateTimeSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (BuildContext context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => DateTimeSelectionBottomSheet(
          initialStartDateTime: startDateTime,
          initialEndDateTime: endDateTime,
          onSelectionChanged: (newStartDateTime, newEndDateTime) {
            setState(() {
              startDateTime = newStartDateTime;
              endDateTime = newEndDateTime;
            });
            widget.onSelectionChanged(newStartDateTime, newEndDateTime);
          },
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasStartTime = startDateTime != null;
    final hasEndTime = endDateTime != null;
    final hasAnyTime = hasStartTime || hasEndTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label ?? MyStrings.eventDateTime,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: MyColor.getTextColor(),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showDateTimeSelector,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Dimensions.space15),
            decoration: BoxDecoration(
              border: Border.all(
                color: hasAnyTime
                    ? MyColor.getPrimaryColor().withValues(alpha: 0.3)
                    : MyColor.getBorderColor(),
              ),
              borderRadius: BorderRadius.circular(8),
              color: hasAnyTime
                  ? MyColor.getPrimaryColor().withValues(alpha: 0.05)
                  : MyColor.getCardBgColor(),
            ),
            child: Row(
              children: [
                // Time indicator
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: hasAnyTime
                        ? MyColor.getPrimaryColor()
                        : MyColor.getGreyColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: Dimensions.space12),
                // Time text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasStartTime && hasEndTime) ...[
                        // Show both start and end times
                        Text(
                          '${_formatDateTimeShort(startDateTime)} - ${_formatDateTimeShort(endDateTime)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: MyColor.getTextColor(),
                          ),
                        ),
                      ] else if (hasStartTime) ...[
                        // Show only start time
                        Text(
                          '${_formatDateTimeShort(startDateTime)} - End time',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: MyColor.getTextColor(),
                          ),
                        ),
                      ] else ...[
                        // No time selected
                        Text(
                          'Select date and time',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: MyColor.getSecondaryTextColor(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Dropdown arrow
                Icon(
                  Icons.keyboard_arrow_down,
                  color: MyColor.getSecondaryTextColor(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
