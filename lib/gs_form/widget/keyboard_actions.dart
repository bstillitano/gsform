import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

/// A wrapper widget that adds a keyboard actions bar to text inputs.
///
/// This widget adds a "Done" button above the keyboard for numeric and other
/// keyboard types that don't have a built-in dismiss button (common on iOS).
///
/// It also supports navigation between fields using up/down arrows.
///
/// Example usage:
/// ```dart
/// final _focusNode1 = FocusNode();
/// final _focusNode2 = FocusNode();
///
/// GSKeyboardActions(
///   focusNodes: [_focusNode1, _focusNode2],
///   child: Column(
///     children: [
///       GSField.number(
///         tag: 'field1',
///         focusNode: _focusNode1,
///       ),
///       GSField.number(
///         tag: 'field2',
///         focusNode: _focusNode2,
///       ),
///     ],
///   ),
/// )
/// ```
class GSKeyboardActions extends StatelessWidget {
  /// The focus nodes for the text fields that should have keyboard actions.
  ///
  /// These should match the focus nodes passed to your form fields.
  final List<FocusNode> focusNodes;

  /// The child widget (typically a form or column of fields).
  final Widget child;

  /// Whether to auto-scroll to the focused field.
  ///
  /// Defaults to `true`.
  final bool autoScroll;

  /// Custom keyboard actions bar color.
  ///
  /// If null, uses the platform default.
  final Color? barColor;

  /// Whether to enable navigation arrows between fields.
  ///
  /// Defaults to `true`.
  final bool enableNavigation;

  /// Custom actions for specific focus nodes.
  ///
  /// Use this if you need custom toolbar buttons or footers for specific fields.
  /// If provided, these will be used instead of the default actions.
  final List<KeyboardActionsItem>? customActions;

  /// Keyboard actions platform to show the bar on.
  ///
  /// Defaults to [KeyboardActionsPlatform.ALL].
  final KeyboardActionsPlatform keyboardActionsPlatform;

  /// Custom bottom padding when keyboard is visible.
  final double? keyboardBarElevation;

  /// Whether to disable scrolling.
  ///
  /// If you're using GSKeyboardActions for just one field and don't need
  /// content scrolling, set this to true.
  final bool disableScroll;

  /// A custom widget to use instead of the default "Done" button.
  final Widget? doneWidget;

  const GSKeyboardActions({
    super.key,
    required this.focusNodes,
    required this.child,
    this.autoScroll = true,
    this.barColor,
    this.enableNavigation = true,
    this.customActions,
    this.keyboardActionsPlatform = KeyboardActionsPlatform.ALL,
    this.keyboardBarElevation,
    this.disableScroll = false,
    this.doneWidget,
  });

  @override
  Widget build(BuildContext context) {
    final actions = customActions ??
        focusNodes.map((node) {
          return KeyboardActionsItem(
            focusNode: node,
            displayArrows: enableNavigation,
            displayDoneButton: true,
          );
        }).toList();

    return KeyboardActions(
      config: KeyboardActionsConfig(
        keyboardActionsPlatform: keyboardActionsPlatform,
        keyboardBarColor: barColor ?? Theme.of(context).colorScheme.surface,
        keyboardBarElevation: keyboardBarElevation,
        nextFocus: enableNavigation,
        actions: actions,
        defaultDoneWidget: doneWidget,
      ),
      autoScroll: autoScroll,
      disableScroll: disableScroll,
      child: child,
    );
  }
}

/// Extension to create keyboard actions items easily from focus nodes.
extension FocusNodeKeyboardActions on FocusNode {
  /// Creates a [KeyboardActionsItem] for this focus node.
  KeyboardActionsItem toKeyboardActionsItem({
    bool displayArrows = true,
    bool displayDoneButton = true,
    List<Widget>? toolbarButtons,
    PreferredSizeWidget Function(BuildContext)? footerBuilder,
  }) {
    return KeyboardActionsItem(
      focusNode: this,
      displayArrows: displayArrows,
      displayDoneButton: displayDoneButton,
      toolbarButtons: toolbarButtons != null
          ? toolbarButtons.map((btn) => (node) => btn).toList()
          : null,
      footerBuilder: footerBuilder,
    );
  }
}
