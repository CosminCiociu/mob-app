import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ovo_meet/core/utils/my_color.dart';

class AgeRangeSelector extends StatefulWidget {
  final int? initialMinAge;
  final int? initialMaxAge;
  final Function(int?, int?) onChanged;
  final String label;
  final String hint;

  const AgeRangeSelector({
    Key? key,
    this.initialMinAge,
    this.initialMaxAge,
    required this.onChanged,
    this.label = 'Age Range',
    this.hint = 'No age limit',
  }) : super(key: key);

  @override
  State<AgeRangeSelector> createState() => _AgeRangeSelectorState();
}

class _AgeRangeSelectorState extends State<AgeRangeSelector> {
  late TextEditingController _minAgeController;
  late TextEditingController _maxAgeController;
  bool _hasAgeLimit = false;

  @override
  void initState() {
    super.initState();
    _hasAgeLimit = widget.initialMinAge != null || widget.initialMaxAge != null;
    _minAgeController = TextEditingController(
      text: widget.initialMinAge?.toString() ?? '',
    );
    _maxAgeController = TextEditingController(
      text: widget.initialMaxAge?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _minAgeController.dispose();
    _maxAgeController.dispose();
    super.dispose();
  }

  void _toggleAgeLimit(bool hasLimit) {
    setState(() {
      _hasAgeLimit = hasLimit;
      if (!hasLimit) {
        _minAgeController.clear();
        _maxAgeController.clear();
        widget.onChanged(null, null);
      } else {
        // Set default values when enabling age limit
        _minAgeController.text = '18';
        _maxAgeController.text = '65';
        widget.onChanged(18, 65);
      }
    });
  }

  void _onAgeChanged() {
    final int? minAge = _minAgeController.text.isEmpty
        ? null
        : int.tryParse(_minAgeController.text);
    final int? maxAge = _maxAgeController.text.isEmpty
        ? null
        : int.tryParse(_maxAgeController.text);

    // Validate age range
    if (minAge != null && maxAge != null && minAge > maxAge) {
      // If min age is greater than max age, adjust max age
      _maxAgeController.text = minAge.toString();
      widget.onChanged(minAge, minAge);
    } else {
      widget.onChanged(minAge, maxAge);
    }
  }

  void _adjustAge(bool isMinAge, bool isIncrement) {
    final controller = isMinAge ? _minAgeController : _maxAgeController;
    final currentValue = int.tryParse(controller.text) ?? (isMinAge ? 18 : 65);

    int newValue;
    if (isIncrement) {
      newValue = currentValue < 100 ? currentValue + 1 : currentValue;
    } else {
      newValue =
          currentValue > (isMinAge ? 1 : 1) ? currentValue - 1 : currentValue;
    }

    controller.text = newValue.toString();
    _onAgeChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: MyColor.getTextColor(),
          ),
        ),
        const SizedBox(height: 8),

        // Toggle buttons container
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: MyColor.getBorderColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // No age limit button
              Expanded(
                child: GestureDetector(
                  onTap: () => _toggleAgeLimit(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: !_hasAgeLimit
                          ? MyColor.getCardBgColor()
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: !_hasAgeLimit
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.all_inclusive,
                          size: 18,
                          color: !_hasAgeLimit
                              ? MyColor.getPrimaryColor()
                              : MyColor.getTextColor().withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.hint,
                          style: TextStyle(
                            color: !_hasAgeLimit
                                ? MyColor.getTextColor()
                                : MyColor.getTextColor().withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Age limit button
              Expanded(
                child: GestureDetector(
                  onTap: () => _toggleAgeLimit(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: _hasAgeLimit
                          ? MyColor.getCardBgColor()
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: _hasAgeLimit
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: _hasAgeLimit
                              ? MyColor.getPrimaryColor()
                              : MyColor.getTextColor().withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Age Limit',
                          style: TextStyle(
                            color: _hasAgeLimit
                                ? MyColor.getTextColor()
                                : MyColor.getTextColor().withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Age input fields (only shown when age limit is selected)
        if (_hasAgeLimit) ...[
          const SizedBox(height: 12),

          // Age range inputs
          Row(
            children: [
              // Min Age
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Min Age',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: MyColor.getSecondaryTextColor(),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: MyColor.getCardBgColor(),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              MyColor.getBorderColor().withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Decrease button
                          GestureDetector(
                            onTap: () => _adjustAge(true, false),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                color: MyColor.getPrimaryColor()
                                    .withValues(alpha: 0.1),
                              ),
                              child: Icon(
                                Icons.remove,
                                color: MyColor.getPrimaryColor(),
                                size: 16,
                              ),
                            ),
                          ),

                          // Text input
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: TextFormField(
                                controller: _minAgeController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: MyColor.getTextColor(),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '18',
                                  hintStyle: TextStyle(
                                    color: MyColor.getSecondaryTextColor(),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onChanged: (_) => _onAgeChanged(),
                              ),
                            ),
                          ),

                          // Increase button
                          GestureDetector(
                            onTap: () => _adjustAge(true, true),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                color: MyColor.getPrimaryColor()
                                    .withValues(alpha: 0.1),
                              ),
                              child: Icon(
                                Icons.add,
                                color: MyColor.getPrimaryColor(),
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Max Age
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Max Age',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: MyColor.getSecondaryTextColor(),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: MyColor.getCardBgColor(),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              MyColor.getBorderColor().withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Decrease button
                          GestureDetector(
                            onTap: () => _adjustAge(false, false),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                color: MyColor.getPrimaryColor()
                                    .withValues(alpha: 0.1),
                              ),
                              child: Icon(
                                Icons.remove,
                                color: MyColor.getPrimaryColor(),
                                size: 16,
                              ),
                            ),
                          ),

                          // Text input
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: TextFormField(
                                controller: _maxAgeController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: MyColor.getTextColor(),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '65',
                                  hintStyle: TextStyle(
                                    color: MyColor.getSecondaryTextColor(),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onChanged: (_) => _onAgeChanged(),
                              ),
                            ),
                          ),

                          // Increase button
                          GestureDetector(
                            onTap: () => _adjustAge(false, true),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                color: MyColor.getPrimaryColor()
                                    .withValues(alpha: 0.1),
                              ),
                              child: Icon(
                                Icons.add,
                                color: MyColor.getPrimaryColor(),
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Helper text
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: MyColor.getSecondaryTextColor(),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Set the age range for participants in this event',
                    style: TextStyle(
                      fontSize: 12,
                      color: MyColor.getSecondaryTextColor(),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
