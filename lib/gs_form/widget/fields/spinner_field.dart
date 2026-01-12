import 'package:flutter/material.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/enums/field_status.dart';
import 'package:gsform/gs_form/model/data_model/spinner_data_model.dart';
import 'package:gsform/gs_form/model/fields_model/spinner_model.dart';

class GSSpinnerField extends StatefulWidget implements GSFieldCallBack {
  final int hintIndex = -1;

  final GSSpinnerModel model;
  SpinnerDataModel? returnedData;

  GSSpinnerField(this.model, {super.key});

  @override
  State<GSSpinnerField> createState() => _GSSpinnerFieldState();

  @override
  getValue() {
    return returnedData;
  }

  @override
  bool isValid() {
    if (model.required != null && model.required!) {
      if (returnedData?.id == -1 || returnedData == null) {
        return false;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }
}

class _GSSpinnerFieldState extends State<GSSpinnerField> {
  @override
  void initState() {
    if (widget.model.items.isNotEmpty) {
      for (var element in widget.model.items) {
        if (element.isSelected ?? false) {
          widget.returnedData = element;
        }
      }

      if (widget.returnedData == null) {
        widget.returnedData = widget.model.items[0];
      }

      if (widget.model.hint != null &&
          widget.model.hint!.isNotEmpty &&
          widget.hintIndex != widget.model.items[0].id) {
        widget.model.items.insert(
          0,
          SpinnerDataModel(
            name: widget.model.hint!,
            id: widget.hintIndex,
            data: null,
            isSelected: false,
          ),
        );
      }
    }

    super.initState();
  }

  @override
  void didUpdateWidget(covariant GSSpinnerField oldWidget) {
    widget.returnedData = null;
    for (var element in widget.model.items) {
      if (element.isSelected ?? false) {
        widget.returnedData = element;
        return;
      }
    }
    if (oldWidget.returnedData != null) {
      for (var element in widget.model.items) {
        if (widget.returnedData == null) {
          if (element.id == oldWidget.returnedData!.id) {
            element.isSelected = true;
            widget.returnedData = element;
          } else {
            element.isSelected = false;
          }
        }
        super.didUpdateWidget(oldWidget);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isError = widget.model.status == GSFieldStatusEnum.error;
    final isRequired = widget.model.required ?? false;

    return DropdownButtonFormField<SpinnerDataModel>(
      value: widget.returnedData,
      isExpanded: true,
      decoration: InputDecoration(
        label: widget.model.title != null
            ? _buildLabel(widget.model.title!, isRequired)
            : null,
        helperText: widget.model.helpMessage,
        errorText: isError ? widget.model.errorMessage : null,
        border: const OutlineInputBorder(),
        prefixIcon: widget.model.prefixWidget,
      ),
      items: widget.model.items
          .map((e) => DropdownMenuItem<SpinnerDataModel>(
                value: e,
                child: Text(
                  e.name,
                  style: e.id == widget.hintIndex
                      ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).hintColor,
                          )
                      : null,
                ),
              ))
          .toList(),
      onChanged: (value) {
        if (value?.id != widget.hintIndex) {
          widget.model.items
              .firstWhere((element) => element.id == value!.id)
              .isSelected = true;
          value?.isSelected = true;
          widget.returnedData = value;
          widget.model.onChange?.call(value);
          setState(() {});
        }
      },
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
