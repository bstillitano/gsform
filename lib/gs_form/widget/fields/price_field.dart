import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/enums/field_status.dart';
import 'package:gsform/gs_form/model/fields_model/price_model.dart';
import 'package:intl/intl.dart';

class GSPriceField extends StatefulWidget implements GSFieldCallBack {
  final GSPriceModel model;

  TextEditingController? controller;

  GSPriceField(this.model, {super.key});

  @override
  State<GSPriceField> createState() => _GSPriceFieldState();

  @override
  getValue() {
    return (controller?.text ?? '').replaceAll(',', '');
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

  String _formatNumber(String s) {
    if (s.isEmpty) return '';
    return NumberFormat.decimalPattern().format(int.parse(s));
  }
}

class _GSPriceFieldState extends State<GSPriceField> {
  @override
  void initState() {
    widget.controller ??= TextEditingController();
    if (widget.model.value != null) {
      final formatted =
          widget._formatNumber(widget.model.value.replaceAll(',', ''));
      widget.controller?.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant GSPriceField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model.value == widget.model.value) {
      widget.controller = oldWidget.controller;
    } else {
      widget.controller ??= TextEditingController();
      final formatted =
          widget._formatNumber(widget.model.value.replaceAll(',', ''));
      widget.controller?.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isError = widget.model.status == GSFieldStatusEnum.error;
    final isRequired = widget.model.required ?? false;

    return TextField(
      readOnly: widget.model.enableReadOnly ?? false,
      controller: widget.controller,
      maxLength: widget.model.maxLength,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      focusNode: widget.model.focusNode,
      textInputAction: widget.model.nextFocusNode != null
          ? TextInputAction.next
          : TextInputAction.done,
      onSubmitted: (_) {
        FocusScope.of(context).requestFocus(widget.model.nextFocusNode);
      },
      onChanged: (string) {
        if (string.isNotEmpty) {
          final formatted = widget._formatNumber(string.replaceAll(',', ''));
          widget.controller!.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      },
      decoration: InputDecoration(
        label: widget.model.title != null
            ? _buildLabel(widget.model.title!, isRequired)
            : null,
        hintText: widget.model.hint,
        helperText: widget.model.helpMessage,
        errorText: isError ? widget.model.errorMessage : null,
        counterText: '',
        border: const OutlineInputBorder(),
        prefixIcon: widget.model.prefixWidget,
        suffixIcon: widget.model.postfixWidget,
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
