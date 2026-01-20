import 'package:flutter/material.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/enums/field_status.dart';
import 'package:gsform/gs_form/model/fields_model/qr_scanner_model.dart';
import 'package:gsform/gs_form/screens/qr_scanner_screen.dart';

class GSQRScannerField extends StatefulWidget implements GSFieldCallBack {
  final GSQRScannerModel model;

  GSQRScannerField(this.model, {super.key});
  String? scannedValue;

  @override
  State<GSQRScannerField> createState() => _GSQRScannerFieldState();

  @override
  getValue() {
    return scannedValue;
  }

  @override
  bool isValid() {
    if (!(model.required ?? false)) {
      return true;
    } else {
      return scannedValue?.isNotEmpty ?? false;
    }
  }
}

class _GSQRScannerFieldState extends State<GSQRScannerField> {
  @override
  void initState() {
    super.initState();
    widget.scannedValue = null;
  }

  @override
  void didUpdateWidget(covariant GSQRScannerField oldWidget) {
    widget.scannedValue = null;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isError = widget.model.status == GSFieldStatusEnum.error;

    final scanner = InkWell(
      onTap: () {
        _route(
          context,
          QrScannerScreen(
            callback: (value) {
              widget.scannedValue = value;
              setState(() {});
            },
          ),
        );
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.model.title,
          hintText: widget.model.hint,
          helperText: widget.model.helpMessage,
          errorText: isError ? widget.model.errorMessage : null,
          border: const OutlineInputBorder(),
          suffixIcon: widget.model.iconWidget ?? const Icon(Icons.qr_code_scanner),
          prefixIcon: widget.model.prefixWidget,
        ),
        child: Text(
          widget.scannedValue ?? widget.model.hint ?? 'Tap to scan',
          style: widget.scannedValue != null
              ? null
              : theme.textTheme.bodyLarge?.copyWith(
                  color: theme.hintColor,
                ),
        ),
      ),
    );
    // Use IgnorePointer to prevent interaction while maintaining normal appearance
    if (widget.model.enableReadOnly == true) {
      return IgnorePointer(child: scanner);
    }
    return scanner;
  }

  void _route(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => screen,
      ),
    );
  }
}
