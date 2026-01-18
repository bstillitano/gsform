import 'package:flutter/cupertino.dart';

import 'field_model.dart';

class GSSwitchModel extends GSFieldModel {
  ValueChanged<bool>? onChange;

  GSSwitchModel({
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
    onTap,
    showTitle,
    this.onChange,
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
          value: value ?? false,
          validateRegEx: validateRegEx,
          weight: weight,
          showTitle: showTitle,
        );
}
