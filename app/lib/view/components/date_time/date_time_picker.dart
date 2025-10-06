import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class CustomDateTimePicker extends StatefulWidget {
  final Function(DateTime) onDateTimeChanged;
  final DateTime? initialDateTime;
  final String? title;

  const CustomDateTimePicker({
    Key? key,
    required this.onDateTimeChanged,
    this.initialDateTime,
    this.title,
  }) : super(key: key);

  @override
  State<CustomDateTimePicker> createState() => _CustomDateTimePickerState();
}

class _CustomDateTimePickerState extends State<CustomDateTimePicker> {
  DateTime? selectedDateTime;

  @override
  void initState() {
    super.initState();
    selectedDateTime = widget.initialDateTime ?? DateTime.now();
  }

  void _showDateTimePicker() {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      currentTime: selectedDateTime,
      minTime: DateTime(2000, 1, 1),
      maxTime: DateTime(2100, 12, 31),
      onConfirm: (dateTime) {
        setState(() {
          selectedDateTime = dateTime;
        });
        widget.onDateTimeChanged(dateTime);
      },
      locale: LocaleType.en, // Change locale if needed
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayText = selectedDateTime != null
        ? '${selectedDateTime!.toLocal()}'.split('.')[0]
        : 'No date selected';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.title!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                displayText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _showDateTimePicker,
          icon: const Icon(Icons.calendar_today),
          label: const Text('Select Date & Time'),
        ),
      ],
    );
  }
}
