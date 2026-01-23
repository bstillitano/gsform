import 'package:flutter/material.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/enums/field_status.dart';

import 'field.dart';
import 'section.dart';

/// A form widget that organizes fields into sections.
///
/// Use [GSForm.singleSection] for forms with a flat list of fields,
/// or [GSForm.multiSection] for forms with multiple grouped sections.
///
/// The form automatically adapts to light/dark mode using Material's [ThemeData].
/// You can customize appearance via the standard [ThemeData.inputDecorationTheme],
/// [ThemeData.cardTheme], and [ThemeData.textTheme].
class GSForm extends StatefulWidget {
  final List<GSSection> sections;

  /// Padding around the form content.
  final EdgeInsetsGeometry? padding;

  const GSForm._({
    super.key,
    required this.sections,
    this.padding,
  });

  /// Creates a form with a single section containing the given fields.
  ///
  /// This is a convenience constructor for simple forms that don't need
  /// multiple sections. The fields will be displayed without a section title.
  factory GSForm.singleSection(
    BuildContext context, {
    Key? key,
    required List<Widget> fields,
    @Deprecated('Use KeyboardDoneButton widget instead') bool enableKeyboardActions = false,
    Color? keyboardBarColor,
    EdgeInsetsGeometry? padding,
  }) {
    return GSForm._(
      key: key,
      sections: [
        GSSection(
          sectionTitle: null,
          fields: fields,
        ),
      ],
      padding: padding,
    );
  }

  /// Creates a form with multiple sections.
  ///
  /// Each section can have its own title and list of fields.
  factory GSForm.multiSection(
    BuildContext context, {
    Key? key,
    required List<GSSection> sections,
    @Deprecated('Use KeyboardDoneButton widget instead') bool enableKeyboardActions = false,
    Color? keyboardBarColor,
    EdgeInsetsGeometry? padding,
  }) {
    return GSForm._(
      key: key,
      sections: sections,
      padding: padding,
    );
  }

  @override
  State<GSForm> createState() => _GSFormState();

  /// Validates all fields in the form.
  ///
  /// Returns `true` if all required fields have valid values.
  /// Updates the status of each field to show validation errors.
  bool isValid() {
    bool isValid = true;
    for (var section in sections) {
      for (var field in section.fields) {
        if (field is GSField) {
          bool fieldValidation = (field.child as GSFieldCallBack).isValid();
          field.model?.status =
              fieldValidation ? GSFieldStatusEnum.success : GSFieldStatusEnum.error;
          isValid = isValid && fieldValidation;
          field.update();
        }
      }
    }
    return isValid;
  }

  /// Collects all field values into a map.
  ///
  /// The map keys are the field tags, and values are the field values.
  Map<String, dynamic> onSubmit() {
    Map<String, dynamic> data = {};
    for (var section in sections) {
      for (var field in section.fields) {
        if (field is GSField) {
          data[field.model?.tag ?? ''] = (field.child as GSFieldCallBack).getValue();
        }
      }
    }
    return data;
  }
}

class _GSFormState extends State<GSForm> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: widget.padding,
      itemCount: widget.sections.length,
      separatorBuilder: (context, index) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final section = widget.sections[index];
        return GSSection(
          sectionTitle: section.sectionTitle,
          fields: section.fields,
        );
      },
    );
  }
}
