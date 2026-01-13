import 'package:flutter/cupertino.dart';
import 'package:gsform/gs_form/model/fields_model/field_model.dart';

/// Data model for individual button options in a button group
class ButtonGroupItem {
  final String label;
  final dynamic data;
  bool isSelected;

  ButtonGroupItem({
    required this.label,
    this.data,
    this.isSelected = false,
  });
}

class GSButtonGroupModel extends GSFieldModel {
  List<ButtonGroupItem> items;
  bool allowDeselect;

  GSButtonGroupModel({
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
    required this.items,
    this.allowDeselect = false,
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
