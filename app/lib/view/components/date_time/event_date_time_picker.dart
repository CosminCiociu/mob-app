import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';

class EventDateTimePicker extends StatefulWidget {
  final Function(DateTime? startDateTime, DateTime? endDateTime)
      onDateTimeRangeChanged;
  final DateTime? initialStartDateTime;
  final DateTime? initialEndDateTime;
  final String? title;
  final bool showTitle;

  const EventDateTimePicker({
    Key? key,
    required this.onDateTimeRangeChanged,
    this.initialStartDateTime,
    this.initialEndDateTime,
    this.title,
    this.showTitle = true,
  }) : super(key: key);

  @override
  State<EventDateTimePicker> createState() => _EventDateTimePickerState();
}

class _EventDateTimePickerState extends State<EventDateTimePicker> {
  DateTime? startDateTime;
  DateTime? endDateTime;

  @override
  void initState() {
    super.initState();
    startDateTime = widget.initialStartDateTime;
    endDateTime = widget.initialEndDateTime;
  }

  void _showStartDateTimePicker() {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      currentTime: startDateTime ?? DateTime.now(),
      minTime: DateTime.now().subtract(const Duration(minutes: 1)),
      maxTime: DateTime(2100, 12, 31),
      onConfirm: (dateTime) {
        setState(() {
          startDateTime = dateTime;
          // If end time is before start time, reset end time
          if (endDateTime != null && endDateTime!.isBefore(dateTime)) {
            endDateTime = null;
          }
        });
        widget.onDateTimeRangeChanged(startDateTime, endDateTime);
      },
      locale: LocaleType.en,
    );
  }

  void _showEndDateTimePicker() {
    if (startDateTime == null) {
      // Show snackbar or alert that start time must be selected first
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(MyStrings.pleaseSelectStartTimeFirst),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      currentTime: endDateTime ?? startDateTime!.add(const Duration(hours: 1)),
      minTime: startDateTime!,
      maxTime: DateTime(2100, 12, 31),
      onConfirm: (dateTime) {
        setState(() {
          endDateTime = dateTime;
        });
        widget.onDateTimeRangeChanged(startDateTime, endDateTime);
      },
      locale: LocaleType.en,
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return MyStrings.notSelected;

    final date = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date at $time';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null && widget.showTitle)
          Padding(
            padding: EdgeInsets.only(bottom: Dimensions.space12),
            child: Text(
              widget.title!,
              style: TextStyle(
                fontSize: Dimensions.fontDefault,
                fontWeight: FontWeight.w600,
                color: MyColor.getTextColor(),
              ),
            ),
          ),

        // Start Date Time Section
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(Dimensions.space15),
          decoration: BoxDecoration(
            color: MyColor.getCardColor(),
            borderRadius: BorderRadius.circular(Dimensions.space12),
            border: Border.all(
              color: startDateTime != null
                  ? MyColor.getPrimaryColor().withOpacity(0.3)
                  : MyColor.getBorderColor(),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.event_available,
                    color: MyColor.getPrimaryColor(),
                    size: Dimensions.iconSize,
                  ),
                  SizedBox(width: Dimensions.space8),
                  Text(
                    MyStrings.startDateTime,
                    style: TextStyle(
                      fontSize: Dimensions.fontSmall,
                      fontWeight: FontWeight.w600,
                      color: MyColor.getPrimaryColor(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimensions.space8),
              Text(
                _formatDateTime(startDateTime),
                style: TextStyle(
                  fontSize: Dimensions.fontDefault,
                  color: startDateTime != null
                      ? MyColor.getTextColor()
                      : MyColor.getTextColor().withOpacity(0.6),
                ),
              ),
              SizedBox(height: Dimensions.space12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showStartDateTimePicker,
                  icon: Icon(Icons.calendar_today,
                      size: Dimensions.inputIconSize),
                  label: Text(startDateTime != null
                      ? MyStrings.changeStartTime
                      : MyStrings.selectStartTime),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColor.getPrimaryColor(),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: Dimensions.space12),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.cardRadius),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: Dimensions.space15),

        // End Date Time Section
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(Dimensions.space15),
          decoration: BoxDecoration(
            color: MyColor.getCardColor(),
            borderRadius: BorderRadius.circular(Dimensions.space12),
            border: Border.all(
              color: endDateTime != null
                  ? MyColor.getPrimaryColor().withOpacity(0.3)
                  : MyColor.getBorderColor(),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.event_busy,
                    color: MyColor.getRedColor(),
                    size: Dimensions.iconSize,
                  ),
                  SizedBox(width: Dimensions.space8),
                  Text(
                    MyStrings.endDateTime,
                    style: TextStyle(
                      fontSize: Dimensions.fontSmall,
                      fontWeight: FontWeight.w600,
                      color: MyColor.getRedColor(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimensions.space8),
              Text(
                _formatDateTime(endDateTime),
                style: TextStyle(
                  fontSize: Dimensions.fontDefault,
                  color: endDateTime != null
                      ? MyColor.getTextColor()
                      : MyColor.getTextColor().withOpacity(0.6),
                ),
              ),
              SizedBox(height: Dimensions.space12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showEndDateTimePicker,
                  icon: Icon(Icons.calendar_today,
                      size: Dimensions.inputIconSize),
                  label: Text(endDateTime != null
                      ? MyStrings.changeEndTime
                      : MyStrings.selectEndTime),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: startDateTime != null
                        ? MyColor.getRedColor()
                        : MyColor.getGreyColorwithShade400(),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: Dimensions.space12),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.cardRadius),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Duration Display (optional)
        if (startDateTime != null && endDateTime != null) ...[
          SizedBox(height: Dimensions.space12),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(Dimensions.space12),
            decoration: BoxDecoration(
              color: MyColor.getPrimaryColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(Dimensions.cardRadius),
              border: Border.all(
                color: MyColor.getPrimaryColor().withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: MyColor.getPrimaryColor(),
                  size: Dimensions.inputIconSize,
                ),
                SizedBox(width: Dimensions.space8),
                Text(
                  '${MyStrings.duration}: ${_calculateDuration()}',
                  style: TextStyle(
                    fontSize: Dimensions.fontSmall,
                    fontWeight: FontWeight.w500,
                    color: MyColor.getPrimaryColor(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _calculateDuration() {
    if (startDateTime == null || endDateTime == null) return '';

    final duration = endDateTime!.difference(startDateTime!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
}
