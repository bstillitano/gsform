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

/// InheritedWidget that allows GSFields to register their focus nodes
class GSFormScope extends InheritedWidget {
  final void Function(FocusNode node, GSFieldTypeEnum type)? registerFocusNode;

  const GSFormScope({
    super.key,
    required super.child,
    this.registerFocusNode,
  });

  static GSFormScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GSFormScope>();
  }

  @override
  bool updateShouldNotify(GSFormScope oldWidget) => false;
}

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
  final List<FocusNode> _registeredFocusNodes = [];
  final List<FocusNode> _managedFocusNodes = [];
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant GSForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sections != widget.sections) {
      // Clear registered nodes - they'll re-register on rebuild
      _registeredFocusNodes.clear();
      _managedFocusNodes.clear();
      _isFirstBuild = true;
    }
  }

  @override
  void dispose() {
    for (final node in _managedFocusNodes) {
      node.dispose();
    }
    _managedFocusNodes.clear();
    super.dispose();
  }

  void _registerFocusNode(FocusNode node, GSFieldTypeEnum type) {
    if (_keyboardFieldTypes.contains(type) && !_registeredFocusNodes.contains(node)) {
      _registeredFocusNodes.add(node);
      // Schedule rebuild after first build completes to update KeyboardActions
      if (_isFirstBuild) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _isFirstBuild) {
            _isFirstBuild = false;
            setState(() {});
          }
        });
      }
    }
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
    // Clear registered nodes at start of each build - they'll re-register
    _registeredFocusNodes.clear();

    // Wrap content with GSFormScope so fields can register
    final content = GSFormScope(
      registerFocusNode: widget.enableKeyboardActions ? _registerFocusNode : null,
      child: _buildFormContent(),
    );

    if (!widget.enableKeyboardActions) {
      return content;
    }

    // On first build, we don't have focus nodes yet - they register during build
    // After first build, we rebuild with the registered focus nodes
    if (_isFirstBuild || _registeredFocusNodes.isEmpty) {
      return content;
    }

    return KeyboardActions(
      config: KeyboardActionsConfig(
        keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
        keyboardBarColor: widget.keyboardBarColor ?? Theme.of(context).colorScheme.surface,
        nextFocus: true,
        actions: _registeredFocusNodes.map((node) {
          return KeyboardActionsItem(
            focusNode: node,
            displayArrows: true,
            displayDoneButton: true,
          );
        }).toList(),
      ),
      autoScroll: true,
      disableScroll: false,
      child: content,
    );
  }
}
