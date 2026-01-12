import 'package:flutter/material.dart';
import 'package:gsform/gs_form/core/constant.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/enums/field_status.dart';
import 'package:gsform/gs_form/model/fields_model/email_model.dart';

class GSEmailField extends StatefulWidget implements GSFieldCallBack {
  final GSEmailModel model;

  TextEditingController? controller;

  GSEmailField(this.model, {super.key});

  @override
  State<GSEmailField> createState() => _GSEmailFieldState();

  @override
  getValue() {
    return controller!.text;
  }

  @override
  bool isValid() {
    if (model.validateRegEx == null) {
      if (controller!.text.isNotEmpty) {
        return RegExp(GSConstant.emailRegEx).hasMatch(controller!.text);
      }
      if (!(model.required ?? false)) {
        return true;
      }
      return controller!.text.isNotEmpty;
    }
    return model.validateRegEx!.hasMatch(controller!.text);
  }
}

class _GSEmailFieldState extends State<GSEmailField> {
  @override
  void initState() {
    widget.controller ??= TextEditingController();
    if (widget.model.value != null) {
      widget.controller?.text = widget.model.value;
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant GSEmailField oldWidget) {
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
      maxLength: widget.model.maxLength,
      keyboardType: TextInputType.emailAddress,
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
