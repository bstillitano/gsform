import 'package:flutter/material.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/enums/field_status.dart';
import 'package:gsform/gs_form/model/fields_model/text_password_model.dart';

class GSPasswordField extends StatefulWidget implements GSFieldCallBack {
  final GSPasswordModel model;
  bool obscured = true;

  TextEditingController? controller;

  GSPasswordField(this.model, {super.key});

  @override
  State<GSPasswordField> createState() => _GSPasswordFieldState();

  @override
  getValue() {
    return controller!.text;
  }

  @override
  bool isValid() {
    if (model.validateRegEx == null) {
      if (!(model.required ?? false)) {
        return true;
      } else {
        return controller!.text.isNotEmpty;
      }
    } else {
      return model.validateRegEx!.hasMatch(controller!.text);
    }
  }
}

class _GSPasswordFieldState extends State<GSPasswordField> {
  @override
  void initState() {
    widget.controller ??= TextEditingController();

    if (widget.model.value != null) {
      widget.controller?.text = widget.model.value;
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant GSPasswordField oldWidget) {
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
      textAlignVertical: TextAlignVertical.center,
      keyboardType: TextInputType.visiblePassword,
      obscureText: widget.obscured,
      focusNode: widget.model.focusNode,
      controller: widget.controller,
      obscuringCharacter: '●',
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
        suffixIcon: IconButton(
          onPressed: _toggleVisibility,
          icon: Icon(
            widget.obscured
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
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

  void _toggleVisibility() {
    if (mounted) {
      setState(() => widget.obscured = !widget.obscured);
    }
  }

  @override
  void dispose() {
    widget.controller?.dispose();
    super.dispose();
  }
}
