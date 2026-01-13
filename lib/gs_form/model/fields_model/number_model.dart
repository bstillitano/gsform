import 'package:flutter/cupertino.dart';
import 'package:gsform/gs_form/model/fields_model/field_model.dart';

class GSNumberModel extends GSFieldModel {
  int? maxLength;
  String? hint;
  bool? showCounter;
  bool? allowDecimal;
  bool? allowNegative;
  double? minValue;
  double? maxValue;

  GSNumberModel(
      {type,
      tag,
      title,
      errorMessage,
      helpMessage,
      prefixWidget,
      postfixWidget,
      required,
      status,
      value,
      validateRegEx,
      weight,
      focusNode,
      showTitle,
      enableReadOnly,
      onTap,
      this.showCounter,
      this.maxLength,
      this.hint,
      this.allowDecimal,
      this.allowNegative,
      this.minValue,
      this.maxValue})
      : super(
          type: type,
          tag: tag,
          title: title,
          errorMessage: errorMessage,
          helpMessage: helpMessage,
          prefixWidget: prefixWidget,
          postfixWidget: postfixWidget,
          required: required,
          status: status,
          value: value,
          validateRegEx: validateRegEx,
          weight: weight,
          focusNode: FocusNode(),
          showTitle: showTitle,
          enableReadOnly: enableReadOnly,
          onTap: onTap,
        );
}
