import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ovo_meet/core/utils/my_color.dart';

class MaxPersonsSelector extends StatefulWidget {
  final int? initialValue;
  final Function(int?) onChanged;
  final String label;
  final String hint;

  const MaxPersonsSelector({
    Key? key,
    this.initialValue,
    required this.onChanged,
    this.label = 'Max Persons',
    this.hint = 'No limit',
  }) : super(key: key);

  @override
  State<MaxPersonsSelector> createState() => _MaxPersonsSelectorState();
}

class _MaxPersonsSelectorState extends State<MaxPersonsSelector> {
  late TextEditingController _controller;
  bool _hasLimit = false;

  @override
  void initState() {
    super.initState();
    _hasLimit = widget.initialValue != null;
    _controller = TextEditingController(
      text: widget.initialValue?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleLimit(bool hasLimit) {
    setState(() {
      _hasLimit = hasLimit;
      if (!hasLimit) {
        _controller.clear();
        widget.onChanged(null);
      } else {
        // Set default value of 10 when enabling limit
        _controller.text = '10';
        widget.onChanged(10);
      }
    });
  }

  void _onTextChanged(String value) {
    if (value.isEmpty) {
      widget.onChanged(null);
    } else {
      final int? parsedValue = int.tryParse(value);
      if (parsedValue != null && parsedValue > 0) {
        widget.onChanged(parsedValue);
      }
    }
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
              // No limit button
              Expanded(
                child: GestureDetector(
                  onTap: () => _toggleLimit(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: !_hasLimit
                          ? MyColor.getCardBgColor()
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: !_hasLimit
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
                          color: !_hasLimit
                              ? MyColor.getPrimaryColor()
                              : MyColor.getTextColor().withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.hint,
                          style: TextStyle(
                            color: !_hasLimit
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

              // Limited button
              Expanded(
                child: GestureDetector(
                  onTap: () => _toggleLimit(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: _hasLimit
                          ? MyColor.getCardBgColor()
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: _hasLimit
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
                          Icons.group,
                          size: 18,
                          color: _hasLimit
                              ? MyColor.getPrimaryColor()
                              : MyColor.getTextColor().withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Limited',
                          style: TextStyle(
                            color: _hasLimit
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

        // Number input (only shown when limited is selected)
        if (_hasLimit) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: MyColor.getCardBgColor(),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: MyColor.getBorderColor().withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                // Decrease button
                GestureDetector(
                  onTap: () {
                    final currentValue = int.tryParse(_controller.text) ?? 1;
                    if (currentValue > 1) {
                      final newValue = currentValue - 1;
                      _controller.text = newValue.toString();
                      _onTextChanged(newValue.toString());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      color: MyColor.getPrimaryColor().withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.remove,
                      color: MyColor.getPrimaryColor(),
                      size: 20,
                    ),
                  ),
                ),

                // Text input
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MyColor.getTextColor(),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '10',
                        hintStyle: TextStyle(
                          color: MyColor.getSecondaryTextColor(),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onChanged: _onTextChanged,
                    ),
                  ),
                ),

                // Increase button
                GestureDetector(
                  onTap: () {
                    final currentValue = int.tryParse(_controller.text) ?? 0;
                    if (currentValue < 999) {
                      final newValue = currentValue + 1;
                      _controller.text = newValue.toString();
                      _onTextChanged(newValue.toString());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      color: MyColor.getPrimaryColor().withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.add,
                      color: MyColor.getPrimaryColor(),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
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
                    'Set the maximum number of people who can join this event',
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
