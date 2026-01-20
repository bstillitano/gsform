import 'package:flutter/material.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/enums/field_status.dart';
import 'package:gsform/gs_form/model/data_model/date_data_model.dart';
import 'package:gsform/gs_form/model/fields_model/date_range_picker_model.dart';
import 'package:intl/intl.dart';

class GSDateRangePickerField extends StatefulWidget implements GSFieldCallBack {
  final GSDateRangePickerModel model;

  String selectedDateText = '';

  DateTime? selectedGregorianStartDate;
  DateTime? selectedGregorianEndDate;
  BuildContext? context;

  late DateTime gregorianInitialStartDate;
  late DateTime gregorianInitialEndDate;
  late DateTime gregorianAvailableFrom;
  late DateTime gregorianAvailableTo;

  bool isDateSelected = false;

  GSDateRangePickerField(this.model, {super.key});

  @override
  State<GSDateRangePickerField> createState() => _GSDateRangePickerFieldState();

  @override
  getValue() {
    return _getData();
  }

  @override
  bool isValid() {
    if (!(model.required ?? false)) {
      return true;
    } else {
      return selectedGregorianEndDate != null &&
          selectedGregorianStartDate != null;
    }
  }

  DateDataRangeModel? _getData() {
    return (selectedGregorianEndDate == null &&
            selectedGregorianStartDate == null)
        ? null
        : DateDataRangeModel(
            startDateServerType: selectedGregorianStartDate!,
            endDateServerType: selectedGregorianEndDate!,
            startTimeStamp: selectedGregorianStartDate!.millisecondsSinceEpoch,
            endTimeStamp: selectedGregorianEndDate!.millisecondsSinceEpoch,
            displayStartDateStr: selectedDateText,
            displayEndDateStr: selectedDateText,
          );
  }
}

class _GSDateRangePickerFieldState extends State<GSDateRangePickerField> {
  @override
  void initState() {
    _initialDates();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant GSDateRangePickerField oldWidget) {
    _initialDates();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    widget.context = context;
    final isError = widget.model.status == GSFieldStatusEnum.error;
    final isRequired = widget.model.required ?? false;
    final defaultErrorMessage = isRequired ? 'Please select a ${widget.model.title?.toLowerCase() ?? 'date range'}' : null;

    final picker = InkWell(
      onTap: () {
        if (widget.model.calendarType == GSCalendarType.jalali) {
          _openDateRangePicker();
        } else {
          _openGregorianDateRangePicker();
        }
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
          suffixIcon: const Icon(Icons.date_range),
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

  void _openDateRangePicker() async {
    widget.isDateSelected = false;
  }

  Future<void> _openGregorianDateRangePicker() async {
    var picked = await showDateRangePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendar,
      initialDateRange: DateTimeRange(
        start: widget.gregorianInitialStartDate,
        end: widget.gregorianInitialEndDate,
      ),
      firstDate: widget.gregorianAvailableFrom,
      lastDate: widget.gregorianAvailableTo,
    );
    if (picked?.start != null && picked?.end != null) {
      widget.selectedGregorianStartDate = picked?.start;
      widget.selectedGregorianEndDate = picked?.end;
      widget.gregorianInitialStartDate = picked!.start;
      widget.gregorianInitialEndDate = picked.end;
      widget.isDateSelected = true;
      _displayGregorianDate();
      _update();
    } else {
      widget.isDateSelected = false;
    }
  }

  void _initialDates() {
    _initialGregorianDates();
  }

  void _initialGregorianDates() {
    if (widget.model.initialStartDate == null) {
      widget.gregorianInitialStartDate = DateTime.now();
    } else {
      widget.gregorianInitialStartDate = DateTime(
        widget.model.initialStartDate!.year,
        widget.model.initialStartDate!.month,
        widget.model.initialStartDate!.day,
      );
      widget.selectedGregorianStartDate = widget.gregorianInitialStartDate;
    }

    if (widget.model.initialEndDate == null) {
      widget.gregorianInitialEndDate =
          DateTime.now().add(const Duration(days: 2));
    } else {
      widget.gregorianInitialEndDate = DateTime(
        widget.model.initialEndDate!.year,
        widget.model.initialEndDate!.month,
        widget.model.initialEndDate!.day,
      );
      widget.selectedGregorianEndDate = widget.gregorianInitialEndDate;
    }
    if (widget.model.initialEndDate != null &&
        widget.model.initialStartDate != null) {
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
    if (widget.model.isPastAvailable ?? false) {
      if (widget.model.availableFrom != null) {
        widget.gregorianAvailableFrom = DateTime(
          widget.model.availableFrom!.year,
          widget.model.availableFrom!.month,
          widget.model.availableFrom!.day,
        );
      } else {
        widget.gregorianAvailableFrom = DateTime(1700, 1, 1);
      }
    } else {
      widget.gregorianAvailableFrom = widget.gregorianInitialStartDate;
    }
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
              '${widget.model.from}: ${DateFormat.yMd().format(widget.selectedGregorianStartDate!)}   ${widget.model.to}: ${DateFormat.yMd().format(widget.selectedGregorianEndDate!)}';
          break;
        case GSDateFormatType.fullText:
          widget.selectedDateText =
              '${widget.model.from}: ${DateFormat('EEE, MMM d, ' 'yyyy').format(widget.selectedGregorianStartDate!)}   ${widget.model.to}: ${DateFormat('EEE, MMM d, ' 'yyyy').format(widget.selectedGregorianEndDate!)}';
          break;
        case GSDateFormatType.mediumText:
          widget.selectedDateText =
              '${widget.model.from}: ${DateFormat('EEE, MMM d').format(widget.selectedGregorianStartDate!)}   ${widget.model.to}: ${DateFormat('EEE, MMM d').format(widget.selectedGregorianEndDate!)}';
          break;
        case GSDateFormatType.shortText:
          widget.selectedDateText =
              '${widget.model.from}: ${DateFormat('MMM d, ' 'yyyy').format(widget.selectedGregorianStartDate!)}   ${widget.model.to}: ${DateFormat('MMM d, ' 'yyyy').format(widget.selectedGregorianEndDate!)}';
          break;
        default:
          widget.selectedDateText =
              '${widget.model.from}: ${DateFormat.yMd().format(widget.selectedGregorianStartDate!)}   ${widget.model.to}: ${DateFormat.yMd().format(widget.selectedGregorianEndDate!)}';
          break;
      }
    } else {
      widget.selectedDateText =
          '${widget.model.from}: ${DateFormat.yMd().format(widget.selectedGregorianStartDate!)}   ${widget.model.to}: ${DateFormat.yMd().format(widget.selectedGregorianEndDate!)}';
    }
  }
}
