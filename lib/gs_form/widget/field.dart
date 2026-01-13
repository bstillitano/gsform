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
import 'package:gsform/gs_form/model/fields_model/stepper_model.dart';
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
import 'package:gsform/gs_form/widget/fields/stepper_field.dart';
import 'package:gsform/gs_form/widget/fields/star_rating_field.dart';
import 'package:gsform/gs_form/model/fields_model/star_rating_model.dart';
import 'package:gsform/gs_form/widget/fields/button_group_field.dart';
import 'package:gsform/gs_form/model/fields_model/button_group_model.dart';
import 'package:gsform/gs_form/enums/required_check_list_enum.dart';
import 'package:gsform/gs_form/widget/fields/slider_field.dart';
import 'package:gsform/gs_form/model/fields_model/slider_model.dart';
import 'package:gsform/gs_form/widget/fields/chip_select_field.dart';
import 'package:gsform/gs_form/model/fields_model/chip_select_model.dart';
import 'package:gsform/gs_form/widget/fields/signature_field.dart';
import 'package:gsform/gs_form/model/fields_model/signature_model.dart';
import 'dart:typed_data';

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
  Function(double)? onSliderChange;
  Function(List<ChipSelectItem>)? onChipSelectChange;
  Function(Uint8List?)? onSignatureChange;
  Function(ButtonGroupItem?)? onButtonGroupChange;

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
    bool? allowDecimal,
    bool? allowNegative,
    double? minValue,
    double? maxValue,
    Function(String?)? onChanged,
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
      allowDecimal: allowDecimal,
      allowNegative: allowNegative,
      minValue: minValue,
      maxValue: maxValue,
    );
    onChange = onChanged;
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

  GSField.stepper({
    super.key,
    required String tag,
    String? title,
    String? errorMessage,
    String? helpMessage,
    bool? required,
    GSFieldStatusEnum? status,
    dynamic value,
    int? weight,
    String? hint,
    String? prefix,
    String? suffix,
    double? minValue,
    double? maxValue,
    double? step,
    bool? allowDecimal,
    bool? allowNegative,
    bool? readOnly,
    Function(String?)? onChanged,
  }) {
    model = GSStepperModel(
      type: GSFieldTypeEnum.stepper,
      tag: tag,
      title: title,
      errorMessage: errorMessage,
      helpMessage: helpMessage,
      required: required,
      status: status,
      value: value,
      weight: weight,
      hint: hint,
      prefix: prefix,
      suffix: suffix,
      minValue: minValue,
      maxValue: maxValue,
      step: step,
      allowDecimal: allowDecimal,
      allowNegative: allowNegative,
      enableReadOnly: readOnly,
    );
    onChange = onChanged;
  }

  GSField.starRating({
    super.key,
    required String tag,
    String? title,
    String? errorMessage,
    String? helpMessage,
    bool? required,
    GSFieldStatusEnum? status,
    dynamic value,
    int? weight,
    int maximumRate = 5,
    double? starSize,
    String? leftText,
    String? rightText,
    bool? readOnly,
    Function(String?)? onChanged,
  }) {
    model = GSStarRatingModel(
      type: GSFieldTypeEnum.starRating,
      tag: tag,
      title: title,
      errorMessage: errorMessage,
      helpMessage: helpMessage,
      required: required,
      status: status,
      value: value,
      weight: weight,
      maximumRate: maximumRate,
      starSize: starSize,
      leftText: leftText,
      rightText: rightText,
      enableReadOnly: readOnly,
    );
    onChange = onChanged;
  }

  GSField.buttonGroup({
    super.key,
    required String tag,
    String? title,
    String? errorMessage,
    String? helpMessage,
    bool? required,
    GSFieldStatusEnum? status,
    String? value,
    int? weight,
    required List<ButtonGroupItem> items,
    bool allowDeselect = false,
    bool? readOnly,
    Function(ButtonGroupItem?)? onChanged,
  }) {
    model = GSButtonGroupModel(
      type: GSFieldTypeEnum.buttonGroup,
      tag: tag,
      title: title,
      errorMessage: errorMessage,
      helpMessage: helpMessage,
      required: required,
      status: status,
      value: value,
      weight: weight,
      items: items,
      allowDeselect: allowDeselect,
      enableReadOnly: readOnly,
    );
    onButtonGroupChange = onChanged;
  }

  GSField.slider({
    super.key,
    required String tag,
    String? title,
    String? errorMessage,
    String? helpMessage,
    bool? required,
    GSFieldStatusEnum? status,
    int? weight,
    double? minValue,
    double? maxValue,
    double? step,
    double? initialValue,
    bool? showLabels,
    bool? showValueField,
    String? minLabel,
    String? midLabel,
    String? maxLabel,
    bool? readOnly,
    Function(double)? onChanged,
  }) {
    model = GSSliderModel(
      tag: tag,
      title: title,
      errorMessage: errorMessage,
      helpMessage: helpMessage,
      required: required,
      status: status,
      weight: weight,
      minValue: minValue,
      maxValue: maxValue,
      step: step,
      initialValue: initialValue,
      showLabels: showLabels,
      showValueField: showValueField,
      minLabel: minLabel,
      midLabel: midLabel,
      maxLabel: maxLabel,
      enableReadOnly: readOnly,
    );
    onSliderChange = onChanged;
  }

  GSField.chipSelect({
    super.key,
    required String tag,
    required List<ChipSelectItem> items,
    String? title,
    String? errorMessage,
    String? helpMessage,
    bool? required,
    GSFieldStatusEnum? status,
    int? weight,
    bool multiSelect = false,
    bool wrap = true,
    bool searchable = false,
    String? searchHint,
    bool? readOnly,
    Function(List<ChipSelectItem>)? onChanged,
  }) {
    model = GSChipSelectModel(
      tag: tag,
      items: items,
      title: title,
      errorMessage: errorMessage,
      helpMessage: helpMessage,
      required: required,
      status: status,
      weight: weight,
      multiSelect: multiSelect,
      wrap: wrap,
      searchable: searchable,
      searchHint: searchHint,
      enableReadOnly: readOnly,
    );
    onChipSelectChange = onChanged;
  }

  GSField.signature({
    super.key,
    required String tag,
    String? title,
    String? errorMessage,
    String? helpMessage,
    bool? required,
    GSFieldStatusEnum? status,
    int? weight,
    double? height,
    Color? penColor,
    double? penStrokeWidth,
    Color? backgroundColor,
    String? clearButtonText,
    bool? showClearButton,
    Uint8List? backgroundImageBytes,
    bool? readOnly,
    Function(Uint8List?)? onChanged,
  }) {
    model = GSSignatureModel(
      tag: tag,
      title: title,
      errorMessage: errorMessage,
      helpMessage: helpMessage,
      required: required,
      status: status,
      weight: weight,
      height: height,
      penColor: penColor,
      penStrokeWidth: penStrokeWidth,
      backgroundColor: backgroundColor,
      clearButtonText: clearButtonText,
      showClearButton: showClearButton,
      backgroundImageBytes: backgroundImageBytes,
      enableReadOnly: readOnly,
    );
    onSignatureChange = onChanged;
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
          // Recreate child with updated model (e.g., error status from validation)
          // Child's didUpdateWidget will preserve its state (entered text, selections)
          _fillChild();
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
        final oldText = widget.child;
        final newText = GSTextField(widget.model as GSTextModel, widget.onChange);
        if (oldText is GSTextField) {
          newText.controller = oldText.controller;
        }
        widget.child = newText;
        break;
      case GSFieldTypeEnum.number:
        final oldNumber = widget.child;
        final newNumber = GSNumberField(
          widget.model as GSNumberModel,
          widget.onChange,
        );
        if (oldNumber is GSNumberField) {
          newNumber.controller = oldNumber.controller;
        }
        widget.child = newNumber;
        break;
      case GSFieldTypeEnum.textPlain:
        final oldTextPlain = widget.child;
        final newTextPlain = GSTextPlainField(
          widget.model as GSTextPlainModel,
          widget.onChange,
        );
        if (oldTextPlain is GSTextPlainField) {
          newTextPlain.controller = oldTextPlain.controller;
        }
        widget.child = newTextPlain;
        break;
      case GSFieldTypeEnum.mobile:
        final oldMobile = widget.child;
        final newMobile = GSMobileField(widget.model as GSMobileModel);
        if (oldMobile is GSMobileField) {
          newMobile.controller = oldMobile.controller;
        }
        widget.child = newMobile;
        break;
      case GSFieldTypeEnum.password:
        final oldPassword = widget.child;
        final newPassword = GSPasswordField(widget.model as GSPasswordModel);
        if (oldPassword is GSPasswordField) {
          newPassword.controller = oldPassword.controller;
          newPassword.obscured = oldPassword.obscured;
        }
        widget.child = newPassword;
        break;
      case GSFieldTypeEnum.date:
        final oldDate = widget.child;
        final newDate = GSDatePickerField(
          widget.model as GSDatePickerModel,
          widget.onDateChange,
        );
        if (oldDate is GSDatePickerField) {
          newDate.selectedGregorianDate = oldDate.selectedGregorianDate;
          newDate.selectedDateText = oldDate.selectedDateText;
          newDate.isDateSelected = oldDate.isDateSelected;
        }
        widget.child = newDate;
        break;
      case GSFieldTypeEnum.dateRage:
        final oldDateRange = widget.child;
        final newDateRange = GSDateRangePickerField(
          widget.model as GSDateRangePickerModel,
        );
        if (oldDateRange is GSDateRangePickerField) {
          newDateRange.selectedGregorianStartDate = oldDateRange.selectedGregorianStartDate;
          newDateRange.selectedGregorianEndDate = oldDateRange.selectedGregorianEndDate;
          newDateRange.selectedDateText = oldDateRange.selectedDateText;
          newDateRange.isDateSelected = oldDateRange.isDateSelected;
        }
        widget.child = newDateRange;
        break;
      case GSFieldTypeEnum.time:
        final oldTime = widget.child;
        final newTime = GSTimePickerField(
          widget.model as GSTimePickerModel,
          widget.onTimeChange,
        );
        if (oldTime is GSTimePickerField) {
          newTime.selectedTime = oldTime.selectedTime;
          newTime.selectedTimeText = oldTime.selectedTimeText;
          newTime.isTimeSelected = oldTime.isTimeSelected;
        }
        widget.child = newTime;
        break;
      case GSFieldTypeEnum.email:
        final oldEmail = widget.child;
        final newEmail = GSEmailField(widget.model as GSEmailModel);
        if (oldEmail is GSEmailField) {
          newEmail.controller = oldEmail.controller;
        }
        widget.child = newEmail;
        break;
      case GSFieldTypeEnum.price:
        final oldPrice = widget.child;
        final newPrice = GSPriceField(widget.model as GSPriceModel);
        if (oldPrice is GSPriceField) {
          newPrice.controller = oldPrice.controller;
        }
        widget.child = newPrice;
        break;
      case GSFieldTypeEnum.bankCard:
        final oldBankCard = widget.child;
        final newBankCard = GSBankCardField(widget.model as GSBankCardModel);
        if (oldBankCard is GSBankCardField) {
          newBankCard.controller = oldBankCard.controller;
        }
        widget.child = newBankCard;
        break;
      case GSFieldTypeEnum.spinner:
        final oldSpinner = widget.child;
        final newSpinner = GSSpinnerField(widget.model as GSSpinnerModel);
        // Immediately transfer state before build cycle
        if (oldSpinner is GSSpinnerField) {
          newSpinner.returnedData = oldSpinner.returnedData;
        }
        widget.child = newSpinner;
        break;
      case GSFieldTypeEnum.radioGroup:
        final oldRadio = widget.child;
        final newRadio = GSRadioGroupField(widget.model as GSRadioModel);
        if (oldRadio is GSRadioGroupField) {
          newRadio.returnedData = oldRadio.returnedData;
          newRadio.filteredItems = oldRadio.filteredItems;
          newRadio.keyword = oldRadio.keyword;
        }
        widget.child = newRadio;
        break;
      case GSFieldTypeEnum.checkList:
        widget.child = GSCheckListField(widget.model as GSCheckBoxModel);
        break;
      case GSFieldTypeEnum.imagePicker:
        final oldImagePicker = widget.child;
        final newImagePicker = GSImagePickerField(
          widget.model as GSImagePickerModel,
          widget.onChange,
        );
        if (oldImagePicker is GSImagePickerField) {
          newImagePicker.croppedFilePath = oldImagePicker.croppedFilePath;
        }
        widget.child = newImagePicker;
        break;
      case GSFieldTypeEnum.qrScanner:
        final oldQR = widget.child;
        final newQR = GSQRScannerField(widget.model as GSQRScannerModel);
        if (oldQR is GSQRScannerField) {
          newQR.scannedValue = oldQR.scannedValue;
        }
        widget.child = newQR;
        break;
      case GSFieldTypeEnum.multiImagePicker:
        final oldMultiImage = widget.child;
        final newMultiImage = GSMultiImagePickerField(
          widget.model as GSMultiImagePickerModel,
          widget.onArrayChange,
        );
        if (oldMultiImage is GSMultiImagePickerField) {
          newMultiImage.croppedFilePaths = oldMultiImage.croppedFilePaths;
        }
        widget.child = newMultiImage;
        break;
      case GSFieldTypeEnum.stepper:
        final oldStepper = widget.child;
        final newStepper = GSStepperField(
          widget.model as GSStepperModel,
          widget.onChange,
        );
        if (oldStepper is GSStepperField) {
          newStepper.controller = oldStepper.controller;
          newStepper.currentValue = oldStepper.currentValue;
        }
        widget.child = newStepper;
        break;
      case GSFieldTypeEnum.starRating:
        final oldStarRating = widget.child;
        final newStarRating = GSStarRatingField(
          widget.model as GSStarRatingModel,
          widget.onChange,
        );
        if (oldStarRating is GSStarRatingField) {
          newStarRating.currentRating = oldStarRating.currentRating;
        }
        widget.child = newStarRating;
        break;
      case GSFieldTypeEnum.buttonGroup:
        final oldButtonGroup = widget.child;
        final newButtonGroup = GSButtonGroupField(
          widget.model as GSButtonGroupModel,
          widget.onButtonGroupChange,
        );
        if (oldButtonGroup is GSButtonGroupField) {
          newButtonGroup.selectedIndex = oldButtonGroup.selectedIndex;
        }
        widget.child = newButtonGroup;
        break;
      case GSFieldTypeEnum.slider:
        final oldSlider = widget.child;
        final newSlider = GSSliderField(
          model: widget.model as GSSliderModel,
          onChanged: widget.onSliderChange,
        );
        if (oldSlider is GSSliderField) {
          newSlider.currentValue = oldSlider.currentValue;
        }
        widget.child = newSlider;
        break;
      case GSFieldTypeEnum.chipSelect:
        final oldChipSelect = widget.child;
        final newChipSelect = GSChipSelectField(
          model: widget.model as GSChipSelectModel,
          onChanged: widget.onChipSelectChange,
        );
        if (oldChipSelect is GSChipSelectField) {
          newChipSelect.selectedItems = oldChipSelect.selectedItems;
        }
        widget.child = newChipSelect;
        break;
      case GSFieldTypeEnum.signature:
        final oldSignature = widget.child;
        final newSignature = GSSignatureField(
          model: widget.model as GSSignatureModel,
          onChanged: widget.onSignatureChange,
        );
        if (oldSignature is GSSignatureField) {
          newSignature.signatureData = oldSignature.signatureData;
        }
        widget.child = newSignature;
        break;
      default:
        widget.child = const SizedBox.shrink();
    }
  }
}
