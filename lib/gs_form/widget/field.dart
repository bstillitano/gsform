import 'package:flutter/material.dart';
import 'package:gsform/gs_form/enums/field_status.dart';
import 'package:gsform/gs_form/enums/filed_type.dart';
import 'package:gsform/gs_form/model/data_model/check_data_model.dart';
import 'package:gsform/gs_form/model/data_model/date_data_model.dart';
import 'package:gsform/gs_form/model/data_model/radio_data_model.dart';
import 'package:gsform/gs_form/model/data_model/spinner_data_model.dart';
import 'package:gsform/gs_form/model/fields_model/bank_card_filed_model.dart';
import 'package:gsform/gs_form/model/fields_model/checkbox_model.dart';
import 'package:gsform/gs_form/model/fields_model/date_picker_model.dart';
import 'package:gsform/gs_form/model/fields_model/date_range_picker_model.dart';
import 'package:gsform/gs_form/model/fields_model/email_model.dart';
import 'package:gsform/gs_form/model/fields_model/field_model.dart';
import 'package:gsform/gs_form/model/fields_model/image_picker_model.dart';
import 'package:gsform/gs_form/model/fields_model/mobile_model.dart';
import 'package:gsform/gs_form/model/fields_model/multi_image_picker_model.dart';
import 'package:gsform/gs_form/model/fields_model/number_model.dart';
import 'package:gsform/gs_form/model/fields_model/price_model.dart';
import 'package:gsform/gs_form/model/fields_model/qr_scanner_model.dart';
import 'package:gsform/gs_form/model/fields_model/radio_model.dart';
import 'package:gsform/gs_form/model/fields_model/spinner_model.dart';
import 'package:gsform/gs_form/model/fields_model/text_filed_model.dart';
import 'package:gsform/gs_form/model/fields_model/text_password_model.dart';
import 'package:gsform/gs_form/model/fields_model/text_plain_model.dart';
import 'package:gsform/gs_form/model/fields_model/time_picker_model.dart';
import 'package:gsform/gs_form/widget/fields/bank_card_field.dart';
import 'package:gsform/gs_form/widget/fields/check_list_field.dart';
import 'package:gsform/gs_form/widget/fields/date_picker_field.dart';
import 'package:gsform/gs_form/widget/fields/date_range_picker_field.dart';
import 'package:gsform/gs_form/widget/fields/email_field.dart';
import 'package:gsform/gs_form/widget/fields/image_picker_field.dart';
import 'package:gsform/gs_form/widget/fields/mobile_field.dart';
import 'package:gsform/gs_form/widget/fields/number_field.dart';
import 'package:gsform/gs_form/widget/fields/password_field.dart';
import 'package:gsform/gs_form/widget/fields/price_field.dart';
import 'package:gsform/gs_form/widget/fields/qr_scanner_field.dart';
import 'package:gsform/gs_form/widget/fields/radio_group_field.dart';
import 'package:gsform/gs_form/widget/fields/spinner_field.dart';
import 'package:gsform/gs_form/widget/fields/text_field.dart';
import 'package:gsform/gs_form/widget/fields/text_plain_field.dart';
import 'package:gsform/gs_form/widget/fields/time_picker_field.dart';
import 'package:gsform/gs_form/widget/fields/multi_image_picker_field.dart';
import 'package:gsform/gs_form/enums/required_check_list_enum.dart';

/// A form field widget that wraps various input types.
///
/// Use the factory constructors to create specific field types:
/// - [GSField.text] - Text input
/// - [GSField.email] - Email input with validation
/// - [GSField.password] - Password input with visibility toggle
/// - [GSField.number] - Numeric input
/// - [GSField.spinner] - Dropdown selector
/// - [GSField.datePicker] - Date picker
/// - [GSField.timePicker] - Time picker
/// - etc.
///
/// Fields automatically inherit styling from the app's [ThemeData].
/// Customize appearance via [ThemeData.inputDecorationTheme].
class GSField extends StatefulWidget {
  GSFieldModel? model;
  Widget? child;

  VoidCallback? onUpdate;
  Function(String?)? onChange;
  Function(List<String>?)? onArrayChange;
  Function(DateTime?)? onDateChange;
  Function(TimeOfDay?)? onTimeChange;

