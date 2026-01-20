import 'package:flutter/material.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/enums/field_status.dart';
import 'package:gsform/gs_form/model/data_model/time_data_model.dart';
import 'package:gsform/gs_form/model/fields_model/time_picker_model.dart';

class GSTimePickerField extends StatefulWidget implements GSFieldCallBack {
  final GSTimePickerModel model;
  final Function(TimeOfDay?)? onChanged;

  String? selectedTimeText;
  bool isTimeSelected = false;
  TimeOfDay? selectedTime;
  BuildContext? context;

  GSTimePickerField(this.model, this.onChanged, {super.key}) {
    selectedTimeText = model.hint ?? 'Select a time';
  }

  @override
  State<GSTimePickerField> createState() => _GSTimePickerFieldState();

  @override
  getValue() {
    return _provideData();
  }

  @override
  bool isValid() {
    if (!(model.required ?? false)) {
      return true;
    } else {
      return selectedTime != null;
    }
  }

  TimeDataModel? _provideData() {
    if (selectedTime == null) return null;

    // Format time manually to avoid dependency on context
    String hour = selectedTime!.hour.toString().padLeft(2, '0');
    String minute = selectedTime!.minute.toString().padLeft(2, '0');
    String displayTime = '$hour:$minute';

    return TimeDataModel(
      displayTime: displayTime,
      hour: selectedTime!.hour,
      minute: selectedTime!.minute,
    );
  }
}

class _GSTimePickerFieldState extends State<GSTimePickerField> {
  @override
  void initState() {
    super.initState();
    if (widget.model.initialTime != null) {
      widget.selectedTime = widget.model.initialTime;
      widget.isTimeSelected = true;
      _displayTime(widget.selectedTime!);
    }
  }

  @override
  void didUpdateWidget(covariant GSTimePickerField oldWidget) {
    if (widget.model.initialTime != null && oldWidget.selectedTime == null) {
      widget.selectedTime = widget.model.initialTime;
    } else {
      widget.selectedTime = oldWidget.selectedTime;
      widget.selectedTimeText = oldWidget.selectedTimeText;
    }
    if (widget.selectedTime != null) {
      widget.isTimeSelected = true;
      _displayTime(widget.selectedTime!);
    } else {
      widget.isTimeSelected = false;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    widget.context = context;
    final isError = widget.model.status == GSFieldStatusEnum.error;
    final isRequired = widget.model.required ?? false;
    final defaultErrorMessage = isRequired ? 'Please select a ${widget.model.title?.toLowerCase() ?? 'time'}' : null;

    return InkWell(
      onTap: widget.model.enableReadOnly == true ? null : () {
        _openTimePicker();
      },
      child: InputDecorator(
        decoration: InputDecoration(
          label: widget.model.title != null
              ? _buildLabel(widget.model.title!, isRequired)
              : null,
          hintText: widget.model.hint,
          helperText: widget.model.helpMessage,
          errorText: isError ? (widget.model.errorMessage ?? defaultErrorMessage) : null,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.access_time),
          prefixIcon: widget.model.prefixWidget,
        ),
        child: Text(
          widget.selectedTimeText!,
          style: widget.isTimeSelected
              ? null
              : Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).hintColor,
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

  Future<void> _openTimePicker() async {
    var picked = await showTimePicker(
      context: context,
      initialTime: widget.selectedTime ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
      useRootNavigator: false,
    );
    if (picked != null) {
      widget.selectedTime = picked;
      widget.model.initialTime = picked;
      widget.isTimeSelected = true;
      _displayTime(picked);
      _update();
    } else {
      widget.isTimeSelected = false;
    }
    widget.onChanged?.call(picked);
  }

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  void _displayTime(TimeOfDay time) {
    String hour =
        time.hour.toString().length == 1 ? '0${time.hour}' : time.hour.toString();
    String minute = time.minute.toString().length == 1
        ? '0${time.minute}'
        : time.minute.toString();
    widget.selectedTimeText = '$hour:$minute';
  }
}
