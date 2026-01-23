import 'package:flutter/material.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/enums/field_status.dart';
import 'package:gsform/gs_form/enums/filed_type.dart';
import 'package:gsform/gs_form/model/fields_model/text_filed_model.dart';
import 'package:gsform/gs_form/widget/form.dart';

class GSTextField extends StatefulWidget implements GSFieldCallBack {
  final GSTextModel model;
  final Function(String)? onChanged;

  TextEditingController? controller;

  GSTextField(this.model, this.onChanged, {super.key});

  @override
  State<GSTextField> createState() => _GSTextFieldState();

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

class _GSTextFieldState extends State<GSTextField> {
  FocusNode? _ownedFocusNode;

  FocusNode get _effectiveFocusNode {
    return widget.model.focusNode ?? (_ownedFocusNode ??= FocusNode());
  }

  @override
  void initState() {
    widget.controller ??= TextEditingController();
    if (widget.model.value != null) {
      widget.controller?.text = widget.model.value;
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant GSTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model.value == widget.model.value) {
      widget.controller = oldWidget.controller;
    } else {
      widget.controller ??= TextEditingController();
      widget.controller!.text = widget.model.value;
    }
  }

  @override
  void dispose() {
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isError = widget.model.status == GSFieldStatusEnum.error;
    final isRequired = widget.model.required ?? false;
    final defaultErrorMessage = isRequired ? '${widget.model.title ?? 'This field'} is required' : null;

    // Register focus node with GSFormScope for keyboard actions
    final formScope = GSFormScope.maybeOf(context);
    formScope?.registerFocusNode?.call(_effectiveFocusNode, GSFieldTypeEnum.text);

    return TextField(
      readOnly: widget.model.enableReadOnly ?? false,
      controller: widget.controller,
      maxLength: widget.model.maxLength,
      keyboardType: TextInputType.text,
      focusNode: _effectiveFocusNode,
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
        helperText: widget.model.helpMessage,
        errorText: isError ? (widget.model.errorMessage ?? defaultErrorMessage) : null,
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