  void update() {
    onUpdate?.call();
  }

  //<editor-fold desc="Component Constructors">

  GSField.qrScanner({
    super.key,
    required String tag,
    String? title,
    String? errorMessage,
    String? helpMessage,
    bool? required,
    GSFieldStatusEnum? status,
    int? weight,
    String? hint,
    Widget? iconWidget,
    bool? enableReadOnly,
  }) {
    model = GSQRScannerModel(
      type: GSFieldTypeEnum.qrScanner,
      tag: tag,
      title: title,
      errorMessage: errorMessage,
      helpMessage: helpMessage,
      required: required,
      status: status,
      weight: weight,
      hint: hint,
      iconWidget: iconWidget,
      enableReadOnly: enableReadOnly,
    );
  }

  GSField.imagePicker({
    super.key,
    required String tag,
    required Widget iconWidget,
    String? defaultImagePathValue,
    String? title,
    String? errorMessage,
    String? helpMessage,
    bool? required,
    GSFieldStatusEnum? status,
    int? weight,
    String? hint,
    String? cameraPopupTitle,
    String? galleryPopupTitle,
    String? cameraPopupIcon,
    String? galleryPopupIcon,
    GSImageSource? imageSource,
    bool? showCropper,
    double? maximumSizePerImageInBytes,
    VoidCallback? onErrorSizeItem,
    Function(String?)? onChanged,
  }) {
    model = GSImagePickerModel(
      type: GSFieldTypeEnum.imagePicker,
      tag: tag,
      showCropper: showCropper ?? true,
      imageSource: imageSource ?? GSImageSource.both,
      title: title,
      cameraPopupTitle: cameraPopupTitle,
      galleryPopupTitle: galleryPopupTitle,
      cameraPopupIcon: cameraPopupIcon,
      galleryPopupIcon: galleryPopupIcon,
      errorMessage: errorMessage,
      helpMessage: helpMessage,
      required: required,
      status: status,
      weight: weight,
      hint: hint,
      iconWidget: iconWidget,
      value: defaultImagePathValue,
      maximumSizePerImageInBytes: maximumSizePerImageInBytes,
      onErrorSizeItem: onErrorSizeItem,
    );
    onChange = onChanged;
  }

  GSField.multiImagePicker({
    super.key,
    required String tag,
    required Widget iconWidget,
    List<String>? defaultImagePathValues,
    String? title,
    String? errorMessage,
    String? helpMessage,
    bool? required,
    GSFieldStatusEnum? status,
    int? weight,
    String? hint,
    String? cameraPopupTitle,
    String? galleryPopupTitle,
    String? cameraPopupIcon,
    String? galleryPopupIcon,
    GSImageSource? imageSource,
    bool? showCropper,
    double? maximumSizePerImageInKB,
    double? maximumImageCount,
    VoidCallback? onErrorSizeItem,
    Function(List<String>?)? onChanged,
  }) {
    model = GSMultiImagePickerModel(
      type: GSFieldTypeEnum.multiImagePicker,
      tag: tag,
      showCropper: showCropper ?? true,
      imageSource: imageSource ?? GSImageSource.both,
      title: title,
      cameraPopupTitle: cameraPopupTitle,
      galleryPopupTitle: galleryPopupTitle,
      cameraPopupIcon: cameraPopupIcon,
      galleryPopupIcon: galleryPopupIcon,
      errorMessage: errorMessage,
      helpMessage: helpMessage,
      required: required,
      status: status,
      weight: weight,
      hint: hint,
      iconWidget: iconWidget,
      defaultImagePath: defaultImagePathValues,
      maximumImageCount: maximumImageCount,
      maximumSizePerImageInKB: maximumSizePerImageInKB,
      onErrorSizeItem: onErrorSizeItem,
    );
    onArrayChange = onChanged;
  }

  GSField.spinner({
    super.key,
    required String tag,
    String? title,
    String? errorMessage,
    String? helpMessage,
    Widget? prefixWidget,
    bool? required,
    GSFieldStatusEnum? status,
    int? weight,
    SpinnerDataModel? value,
    ValueChanged<SpinnerDataModel?>? onChange,
    required List<SpinnerDataModel> items,
    String? hint,
  }) {
    model = GSSpinnerModel(
      type: GSFieldTypeEnum.spinner,
      tag: tag,
      title: title,
      errorMessage: errorMessage,
      helpMessage: helpMessage,
      prefixWidget: prefixWidget,
      required: required,
      status: status,
      weight: weight,
      items: items,
      hint: hint,
      onChange: onChange,
      value: value,
    );
  }

