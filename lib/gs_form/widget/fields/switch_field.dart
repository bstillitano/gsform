import 'package:flutter/material.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/enums/field_status.dart';
import 'package:gsform/gs_form/model/fields_model/switch_model.dart';

class GSSwitchField extends StatefulWidget implements GSFieldCallBack {
  final GSSwitchModel model;
  bool currentValue;

  GSSwitchField(this.model, {super.key}) : currentValue = model.value ?? false;

  @override
  State<GSSwitchField> createState() => _GSSwitchFieldState();

  @override
  getValue() {
    return currentValue;
  }

  @override
  bool isValid() {
    // Switch fields are always valid since they always have a value (true/false)
    return true;
  }
}

class _GSSwitchFieldState extends State<GSSwitchField> {
  @override
  void initState() {
    super.initState();
    widget.currentValue = widget.model.value ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isError = widget.model.status == GSFieldStatusEnum.error;
    final isReadOnly = widget.model.enableReadOnly ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.model.prefixWidget != null) ...[
              widget.model.prefixWidget!,
              const SizedBox(width: 8),
            ],
            Expanded(
              child: widget.model.title != null
                  ? Text(
                      widget.model.title!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  : const SizedBox.shrink(),
            ),
            Switch(
              value: widget.currentValue,
              onChanged: isReadOnly
                  ? null
                  : (value) {
                      setState(() {
                        widget.currentValue = value;
                      });
                      widget.model.onChange?.call(value);
                    },
            ),
            if (widget.model.postfixWidget != null) ...[
              const SizedBox(width: 8),
              widget.model.postfixWidget!,
            ],
          ],
        ),
        if (widget.model.helpMessage != null && !isError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              widget.model.helpMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
            ),
          ),
        if (isError && widget.model.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              widget.model.errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
      ],
    );
  }
}
