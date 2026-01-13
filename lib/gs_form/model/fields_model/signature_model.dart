import 'package:flutter/material.dart';
import 'package:gsform/gs_form/enums/filed_type.dart';
import 'package:gsform/gs_form/model/fields_model/field_model.dart';

class GSSignatureModel extends GSFieldModel {
  double? height;
  Color? penColor;
  double? penStrokeWidth;
  Color? backgroundColor;
  String? clearButtonText;
  bool? showClearButton;

  GSSignatureModel({
    required super.tag,
    this.height,
    this.penColor,
    this.penStrokeWidth,
    this.backgroundColor,
    this.clearButtonText,
    this.showClearButton,
    super.title,
    super.errorMessage,
    super.helpMessage,
    super.required,
    super.status,
    super.weight,
    super.showTitle,
    super.prefixWidget,
    super.postfixWidget,
    super.enableReadOnly,
  });

  @override
  GSFieldTypeEnum get type => GSFieldTypeEnum.signature;
}