  GSField.radioGroup({
    super.key,
    required String tag,
    String? title,
    String? errorMessage,
    String? helpMessage,
    bool? required,
    GSFieldStatusEnum? status,
    int? weight,
    String? hint,
    Axis? scrollDirection,
    Widget? selectedIcon,
    Widget? unSelectedIcon,
    bool? scrollable,
    double? height,
    bool? showScrollBar,
    Color? scrollBarColor,
    required bool searchable,
    String? searchHint,
    Icon? searchIcon,
    BoxDecoration? searchBoxDecoration,
    required List<RadioDataModel> items,
    required ValueChanged<RadioDataModel> callBack,
  }) {
    model = GSRadioModel(
      type: GSFieldTypeEnum.radioGroup,
      tag: tag,
      title: title,
      errorMessage: errorMessage,
      helpMessage: helpMessage,
      required: required,
      status: status,
      weight: weight,
      showScrollBar: showScrollBar,
      scrollBarColor: scrollBarColor,
      hint: hint,
      items: items,
      callBack: callBack,
      scrollDirection: scrollDirection,
      unSelectedIcon: unSelectedIcon,
      selectedIcon: selectedIcon,
      scrollable: scrollable ?? false,
      height: height,
      searchable: searchable,
      searchHint: searchHint,
      searchIcon: searchIcon,
      searchBoxDecoration: searchBoxDecoration,
    );
  }

  GSField.checkList({
    super.key,
    required String tag,
    required bool searchable,
    required List<CheckDataModel> items,
    required ValueChanged<CheckDataModel> callBack,
    RequiredCheckListEnum? requiredCheckListEnum,
    String? title,
    String? errorMessage,
    String? helpMessage,
    GSFieldStatusEnum? status,
    int? weight,
    String? hint,
    Axis? scrollDirection,
    Widget? selectedIcon,
    Widget? unSelectedIcon,
    bool? scrollable,
    double? height,
    bool? showScrollBar,
    Color? scrollBarColor,
    String? searchHint,
    Icon? searchIcon,
    BoxDecoration? searchBoxDecoration,
  }) {
    bool isRequired = false;
    if (requiredCheckListEnum != null &&
        requiredCheckListEnum != RequiredCheckListEnum.none) {
      isRequired = true;
    }
    model = GSCheckBoxModel(
      type: GSFieldTypeEnum.checkList,
      tag: tag,
      title: title,
      errorMessage: errorMessage,
      helpMessage: helpMessage,
      required: isRequired,
      status: status,
      weight: weight,
      showScrollBar: showScrollBar,
      scrollBarColor: scrollBarColor,
      hint: hint,
      items: items,
      callBack: callBack,
      scrollDirection: scrollDirection,
      unSelectedIcon: unSelectedIcon,
      selectedIcon: selectedIcon,
      scrollable: scrollable ?? false,
      height: height,
      searchable: searchable,
      searchHint: searchHint,
      searchIcon: searchIcon,
      searchBoxDecoration: searchBoxDecoration,
      requiredCheckListEnum: requiredCheckListEnum,
    );
  }

  GSField.text({
    super.key,
    required String tag,
    String? title,
    String? errorMessage,
    String? helpMessage,
    Widget? prefixWidget,
    Widget? postfixWidget,
    bool? required,
    GSFieldStatusEnum? status,
    String? value,
    int? weight,
    RegExp? validateRegEx,
    int? maxLength,
    String? hint,
    bool? readOnly,
    Function(String?)? onChanged,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
  }) {
    model = GSTextModel(
      type: GSFieldTypeEnum.text,
      tag: tag,
      focusNode: focusNode,
      nextFocusNode: nextFocusNode,
      title: title,
      errorMessage: errorMessage,
      helpMessage: helpMessage,
      prefixWidget: prefixWidget,
      postfixWidget: postfixWidget,
      required: required,
      status: status,
      value: value,
      weight: weight,
      maxLength: maxLength,
      hint: hint,
      enableReadOnly: readOnly,
    );
    onChange = onChanged;
  }

