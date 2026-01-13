import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/enums/field_status.dart';
import 'package:gsform/gs_form/model/fields_model/mobile_model.dart';

class GSMobileField extends StatefulWidget implements GSFieldCallBack {
  final GSMobileModel model;

  TextEditingController? controller;

  GSMobileField(this.model, {super.key});

  @override
  State<GSMobileField> createState() => _GSMobileFieldState();

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

class _GSMobileFieldState extends State<GSMobileField> {
  @override
  void initState() {
    widget.controller ??= TextEditingController();
    if (widget.model.value != null) {
      widget.controller?.text = widget.model.value;
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant GSMobileField oldWidget) {
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
    final isError = widget.model.status == GSFieldStatusEnum.error;
    final isRequired = widget.model.required ?? false;

    return TextField(
      readOnly: widget.model.enableReadOnly ?? false,
      controller: widget.controller,
      maxLength: widget.model.maxLength ?? 11,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      focusNode: widget.model.focusNode,
      textInputAction: widget.model.nextFocusNode != null
          ? TextInputAction.next
          : TextInputAction.done,
      onSubmitted: (_) {
        FocusScope.of(context).requestFocus(widget.model.nextFocusNode);
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
