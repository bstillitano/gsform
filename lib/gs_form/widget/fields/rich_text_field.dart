import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/enums/field_status.dart';
import 'package:gsform/gs_form/model/fields_model/rich_text_model.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

class GSRichTextField extends StatefulWidget implements GSFieldCallBack {
  final GSRichTextModel model;
  final Function(String)? onChanged;

  QuillController? controller;

  GSRichTextField(this.model, this.onChanged, {super.key});

  @override
  State<GSRichTextField> createState() => _GSRichTextFieldState();

  @override
  getValue() {
    if (controller == null) return '';
    final delta = controller!.document.toDelta();
    final deltaJson = delta.toJson();
    final converter = QuillDeltaToHtmlConverter(
      List<Map<String, dynamic>>.from(deltaJson),
      ConverterOptions.forEmail(),
    );
    return converter.convert();
  }

  @override
  bool isValid() {
    final text = controller?.document.toPlainText().trim() ?? '';
    if (model.validateRegEx == null) {
      if (!(model.required ?? false)) {
        return true;
      } else {
        return text.isNotEmpty;
      }
    } else {
      return model.validateRegEx!.hasMatch(text);
    }
  }
}

class _GSRichTextFieldState extends State<GSRichTextField> {
  final FocusNode _editorFocusNode = FocusNode();

  @override
  void initState() {
    widget.controller ??= QuillController.basic();
    if (widget.model.value != null && widget.model.value is String) {
      _setHtmlContent(widget.model.value as String);
    }
    widget.controller?.readOnly = widget.model.enableReadOnly ?? false;
    widget.controller?.addListener(_onTextChanged);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    _editorFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onChanged?.call(widget.getValue());
  }

  void _setHtmlContent(String html) {
    if (html.isEmpty) return;
    // For initial value, we expect it to be either HTML or plain text
    // If it's plain text (no HTML tags), just insert it directly
    if (!html.contains('<') && !html.contains('>')) {
      widget.controller?.document = Document()..insert(0, html);
      return;
    }
    // For HTML, we'll need to parse it - for now just strip tags as a fallback
    // The proper way would be to use a HTML to Delta converter
    final plainText = html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '');
    if (plainText.isNotEmpty) {
      widget.controller?.document = Document()..insert(0, plainText);
    }
  }

  @override
  void didUpdateWidget(covariant GSRichTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model.value == widget.model.value) {
      widget.controller = oldWidget.controller;
    } else {
      widget.controller ??= QuillController.basic();
      if (widget.model.value != null) {
        _setHtmlContent(widget.model.value as String);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isError = widget.model.status == GSFieldStatusEnum.error;
    final isRequired = widget.model.required ?? false;
    final showToolbar = widget.model.showToolbar ?? true;
    final isReadOnly = widget.model.enableReadOnly ?? false;
    widget.controller?.readOnly = isReadOnly;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.model.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildLabel(widget.model.title!, isRequired),
          ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isError
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).dividerColor,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              if (showToolbar && !isReadOnly)
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: QuillSimpleToolbar(
                    controller: widget.controller!,
                    config: const QuillSimpleToolbarConfig(
                      showAlignmentButtons: false,
                      showBackgroundColorButton: false,
                      showCenterAlignment: false,
                      showClearFormat: false,
                      showCodeBlock: false,
                      showColorButton: false,
                      showDirection: false,
                      showDividers: false,
                      showFontFamily: false,
                      showFontSize: false,
                      showHeaderStyle: false,
                      showIndent: false,
                      showInlineCode: false,
                      showJustifyAlignment: false,
                      showLeftAlignment: false,
                      showLink: false,
                      showQuote: false,
                      showRightAlignment: false,
                      showSearchButton: false,
                      showSmallButton: false,
                      showStrikeThrough: false,
                      showSubscript: false,
                      showSuperscript: false,
                      showUndo: false,
                      showRedo: false,
                      showListNumbers: true,
                      showListBullets: true,
                      showBoldButton: true,
                      showItalicButton: true,
                      showUnderLineButton: true,
                      showClipboardCopy: false,
                      showClipboardCut: false,
                      showClipboardPaste: false,
                      multiRowsDisplay: false,
                    ),
                  ),
                ),
              Container(
                height: widget.model.height ?? 200,
                padding: const EdgeInsets.all(8),
                child: QuillEditor.basic(
                  controller: widget.controller!,
                  focusNode: _editorFocusNode,
                  config: QuillEditorConfig(
                    placeholder: widget.model.hint,
                    padding: EdgeInsets.zero,
                    expands: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.model.helpMessage != null && !isError)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Text(
              widget.model.helpMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
            ),
          ),
        if (isError && widget.model.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Text(
              widget.model.errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
      ],
    );
  }

  Widget _buildLabel(String title, bool isRequired) {
    if (!isRequired) return Text(title);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        const Text(' *', style: TextStyle(color: Colors.red)),
      ],
    );
  }
}
