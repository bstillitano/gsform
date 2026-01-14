import 'package:flutter/cupertino.dart';

import 'field_model.dart';

class GSRichTextModel extends GSFieldModel {
  String? hint;
  double? height;
  bool? showToolbar;

  GSRichTextModel({
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
    enableReadOnly,
    weight,
    showTitle,
    onTap,
    this.hint,
    this.height,
    this.showToolbar,
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
