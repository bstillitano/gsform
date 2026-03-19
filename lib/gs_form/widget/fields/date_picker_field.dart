import 'package:flutter/material.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/enums/field_status.dart';
import 'package:gsform/gs_form/model/data_model/date_data_model.dart';
import 'package:gsform/gs_form/model/fields_model/date_picker_model.dart';
import 'package:intl/intl.dart';

class GSDatePickerField extends StatefulWidget implements GSFieldCallBack {
  final GSDatePickerModel model;
  final Function(DateTime?)? onChanged;

  String selectedDateText = '';
  DateTime? selectedGregorianDate;
  BuildContext? context;

  late DateTime gregorianInitialDate;
  late DateTime gregorianAvailableFrom;
  late DateTime gregorianAvailableTo;

  bool isDateSelected = false;

  GSDatePickerField(this.model, this.onChanged, {super.key});

  @override
  State<GSDatePickerField> createState() => _GSDatePickerFieldState();

  @override
  getValue() {
    return _getData();
  }

  @override
  bool isValid() {
    if (!(model.required ?? false)) {
      return true;
    } else {
      return selectedGregorianDate != null;
    }
  }

  DateDataModel? _getData() {
    return selectedGregorianDate == null
        ? null
        : DateDataModel(
            dateServerType: selectedGregorianDate!,
            timeStamp: selectedGregorianDate!.millisecondsSinceEpoch,
            showDateStr: selectedDateText,
          );
  }
}

class _GSDatePickerFieldState extends State<GSDatePickerField> {
  @override
  void initState() {
    _initialDates();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant GSDatePickerField oldWidget) {
    if (oldWidget.selectedGregorianDate != null) {
      widget.model.initialDate = GSDate(
        year: oldWidget.selectedGregorianDate!.year,
        month: oldWidget.selectedGregorianDate!.month,
        day: oldWidget.selectedGregorianDate!.day,
      );
    }
    _initialDates();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    widget.context = context;
    final isError = widget.model.status == GSFieldStatusEnum.error;
    final isRequired = widget.model.required ?? false;
    final defaultErrorMessage = isRequired ? 'Please select a ${widget.model.title?.toLowerCase() ?? 'date'}' : null;

    final picker = InkWell(
      onTap: () {
        _openGregorianPicker();
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
          suffixIcon: const Icon(Icons.calendar_today),
          prefixIcon: widget.model.prefixWidget,
        ),
        child: Text(
          widget.selectedDateText.isEmpty
              ? widget.model.hint ?? ''
              : widget.selectedDateText,
          style: widget.isDateSelected
              ? null
              : Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
        ),
      ),
    );
    // Use IgnorePointer to prevent interaction while maintaining normal appearance
    if (widget.model.enableReadOnly == true) {
      return IgnorePointer(child: picker);
    }
    return picker;
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

  void _initialDates() {
    _initialGregorianDates();
  }

  void _initialGregorianDates() {
    if (widget.model.initialDate == null) {
      widget.gregorianInitialDate = DateTime.now();
    } else {
      widget.gregorianInitialDate = DateTime(
        widget.model.initialDate!.year,
        widget.model.initialDate!.month,
        widget.model.initialDate!.day,
      );
      widget.selectedGregorianDate = widget.gregorianInitialDate;
      _displayGregorianDate();
    }

    if (widget.model.availableTo == null) {
      widget.gregorianAvailableTo = DateTime(2100, 1, 1);
    } else {
      widget.gregorianAvailableTo = DateTime(
        widget.model.availableTo!.year,
        widget.model.availableTo!.month,
        widget.model.availableTo!.day,
      );
    }

    _initialGregorianAvailableFromDate();
  }

  void _initialGregorianAvailableFromDate() {
    // Always use availableFrom if provided
    if (widget.model.availableFrom != null) {
      widget.gregorianAvailableFrom = DateTime(
        widget.model.availableFrom!.year,
        widget.model.availableFrom!.month,
        widget.model.availableFrom!.day,
      );
    } else if (widget.model.isPastAvailable ?? false) {
      // Past dates allowed, no minimum specified - use very old date
      widget.gregorianAvailableFrom = DateTime(1700, 1, 1);
    } else {
      // Past dates not allowed, no minimum specified - use today
      widget.gregorianAvailableFrom = DateTime.now();
    }
  }

  Future<void> _openGregorianPicker() async {
    // Clamp initialDate to be within valid range to avoid assertion errors
    DateTime clampedInitialDate = widget.gregorianInitialDate;
    if (clampedInitialDate.isBefore(widget.gregorianAvailableFrom)) {
      clampedInitialDate = widget.gregorianAvailableFrom;
    }
    if (clampedInitialDate.isAfter(widget.gregorianAvailableTo)) {
      clampedInitialDate = widget.gregorianAvailableTo;
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: clampedInitialDate,
      firstDate: widget.gregorianAvailableFrom,
      lastDate: widget.gregorianAvailableTo,
    );
    if (picked != null) {
      widget.selectedGregorianDate = picked;
      widget.isDateSelected = true;
      widget.gregorianInitialDate = picked;
      _displayGregorianDate();
      _update();
    } else {
      widget.isDateSelected = false;
    }
    widget.onChanged?.call(picked);
  }

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  void _displayGregorianDate() {
    if (widget.model.dateFormatType != null) {
      switch (widget.model.dateFormatType) {
        case GSDateFormatType.numeric:
          widget.selectedDateText =
              DateFormat('dd/MM/yyyy').format(widget.selectedGregorianDate!);
          break;
        case GSDateFormatType.fullText:
          widget.selectedDateText =
              DateFormat('EEE, MMM d, ' 'yyyy').format(widget.selectedGregorianDate!);
          break;
        case GSDateFormatType.mediumText:
          widget.selectedDateText =
              DateFormat('EEE, MMM d').format(widget.selectedGregorianDate!);
          break;
        case GSDateFormatType.shortText:
          widget.selectedDateText =
              DateFormat('MMM d, ' 'yyyy').format(widget.selectedGregorianDate!);
          break;
        default:
          widget.selectedDateText =
              DateFormat('dd/MM/yyyy').format(widget.selectedGregorianDate!);
          break;
      }
    } else {
      widget.selectedDateText =
          DateFormat('dd/MM/yyyy').format(widget.selectedGregorianDate!);
    }
  }
}
