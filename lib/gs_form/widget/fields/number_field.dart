import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/enums/field_status.dart';
import 'package:gsform/gs_form/model/fields_model/number_model.dart';

class GSNumberField extends StatefulWidget implements GSFieldCallBack {
  final GSNumberModel model;
  final Function(String?)? onChanged;

  TextEditingController? controller;

  GSNumberField(this.model, this.onChanged, {super.key});

  @override
  State<GSNumberField> createState() => _GSNumberFieldState();

  @override
  getValue() {
    return controller?.text ?? '';
  }

  @override
  bool isValid() {
    final text = controller?.text ?? '';

    // Check required
    if (model.required ?? false) {
      if (text.isEmpty) return false;
    } else if (text.isEmpty) {
      return true;
    }

    // Check regex if provided
    if (model.validateRegEx != null) {
      if (!model.validateRegEx!.hasMatch(text)) return false;
    }

    // Check min/max if provided
    final value = double.tryParse(text);
    if (value != null) {
      if (model.minValue != null && value < model.minValue!) return false;
      if (model.maxValue != null && value > model.maxValue!) return false;
    }

    return true;
  }
}

class _GSNumberFieldState extends State<GSNumberField> {
  @override
  void initState() {
    widget.controller ??= TextEditingController();
    if (widget.model.value != null) {
      widget.controller?.text = widget.model.value;
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant GSNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model.value == widget.model.value) {
      widget.controller = oldWidget.controller;
    } else {
      widget.controller ??= TextEditingController();
      widget.controller!.text = widget.model.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isError = widget.model.status == GSFieldStatusEnum.error;
    final isRequired = widget.model.required ?? false;
    final allowDecimal = widget.model.allowDecimal ?? false;
    final allowNegative = widget.model.allowNegative ?? false;
    final helperText = _buildHelperText();

    // Build input formatters based on settings
    List<TextInputFormatter> formatters = [];
    if (!allowDecimal && !allowNegative) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    } else {
      // Allow digits, decimal point, and optionally minus sign
      String pattern = allowNegative ? r'^-?\d*\.?\d*$' : r'^\d*\.?\d*$';
      if (!allowDecimal) {
        pattern = allowNegative ? r'^-?\d*$' : r'^\d*$';
      }
      formatters.add(FilteringTextInputFormatter.allow(RegExp(pattern)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          readOnly: widget.model.enableReadOnly ?? false,
          controller: widget.controller,
          maxLength: widget.model.maxLength,
          keyboardType: TextInputType.numberWithOptions(
            decimal: allowDecimal,
            signed: allowNegative,
          ),
          inputFormatters: formatters,
          focusNode: widget.model.focusNode,
          textInputAction: widget.model.nextFocusNode != null
              ? TextInputAction.next
              : TextInputAction.done,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(widget.model.nextFocusNode);
          },
          onChanged: (value) {
            widget.onChanged?.call(value);
          },
          decoration: InputDecoration(
            label: widget.model.title != null
                ? _buildLabel(widget.model.title!, isRequired)
                : null,
            hintText: widget.model.hint,
            errorText: isError ? widget.model.errorMessage : null,
            counterText: widget.model.showCounter == true ? null : '',
            border: const OutlineInputBorder(),
            prefixIcon: widget.model.prefixWidget,
            suffixIcon: widget.model.postfixWidget,
          ),
        ),
        // Display helper text separately for proper left alignment
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              helperText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  String? _buildHelperText() {
    if (widget.model.helpMessage != null) return widget.model.helpMessage;

    // Auto-generate helper text for min/max if not provided
    final minValue = widget.model.minValue;
    final maxValue = widget.model.maxValue;
    if (minValue != null && maxValue != null) {
      return 'Value must be between ${_formatNumber(minValue)} and ${_formatNumber(maxValue)}';
    } else if (minValue != null) {
      return 'Minimum value: ${_formatNumber(minValue)}';
    } else if (maxValue != null) {
      return 'Maximum value: ${_formatNumber(maxValue)}';
    }
    return null;
  }

  String _formatNumber(double value) {
    return value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  Widget _buildLabel(String title, bool isRequired) {
    if (!isRequired) return Text(title);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        const Text(' *', style: TextStyle(color: Colors.red)),
      ],
    );
  }
}
