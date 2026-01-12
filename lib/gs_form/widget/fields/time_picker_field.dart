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
  late BuildContext context;

  GSTimePickerField(this.model, this.onChanged, {super.key}) {
    selectedTimeText = model.hint ?? 'Select a time';
  }

  @override
  State<GSTimePickerField> createState() => _GSTimePickerFieldState();

  @override
  getValue() {
    return _provideData(context);
  }

  @override
  bool isValid() {
    if (!(model.required ?? false)) {
      return true;
    } else {
      return selectedTime != null;
    }
  }

  TimeDataModel? _provideData(BuildContext context) {
    return selectedTime == null
        ? null
        : TimeDataModel(
            displayTime: selectedTime!.format(context),
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
    widget.isTimeSelected = true;
    _displayTime(widget.selectedTime!);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    widget.context = context;
    final isError = widget.model.status == GSFieldStatusEnum.error;

    return InkWell(
      onTap: () {
        _openTimePicker();
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.model.title,
          hintText: widget.model.hint,
          helperText: widget.model.helpMessage,
          errorText: isError ? widget.model.errorMessage : null,
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

  Future<void> _openTimePicker() async {
    var picked = await showTimePicker(
      context: widget.context,
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
