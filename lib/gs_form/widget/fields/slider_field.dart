import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/model/fields_model/slider_model.dart';

class GSSliderField extends StatefulWidget implements GSFieldCallBack {
  final GSSliderModel model;
  final Function(double)? onChanged;

  GSSliderField({
    super.key,
    required this.model,
    this.onChanged,
  });

  double currentValue = 0;
  final TextEditingController textController = TextEditingController();

  @override
  bool isValid() {
    if (model.required == true) {
      return true; // Slider always has a value
    }
    return true;
  }

  @override
  dynamic getValue() {
    return currentValue;
  }

  @override
  void setValue(dynamic value) {
    if (value is double) {
      currentValue = value;
    } else if (value is int) {
      currentValue = value.toDouble();
    } else if (value is String) {
      currentValue = double.tryParse(value) ?? model.minValue ?? 0;
    }
  }

  @override
  State<GSSliderField> createState() => _GSSliderFieldState();
}

class _GSSliderFieldState extends State<GSSliderField> {
  late double _value;
  late double _min;
  late double _max;
  late double _step;

  @override
  void initState() {
    super.initState();
    _min = widget.model.minValue ?? 0;
    _max = widget.model.maxValue ?? 100;
    _step = widget.model.step ?? 1;
    _value = widget.model.initialValue ?? _min;

    // Clamp initial value to valid range
    _value = _value.clamp(_min, _max);
    widget.currentValue = _value;
    widget.textController.text = _formatValue(_value);
  }

  @override
  void didUpdateWidget(GSSliderField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update values when props change from parent
    if (oldWidget.model.initialValue != widget.model.initialValue ||
        oldWidget.model.minValue != widget.model.minValue ||
        oldWidget.model.maxValue != widget.model.maxValue ||
        oldWidget.model.step != widget.model.step) {
      _min = widget.model.minValue ?? 0;
      _max = widget.model.maxValue ?? 100;
      _step = widget.model.step ?? 1;

      // Only update value if initialValue changed
      if (oldWidget.model.initialValue != widget.model.initialValue) {
        _value = widget.model.initialValue ?? _min;
        _value = _value.clamp(_min, _max);
        widget.currentValue = _value;
        widget.textController.text = _formatValue(_value);
      }
    }
  }

  String _formatValue(double value) {
    if (_step >= 1 || _step == 0) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  int get _divisions {
    if (_step <= 0) return 0;
    return ((_max - _min) / _step).round();
  }

  void _onSliderChanged(double newValue) {
    setState(() {
      _value = newValue;
      widget.currentValue = _value;
      widget.textController.text = _formatValue(_value);
    });
    widget.onChanged?.call(_value);
  }

  void _onTextFieldSubmitted(String text) {
    final parsed = double.tryParse(text);
    if (parsed != null) {
      final clamped = parsed.clamp(_min, _max);
      setState(() {
        _value = clamped;
        widget.currentValue = _value;
        widget.textController.text = _formatValue(_value);
      });
      widget.onChanged?.call(_value);
    } else {
      // Reset to current value if invalid
      widget.textController.text = _formatValue(_value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showLabels = widget.model.showLabels ?? true;
    final showValueField = widget.model.showValueField ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _value,
                min: _min,
                max: _max,
                divisions: _divisions > 0 ? _divisions : null,
                onChanged: widget.model.enableReadOnly == true ? null : _onSliderChanged,
              ),
            ),
            if (showValueField)
              SizedBox(
                width: 80,
                child: TextField(
                  controller: widget.textController,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  enabled: widget.model.enableReadOnly != true,
                  onSubmitted: _onTextFieldSubmitted,
                  onEditingComplete: () {
                    _onTextFieldSubmitted(widget.textController.text);
                  },
                ),
              ),
          ],
        ),
        if (showLabels)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.model.minLabel ?? _formatValue(_min),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (widget.model.midLabel != null)
                  Text(
                    widget.model.midLabel!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                Text(
                  widget.model.maxLabel ?? _formatValue(_max),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
