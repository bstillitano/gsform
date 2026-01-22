import 'package:flutter/cupertino.dart';
import 'package:gsform/gs_form/model/fields_model/field_model.dart';

class GSEmailModel extends GSFieldModel {
  int? maxLength;

  String? hint;

  GSEmailModel(
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
      maxLength,
      weight,
      FocusNode? focusNode,
      FocusNode? nextFocusNode,
      showTitle,
      enableReadOnly,
      onTap,
      this.hint})
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
          focusNode: focusNode,
          nextFocusNode: nextFocusNode,
          showTitle: showTitle,
          enableReadOnly: enableReadOnly,
          onTap: onTap,
        );
}
