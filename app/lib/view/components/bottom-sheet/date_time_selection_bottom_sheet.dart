import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/view/components/bottom-sheet/bottom_sheet_header_row.dart';
import 'package:ovo_meet/view/components/buttons/custom_gradiant_button.dart';

class DateTimeSelectionBottomSheet extends StatefulWidget {
  final DateTime? initialStartDateTime;
  final DateTime? initialEndDateTime;
  final Function(DateTime? startDateTime, DateTime? endDateTime)
      onSelectionChanged;
  final ScrollController? scrollController;

  const DateTimeSelectionBottomSheet({
    Key? key,
    this.initialStartDateTime,
    this.initialEndDateTime,
    required this.onSelectionChanged,
    this.scrollController,
  }) : super(key: key);

  @override
  State<DateTimeSelectionBottomSheet> createState() =>
      _DateTimeSelectionBottomSheetState();
}

class _DateTimeSelectionBottomSheetState
    extends State<DateTimeSelectionBottomSheet> {
  DateTime? startDateTime;
  DateTime? endDateTime;
  bool isSelectingStart = true;

  // Controllers for scroll pickers
  late FixedExtentScrollController dayController;
  late FixedExtentScrollController monthController;
  late FixedExtentScrollController yearController;
  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;

  // Current selected values
  int selectedDay = DateTime.now().day;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  int selectedHour = DateTime.now().hour;
  int selectedMinute = DateTime.now().minute;

  @override
  void initState() {
    super.initState();
    startDateTime = widget.initialStartDateTime;
    endDateTime = widget.initialEndDateTime;

    // Initialize with current datetime or existing selection
    final currentDateTime = isSelectingStart
        ? (startDateTime ?? DateTime.now())
        : (endDateTime ?? startDateTime ?? DateTime.now());

    selectedDay = currentDateTime.day;
    selectedMonth = currentDateTime.month;
    selectedYear = currentDateTime.year;
    selectedHour = currentDateTime.hour;
    selectedMinute = currentDateTime.minute;

    // Initialize controllers
    dayController = FixedExtentScrollController(initialItem: selectedDay - 1);
    monthController =
        FixedExtentScrollController(initialItem: selectedMonth - 1);

    // Fix year controller - make sure it's properly aligned
    final yearIndex = selectedYear >= DateTime.now().year
        ? selectedYear - DateTime.now().year
        : 0;
    yearController = FixedExtentScrollController(initialItem: yearIndex);

    hourController = FixedExtentScrollController(initialItem: selectedHour);
    minuteController = FixedExtentScrollController(initialItem: selectedMinute);
  }

  @override
  void dispose() {
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    hourController.dispose();
    minuteController.dispose();
    super.dispose();
  }

  void _updateControllers() {
    final currentDateTime = isSelectingStart
        ? (startDateTime ?? DateTime.now())
        : (endDateTime ?? startDateTime ?? DateTime.now());

    setState(() {
      selectedDay = currentDateTime.day;
      selectedMonth = currentDateTime.month;
      selectedYear = currentDateTime.year;
      selectedHour = currentDateTime.hour;
      selectedMinute = currentDateTime.minute;
    });

    // Update controllers
    dayController.animateToItem(
      selectedDay - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    monthController.animateToItem(
      selectedMonth - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    final yearIndex = selectedYear >= DateTime.now().year
        ? selectedYear - DateTime.now().year
        : 0;
    yearController.animateToItem(
      yearIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    hourController.animateToItem(
      selectedHour,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    minuteController.animateToItem(
      selectedMinute,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  List<String> get _monthNames => [
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

  DateTime get _currentSelectedDateTime {
    return DateTime(
        selectedYear, selectedMonth, selectedDay, selectedHour, selectedMinute);
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

  void _confirmSelection() {
    widget.onSelectionChanged(startDateTime, endDateTime);
    Navigator.of(context).pop();
  }

  Widget _buildScrollablePicker({
    required String title,
    required List<String> items,
    required FixedExtentScrollController controller,
    required Function(int) onSelectedItemChanged,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: MyColor.getTextColor().withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: MyColor.getBorderColor().withValues(alpha: 0.3),
            ),
          ),
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 40,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onSelectedItemChanged,
            perspective: 0.003,
            diameterRatio: 2.0,
            childDelegate: ListWheelChildLoopingListDelegate(
              children: items.asMap().entries.map((entry) {
                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: MyColor.getTextColor(),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MyColor.getCardBgColor(),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header with tab selection
          Container(
            padding: const EdgeInsets.all(Dimensions.space15),
            child: Column(
              children: [
                BottomSheetHeaderRow(
                  header: MyStrings.eventDateTime,
                  bottomSpace: 0,
                ),
                const SizedBox(height: Dimensions.space15),
                // Tab selection
                Container(
                  decoration: BoxDecoration(
                    color: MyColor.getBorderColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isSelectingStart = true;
                              _updateControllers();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isSelectingStart
                                  ? MyColor.getPrimaryColor()
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              'Start Time',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelectingStart
                                    ? Colors.white
                                    : MyColor.getTextColor(),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isSelectingStart = false;
                              // If we don't have an end time but have a start time,
                              // set default end time to 1 hour after start time
                              if (endDateTime == null &&
                                  startDateTime != null) {
                                final defaultEndTime = startDateTime!
                                    .add(const Duration(hours: 1));
                                selectedDay = defaultEndTime.day;
                                selectedMonth = defaultEndTime.month;
                                selectedYear = defaultEndTime.year;
                                selectedHour = defaultEndTime.hour;
                                selectedMinute = defaultEndTime.minute;
                              }
                              _updateControllers();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: !isSelectingStart
                                  ? MyColor.getRedColor()
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              'End Time',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: !isSelectingStart
                                    ? Colors.white
                                    : MyColor.getTextColor(),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Pickers
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding:
                  const EdgeInsets.symmetric(horizontal: Dimensions.space15),
              child: Column(
                children: [
                  // Date Pickers Row
                  Row(
                    children: [
                      // Day Picker
                      Expanded(
                        child: _buildScrollablePicker(
                          title: 'Day',
                          items: List.generate(31, (index) => '${index + 1}'),
                          controller: dayController,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedDay = index + 1;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: Dimensions.space12),
                      // Month Picker
                      Expanded(
                        child: _buildScrollablePicker(
                          title: 'Month',
                          items: _monthNames,
                          controller: monthController,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedMonth = index + 1;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: Dimensions.space12),
                      // Year Picker
                      Expanded(
                        child: _buildScrollablePicker(
                          title: 'Year',
                          items: List.generate(
                            10,
                            (index) => '${DateTime.now().year + index}',
                          ),
                          controller: yearController,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedYear = DateTime.now().year + index;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: Dimensions.space20),

                  // Time Pickers Row
                  Row(
                    children: [
                      // Hour Picker
                      Expanded(
                        child: _buildScrollablePicker(
                          title: 'Hour',
                          items: List.generate(
                              24, (index) => index.toString().padLeft(2, '0')),
                          controller: hourController,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedHour = index;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: Dimensions.space12),
                      // Minute Picker
                      Expanded(
                        child: _buildScrollablePicker(
                          title: 'Minute',
                          items: List.generate(
                              60, (index) => index.toString().padLeft(2, '0')),
                          controller: minuteController,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedMinute = index;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: Dimensions.space20),

                  // Current Selection Display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Dimensions.space15),
                    decoration: BoxDecoration(
                      color: MyColor.getPrimaryColor().withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(Dimensions.cardRadius),
                      border: Border.all(
                        color: MyColor.getPrimaryColor().withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          isSelectingStart ? 'Start Time' : 'End Time',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: MyColor.getPrimaryColor(),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$selectedDay/$selectedMonth/$selectedYear ${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: MyColor.getPrimaryColor(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Duration Display
                  if (startDateTime != null && endDateTime != null) ...[
                    const SizedBox(height: Dimensions.space15),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(Dimensions.space15),
                      decoration: BoxDecoration(
                        color: MyColor.getGreyColor().withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(Dimensions.cardRadius),
                        border: Border.all(
                          color: MyColor.getGreyColor().withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.schedule,
                            color: MyColor.getGreyColor(),
                            size: 20,
                          ),
                          const SizedBox(width: Dimensions.space8),
                          Text(
                            'Duration: ${_calculateDuration()}',
                            style: TextStyle(
                              fontSize: Dimensions.fontDefault,
                              fontWeight: FontWeight.w600,
                              color: MyColor.getGreyColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: Dimensions.space20),
                ],
              ),
            ),
          ),

          // Bottom action buttons
          Container(
            padding: const EdgeInsets.all(Dimensions.space15),
            child: Row(
              children: [
                // Set button
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      final newDateTime = _currentSelectedDateTime;
                      setState(() {
                        if (isSelectingStart) {
                          startDateTime = newDateTime;
                          // If end time is before start time, reset end time
                          if (endDateTime != null &&
                              endDateTime!.isBefore(newDateTime)) {
                            endDateTime = null;
                          }
                          // Automatically switch to End Time tab after setting start time
                          isSelectingStart = false;
                          // Set default end time to 1 hour after start time if no end time exists
                          if (endDateTime == null) {
                            final defaultEndTime =
                                newDateTime.add(const Duration(hours: 1));
                            selectedDay = defaultEndTime.day;
                            selectedMonth = defaultEndTime.month;
                            selectedYear = defaultEndTime.year;
                            selectedHour = defaultEndTime.hour;
                            selectedMinute = defaultEndTime.minute;
                          }
                          _updateControllers();
                        } else {
                          if (startDateTime != null &&
                              newDateTime.isAfter(startDateTime!)) {
                            endDateTime = newDateTime;
                          } else {
                            // Show error
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('End time must be after start time'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: isSelectingStart
                            ? MyColor.getPrimaryColor()
                            : MyColor.getRedColor(),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        isSelectingStart ? 'Set Start' : 'Set End',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.space12),
                // Done button
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onTap: startDateTime != null ? _confirmSelection : null,
                    child: CustomGradiantButton(
                      text: 'Done',
                      isEnable: startDateTime != null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
