import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/enums/field_status.dart';
import 'package:gsform/gs_form/enums/filed_type.dart';

import 'field.dart';
import 'section.dart';

/// Field types that show a keyboard and need keyboard actions.
const _keyboardFieldTypes = {
  GSFieldTypeEnum.text,
  GSFieldTypeEnum.textPlain,
  GSFieldTypeEnum.number,
  GSFieldTypeEnum.mobile,
  GSFieldTypeEnum.email,
  GSFieldTypeEnum.password,
  GSFieldTypeEnum.price,
  GSFieldTypeEnum.bankCard,
  GSFieldTypeEnum.stepper,
  GSFieldTypeEnum.slider,
};

/// A form widget that organizes fields into sections.
///
/// Use [GSForm.singleSection] for forms with a flat list of fields,
/// or [GSForm.multiSection] for forms with multiple grouped sections.
///
/// The form automatically adapts to light/dark mode using Material's [ThemeData].
/// You can customize appearance via the standard [ThemeData.inputDecorationTheme],
/// [ThemeData.cardTheme], and [ThemeData.textTheme].
///
/// By default, a keyboard actions bar with a "Done" button is shown above the
/// keyboard for all text input fields. This can be disabled by setting
/// [enableKeyboardActions] to `false`.
///
/// **Important**: When using keyboard actions (the default), do NOT wrap GSForm
/// in a ScrollView. GSForm handles its own scrolling. If you need to disable
/// this behavior, set [enableKeyboardActions] to `false`.
class GSForm extends StatefulWidget {
  final List<GSSection> sections;

  /// Whether to show a keyboard actions bar with a "Done" button.
  ///
  /// Defaults to `true`. This is especially useful on iOS where numeric
  /// keyboards don't have a built-in dismiss button.
  ///
  /// When enabled, GSForm handles scrolling internally - do not wrap it
  /// in a ScrollView.
  final bool enableKeyboardActions;

  /// Color of the keyboard actions bar.
  ///
  /// If null, uses the theme's surface color.
  final Color? keyboardBarColor;

  /// Padding around the form content.
  final EdgeInsetsGeometry? padding;

  const GSForm._({
    super.key,
    required this.sections,
    this.enableKeyboardActions = true,
    this.keyboardBarColor,
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
    bool enableKeyboardActions = true,
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
      enableKeyboardActions: enableKeyboardActions,
      keyboardBarColor: keyboardBarColor,
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
    bool enableKeyboardActions = true,
    Color? keyboardBarColor,
    EdgeInsetsGeometry? padding,
  }) {
    return GSForm._(
      key: key,
      sections: sections,
      enableKeyboardActions: enableKeyboardActions,
      keyboardBarColor: keyboardBarColor,
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
  final List<FocusNode> _managedFocusNodes = [];
  bool _focusNodesSetup = false;

  @override
  void initState() {
    super.initState();
    _setupFocusNodes();
  }

  @override
  void didUpdateWidget(covariant GSForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-setup focus nodes if sections changed
    if (oldWidget.sections != widget.sections) {
      _disposeFocusNodes();
      _setupFocusNodes();
    }
  }

  @override
  void dispose() {
    _disposeFocusNodes();
    super.dispose();
  }

  void _disposeFocusNodes() {
    for (final node in _managedFocusNodes) {
      node.dispose();
    }
    _managedFocusNodes.clear();
    _focusNodesSetup = false;
  }

  void _setupFocusNodes() {
    if (!widget.enableKeyboardActions || _focusNodesSetup) return;

    // Collect all keyboard fields in order
    final keyboardFields = <GSField>[];
    for (var section in widget.sections) {
      for (var field in section.fields) {
        if (field is GSField &&
            field.model != null &&
            _keyboardFieldTypes.contains(field.model!.type)) {
          keyboardFields.add(field);
        }
      }
    }

    // Create focus nodes for fields that don't have one and chain them
    for (int i = 0; i < keyboardFields.length; i++) {
      final field = keyboardFields[i];
      final model = field.model!;

      // Create focus node if not provided
      if (model.focusNode == null) {
        final node = FocusNode();
        _managedFocusNodes.add(node);
        model.focusNode = node;
      }

      // Set next focus node if not already set and there's a next field
      if (model.nextFocusNode == null && i < keyboardFields.length - 1) {
        final nextField = keyboardFields[i + 1];
        // Ensure next field has a focus node
        if (nextField.model!.focusNode == null) {
          final node = FocusNode();
          _managedFocusNodes.add(node);
          nextField.model!.focusNode = node;
        }
        model.nextFocusNode = nextField.model!.focusNode;
      }
    }

    _focusNodesSetup = true;
  }

  List<FocusNode> _collectFocusNodes() {
    final focusNodes = <FocusNode>[];
    for (var section in widget.sections) {
      for (var field in section.fields) {
        if (field is GSField &&
            field.model != null &&
            _keyboardFieldTypes.contains(field.model!.type) &&
            field.model!.focusNode != null) {
          focusNodes.add(field.model!.focusNode!);
        }
      }
    }
    return focusNodes;
  }

  Widget _buildFormContent() {
    return ListView.separated(
      shrinkWrap: true,
      physics: widget.enableKeyboardActions
          ? const ClampingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
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

  @override
  Widget build(BuildContext context) {
    if (!widget.enableKeyboardActions) {
      return _buildFormContent();
    }

    final focusNodes = _collectFocusNodes();
    if (focusNodes.isEmpty) {
      return _buildFormContent();
    }

    return KeyboardActions(
      config: KeyboardActionsConfig(
        keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
        keyboardBarColor: widget.keyboardBarColor ?? Theme.of(context).colorScheme.surface,
        nextFocus: true,
        actions: focusNodes.map((node) {
          return KeyboardActionsItem(
            focusNode: node,
            displayArrows: true,
            displayDoneButton: true,
          );
        }).toList(),
      ),
      autoScroll: true,
      disableScroll: false,
      child: _buildFormContent(),
    );
  }
}
