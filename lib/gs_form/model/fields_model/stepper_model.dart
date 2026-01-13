import 'package:flutter/cupertino.dart';
import 'package:gsform/gs_form/model/fields_model/field_model.dart';

class GSStepperModel extends GSFieldModel {
  String? hint;
  String? prefix;
  String? suffix;
  double? minValue;
  double? maxValue;
  double? step;
  bool? allowDecimal;
  bool? allowNegative;

  GSStepperModel({
    type,
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
    this.hint,
    this.prefix,
    this.suffix,
    this.minValue,
    this.maxValue,
    this.step,
    this.allowDecimal,
    this.allowNegative,
  }) : super(
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