  GSField.password({
    super.key,
    required String tag,
    String? title,
    String? errorMessage,
    String? helpMessage,
    Widget? prefixWidget,
    bool? required,
    GSFieldStatusEnum? status,
    String? value,
    int? weight,
    RegExp? validateReg,
    int? maxLength,
    String? hint,
    bool? readOnly,
  }) {
    model = GSPasswordModel(
      type: GSFieldTypeEnum.password,
      tag: tag,
      title: title,
      errorMessage: errorMessage,
      helpMessage: helpMessage,
      prefixWidget: prefixWidget,
      required: required,
      status: status,
      value: value,
      weight: weight,
      hint: hint,
      maxLength: maxLength,
      enableReadOnly: readOnly,
    );
  }

  GSField.textPlain({
    super.key,
    required String tag,
    String? title,
    String? errorMessage,
    String? helpMessage,
    Widget? prefixWidget,
    Widget? postfixWidget,
    bool? required,
    GSFieldStatusEnum? status,
    String? value,
    int? weight,
    int? maxLength,
    int? minLine,
    int? maxLine,
    String? hint,
    bool? showCounter,
    bool? readOnly,
    Function(String?)? onChanged,
  }) {
    model = GSTextPlainModel(
      type: GSFieldTypeEnum.textPlain,
      tag: tag,
      title: title,
      errorMessage: errorMessage,
      helpMessage: helpMessage,
      prefixWidget: prefixWidget,
      postfixWidget: postfixWidget,
      required: required,
      status: status,
      value: value,
      weight: weight,
      hint: hint,
      maxLine: maxLine,
      minLine: minLine,
      maxLength: maxLength,
      showCounter: showCounter,
      enableReadOnly: readOnly,
    );
    onChange = onChanged;
  }

  GSField.mobile({
    super.key,
    required String tag,
    String? title,
    String? errorMessage,
    String? helpMessage,
    Widget? prefixWidget,
    Widget? postfixWidget,
    bool? required,
    GSFieldStatusEnum? status,
    String? value,
    int? weight,
    int? maxLength,
    String? hint,
    bool? readOnly,
  }) {
    model = GSMobileModel(
      type: GSFieldTypeEnum.mobile,
      tag: tag,
      title: title,
      errorMessage: errorMessage,
      helpMessage: helpMessage,
      prefixWidget: prefixWidget,
      postfixWidget: postfixWidget,
      required: required,
      status: status,
      value: value,
      weight: weight,
      maxLength: maxLength,
      hint: hint,
      enableReadOnly: readOnly,
    );
  }

  GSField.number({
    super.key,
    required String tag,
    String? title,
    String? errorMessage,
    String? helpMessage,
    Widget? prefixWidget,
    Widget? postfixWidget,
    bool? required,
    GSFieldStatusEnum? status,
    String? value,
    int? weight,
    int? maxLength,
    bool? showCounter,
    String? hint,
    bool? readOnly,
  }) {
    model = GSNumberModel(
      type: GSFieldTypeEnum.number,
      tag: tag,
      title: title,
      errorMessage: errorMessage,
      helpMessage: helpMessage,
      prefixWidget: prefixWidget,
      postfixWidget: postfixWidget,
      required: required,
      status: status,
      value: value,
      weight: weight,
      maxLength: maxLength,
      hint: hint,
      showCounter: showCounter,
      enableReadOnly: readOnly,
    );
  }

  GSField.datePicker({
    super.key,
    required String tag,
    required GSCalendarType calendarType,
    String? title,
    String? errorMessage,
    String? helpMessage,
    Widget? prefixWidget,
    Widget? postfixWidget,
    bool? required,
    GSFieldStatusEnum? status,
    int? weight,
    String? hint,
    GSDateFormatType? displayDateType,
    bool? isPastAvailable,
    GSDate? initialDate,
    GSDate? availableFrom,
    GSDate? availableTo,
    Function(DateTime?)? onChanged,
  }) {
    model = GSDatePickerModel(
      type: GSFieldTypeEnum.date,
      tag: tag,
      title: title,
      errorMessage: errorMessage,
      helpMessage: helpMessage,
      calendarType: calendarType,
      prefixWidget: prefixWidget,
      postfixWidget: postfixWidget,
      required: required,
      status: status,
      weight: weight,
      hint: hint,
      isPastAvailable: isPastAvailable,
      dateFormatType: displayDateType,
      initialDate: initialDate,
      availableFrom: availableTo,
      availableTo: availableTo,
    );
    onDateChange = onChanged;
  }

