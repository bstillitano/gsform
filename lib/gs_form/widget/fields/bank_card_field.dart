import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/enums/field_status.dart';
import 'package:gsform/gs_form/model/fields_model/bank_card_filed_model.dart';
import 'package:gsform/gs_form/util/util.dart';

class GSBankCardField extends StatefulWidget implements GSFieldCallBack {
  final GSBankCardModel model;

  TextEditingController? controller;

  GSBankCardField(this.model, {super.key});

  @override
  State<GSBankCardField> createState() => _GSBankCardFieldState();

  @override
  getValue() {
    return controller!.text.replaceAll(' ', '');
  }

  @override
  bool isValid() {
    if (model.validateRegEx == null) {
      if (!(model.required ?? false)) {
        return true;
      } else {
        return controller!.text.replaceAll(' ', '').length == 16;
      }
    } else {
      return model.validateRegEx!.hasMatch(controller!.text);
    }
  }
}

class _GSBankCardFieldState extends State<GSBankCardField> {
  @override
  void initState() {
    widget.controller ??= TextEditingController();
    if (widget.model.value != null) {
      widget.controller?.text = widget.model.value;
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant GSBankCardField oldWidget) {
    if (oldWidget.model.value == widget.model.value) {
      widget.controller = oldWidget.controller;
    } else {
      widget.controller ??= TextEditingController();
      widget.controller!.text = widget.model.value;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final isError = widget.model.status == GSFieldStatusEnum.error;
    final isRequired = widget.model.required ?? false;

    return TextField(
      readOnly: widget.model.enableReadOnly ?? false,
      inputFormatters: [CardNumberFormatter()],
      textDirection: TextDirection.ltr,
      controller: widget.controller,
      maxLines: 1,
      keyboardType: TextInputType.number,
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
        hintText: widget.model.hint ?? '0000 0000 0000 0000',
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
