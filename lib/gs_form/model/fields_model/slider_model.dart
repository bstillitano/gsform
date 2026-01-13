import 'package:gsform/gs_form/enums/filed_type.dart';
import 'package:gsform/gs_form/model/fields_model/field_model.dart';

class GSSliderModel extends GSFieldModel {
  double? minValue;
  double? maxValue;
  double? step;
  double? initialValue;
  bool? showLabels;
  bool? showValueField;
  String? minLabel;
  String? midLabel;
  String? maxLabel;

  GSSliderModel({
    required super.tag,
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
    this.minValue,
    this.maxValue,
    this.step,
    this.initialValue,
    this.showLabels,
    this.showValueField,
    this.minLabel,
    this.midLabel,
    this.maxLabel,
  });

  @override
  GSFieldTypeEnum get type => GSFieldTypeEnum.slider;
}