  GSField.dateRangePicker({
    super.key,
    required String tag,
    required GSCalendarType calendarType,
    String? title,
    String? errorMessage,
    String? helpMessage,
    String? from,
    String? to,
    Widget? prefixWidget,
    Widget? postfixWidget,
    bool? required,
    GSFieldStatusEnum? status,
    int? weight,
    String? hint,
    GSDateFormatType? displayDateType,
    bool? isPastAvailable,
    GSDate? initialStartDate,
    GSDate? initialEndDate,
    GSDate? availableFrom,
    GSDate? availableTo,
  }) {
    model = GSDateRangePickerModel(
      type: GSFieldTypeEnum.dateRage,
      tag: tag,
      title: title,
      errorMessage: errorMessage,
      helpMessage: helpMessage,
      from: from ?? 'From ',
      to: to ?? 'To ',
      prefixWidget: prefixWidget,
      postfixWidget: postfixWidget,
      required: required,
      status: status,
      weight: weight,
      hint: hint,
      isPastAvailable: isPastAvailable,
      dateFormatType: displayDateType,
      initialStartDate: initialStartDate,
      initialEndDate: initialEndDate,
      availableFrom: availableTo,
      availableTo: availableTo,
      calendarType: calendarType,
    );
  }

  GSField.time({
    super.key,
    required String tag,
    String? title,
    String? errorMessage,
    String? helpMessage,
    Widget? prefixWidget,
    Widget? postfixWidget,
    bool? required,
    GSFieldStatusEnum? status,
    int? weight,
    String? hint,
    TimeOfDay? initialTime,
    Function(TimeOfDay?)? onChanged,
  }) {
    model = GSTimePickerModel(
      type: GSFieldTypeEnum.time,
      tag: tag,
      title: title,
      errorMessage: errorMessage,
      helpMessage: helpMessage,
      prefixWidget: prefixWidget,
      postfixWidget: postfixWidget,
      required: required,
      status: status,
      weight: weight,
      hint: hint,
      initialTime: initialTime,
      timePickerType: TimePickerType.english,
    );
    onTimeChange = onChanged;
  }

  GSField.email({
    super.key,
    required String tag,
    String? title,
    String? errorMessage,
    String? helpMessage,
    Widget? prefixWidget,
    Widget? postfixWidget,
    bool? required,
    GSFieldStatusEnum? status,
    String? value,
    int? weight,
    int? maxLength,
    String? hint,
    bool? readOnly,
  }) {
    model = GSEmailModel(
      type: GSFieldTypeEnum.email,
      tag: tag,
      title: title,
      errorMessage: errorMessage,
      helpMessage: helpMessage,
      prefixWidget: prefixWidget,
      postfixWidget: postfixWidget,
      required: required,
      status: status,
      value: value,
      weight: weight,
      maxLength: maxLength,
      hint: hint,
      enableReadOnly: readOnly,
    );
  }

  GSField.price({
    super.key,
    required String tag,
    String? title,
    String? errorMessage,
    String? helpMessage,
    Widget? prefixWidget,
    String? currencyName,
    bool? required,
    GSFieldStatusEnum? status,
    String? value,
    int? weight,
    int? maxLength,
    String? hint,
    bool? readOnly,
  }) {
    model = GSPriceModel(
      type: GSFieldTypeEnum.price,
      tag: tag,
      title: title,
      errorMessage: errorMessage,
      helpMessage: helpMessage,
      prefixWidget: prefixWidget,
      postfixWidget: currencyName != null ? Text(currencyName) : null,
      required: required,
      status: status,
      value: value,
      weight: weight,
      maxLength: maxLength,
      hint: hint,
      enableReadOnly: readOnly,
    );
  }

