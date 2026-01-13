import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/enums/field_status.dart';
import 'package:gsform/gs_form/model/fields_model/stepper_model.dart';

class GSStepperField extends StatefulWidget implements GSFieldCallBack {
  final GSStepperModel model;
  final Function(String?)? onChanged;

  TextEditingController? controller;
  double currentValue = 0;

  GSStepperField(this.model, this.onChanged, {super.key});

  @override
  State<GSStepperField> createState() => _GSStepperFieldState();

  @override
  getValue() {
    return controller?.text ?? '';
  }

  @override
  bool isValid() {
    final text = controller?.text ?? '';
    if (model.validateRegEx == null) {
      if (!(model.required ?? false)) {
        return true;
      } else {
        return text.isNotEmpty;
      }
    } else {
      return model.validateRegEx!.hasMatch(text);
    }
  }
}

class _GSStepperFieldState extends State<GSStepperField> {
  @override
  void initState() {
    widget.controller ??= TextEditingController();
    if (widget.model.value != null) {
      widget.controller?.text = widget.model.value.toString();
      widget.currentValue = double.tryParse(widget.model.value.toString()) ?? 0;
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant GSStepperField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model.value == widget.model.value) {
      widget.controller = oldWidget.controller;
      widget.currentValue = oldWidget.currentValue;
    } else {
      widget.controller ??= TextEditingController();
      widget.controller!.text = widget.model.value?.toString() ?? '';
      widget.currentValue = double.tryParse(widget.model.value?.toString() ?? '') ?? 0;
    }
  }

  void _increment() {
    final step = widget.model.step ?? 1;
    final maxValue = widget.model.maxValue;

    double newValue = widget.currentValue + step;
    if (maxValue != null && newValue > maxValue) {
      newValue = maxValue;
    }

    _updateValue(newValue);
  }

  void _decrement() {
    final step = widget.model.step ?? 1;
    final minValue = widget.model.minValue;
    final allowNegative = widget.model.allowNegative ?? true;

    double newValue = widget.currentValue - step;
    if (minValue != null && newValue < minValue) {
      newValue = minValue;
    }
    if (!allowNegative && newValue < 0) {
      newValue = 0;
    }

    _updateValue(newValue);
  }

  void _updateValue(double value) {
    setState(() {
      widget.currentValue = value;
      final allowDecimal = widget.model.allowDecimal ?? true;
      if (allowDecimal) {
        // Remove unnecessary trailing zeros
        widget.controller?.text = value.toString().replaceAll(RegExp(r'\.0$'), '');
      } else {
        widget.controller?.text = value.toInt().toString();
      }
      widget.onChanged?.call(widget.controller?.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isError = widget.model.status == GSFieldStatusEnum.error;
    final isRequired = widget.model.required ?? false;
    final allowDecimal = widget.model.allowDecimal ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.model.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildLabel(widget.model.title!, isRequired),
          ),
        Row(
          children: [
            // Decrement button
            _buildStepperButton(
              icon: Icons.remove,
              onPressed: widget.model.enableReadOnly == true ? null : _decrement,
              theme: theme,
            ),
            const SizedBox(width: 8),
            // Text field
            Expanded(
              child: TextField(
                readOnly: widget.model.enableReadOnly ?? false,
                controller: widget.controller,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: allowDecimal,
                  signed: widget.model.allowNegative ?? true,
                ),
                inputFormatters: [
                  if (allowDecimal)
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))
                  else
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                ],
                textAlign: TextAlign.center,
                onChanged: (value) {
                  widget.currentValue = double.tryParse(value) ?? 0;
                  widget.onChanged?.call(value);
                },
                decoration: InputDecoration(
                  hintText: widget.model.hint,
                  helperText: widget.model.helpMessage,
                  errorText: isError ? widget.model.errorMessage : null,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  prefixText: widget.model.prefix,
                  suffixText: widget.model.suffix,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Increment button
            _buildStepperButton(
              icon: Icons.add,
              onPressed: widget.model.enableReadOnly == true ? null : _increment,
              theme: theme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: theme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
        ),
      ),
    );
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
