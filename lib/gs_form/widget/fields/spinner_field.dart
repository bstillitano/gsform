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
      // Invalid if: null, id is -1 (hint), or empty name with id <= 0 (placeholder)
      if (returnedData == null ||
          returnedData?.id == -1 ||
          (returnedData?.name.isEmpty == true && (returnedData?.id ?? -1) <= 0)) {
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
    // Preserve the old selection - don't reset returnedData
    widget.returnedData = oldWidget.returnedData;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final isError = widget.model.status == GSFieldStatusEnum.error;
    final isRequired = widget.model.required ?? false;
    final defaultErrorMessage = isRequired ? 'Please select a ${widget.model.title?.toLowerCase() ?? 'value'}' : null;

    return DropdownButtonFormField<SpinnerDataModel>(
      value: widget.returnedData,
      isExpanded: true,
      decoration: InputDecoration(
        label: widget.model.title != null
            ? _buildLabel(widget.model.title!, isRequired)
            : null,
        helperText: widget.model.helpMessage,
        errorText: isError ? (widget.model.errorMessage ?? defaultErrorMessage) : null,
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