  GSField.bankCard({
    super.key,
    required String tag,
    String? title,
    String? errorMessage,
    String? helpMessage,
    Widget? prefixWidget,
    Widget? postfixWidget,
    bool? required,
    GSFieldStatusEnum? status,
    String? value,
    int? weight,
    String? hint,
  }) {
    model = GSBankCardModel(
      type: GSFieldTypeEnum.bankCard,
      tag: tag,
      title: title,
      errorMessage: errorMessage,
      helpMessage: helpMessage,
      prefixWidget: prefixWidget,
      postfixWidget: postfixWidget,
      required: required,
      status: status,
      value: value,
      weight: weight,
      hint: hint,
    );
  }

  //</editor-fold>

  @override
  State<GSField> createState() => _GSFieldState();
}

class _GSFieldState extends State<GSField> {
  @override
  void didUpdateWidget(covariant GSField oldWidget) {
    // Recreate child with new model (which may have updated status/error)
    // Each child's didUpdateWidget will preserve its own state (selected values, etc.)
    _fillChild();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _fillChild();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.onUpdate = () {
      if (mounted) {
        if (widget.model?.status != GSFieldStatusEnum.disabled) {
          // Just trigger rebuild without recreating child to preserve field state
          setState(() {});
        }
      }
    };

    return AbsorbPointer(
      absorbing: widget.model?.status == GSFieldStatusEnum.disabled,
      child: Opacity(
        opacity: widget.model?.status == GSFieldStatusEnum.disabled ? 0.5 : 1.0,
        child: widget.child ?? const SizedBox.shrink(),
      ),
    );
  }

  void _fillChild() {
    switch (widget.model?.type) {
      case GSFieldTypeEnum.text:
        widget.child = GSTextField(
          widget.model as GSTextModel,
          widget.onChange,
        );
        break;
      case GSFieldTypeEnum.number:
        widget.child = GSNumberField(widget.model as GSNumberModel);
        break;
      case GSFieldTypeEnum.textPlain:
        widget.child = GSTextPlainField(
          widget.model as GSTextPlainModel,
          widget.onChange,
        );
        break;
      case GSFieldTypeEnum.mobile:
        widget.child = GSMobileField(widget.model as GSMobileModel);
        break;
      case GSFieldTypeEnum.password:
        widget.child = GSPasswordField(widget.model as GSPasswordModel);
        break;
      case GSFieldTypeEnum.date:
        widget.child = GSDatePickerField(
          widget.model as GSDatePickerModel,
          widget.onDateChange,
        );
        break;
      case GSFieldTypeEnum.dateRage:
        widget.child = GSDateRangePickerField(
          widget.model as GSDateRangePickerModel,
        );
        break;
      case GSFieldTypeEnum.time:
        widget.child = GSTimePickerField(
          widget.model as GSTimePickerModel,
          widget.onTimeChange,
        );
        break;
      case GSFieldTypeEnum.email:
        widget.child = GSEmailField(widget.model as GSEmailModel);
        break;
      case GSFieldTypeEnum.price:
        widget.child = GSPriceField(widget.model as GSPriceModel);
        break;
      case GSFieldTypeEnum.bankCard:
        widget.child = GSBankCardField(widget.model as GSBankCardModel);
        break;
      case GSFieldTypeEnum.spinner:
        widget.child = GSSpinnerField(widget.model as GSSpinnerModel);
        break;
      case GSFieldTypeEnum.radioGroup:
        widget.child = GSRadioGroupField(widget.model as GSRadioModel);
        break;
      case GSFieldTypeEnum.checkList:
        widget.child = GSCheckListField(widget.model as GSCheckBoxModel);
        break;
      case GSFieldTypeEnum.imagePicker:
        widget.child = GSImagePickerField(
          widget.model as GSImagePickerModel,
          widget.onChange,
        );
        break;
      case GSFieldTypeEnum.qrScanner:
        widget.child = GSQRScannerField(widget.model as GSQRScannerModel);
        break;
      case GSFieldTypeEnum.multiImagePicker:
        widget.child = GSMultiImagePickerField(
          widget.model as GSMultiImagePickerModel,
          widget.onArrayChange,
        );
        break;
      default:
        widget.child = const SizedBox.shrink();
    }
  }
}
