import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/model/fields_model/signature_model.dart';

class GSSignatureField extends StatefulWidget implements GSFieldCallBack {
  final GSSignatureModel model;
  final Function(Uint8List?)? onChanged;

  GSSignatureField({
    super.key,
    required this.model,
    this.onChanged,
  });

  final _SignaturePainterController _controller = _SignaturePainterController();
  Uint8List? signatureData;

  @override
  bool isValid() {
    if (model.required == true) {
      return _controller.hasSignature;
    }
    return true;
  }

  @override
  dynamic getValue() {
    return signatureData;
  }

  @override
  void setValue(dynamic value) {
    // Signature cannot be set programmatically
  }

  Future<Uint8List?> exportSignature() async {
    return await _controller.exportToPng();
  }

  void clear() {
    _controller.clear();
    signatureData = null;
  }

  @override
  State<GSSignatureField> createState() => _GSSignatureFieldState();
}

class _GSSignatureFieldState extends State<GSSignatureField> {
  @override
  void initState() {
    super.initState();
    widget._controller.addListener(_onSignatureChanged);
  }

  @override
  void dispose() {
    widget._controller.removeListener(_onSignatureChanged);
    super.dispose();
  }

  void _onSignatureChanged() {
    setState(() {});
    _exportAndNotify();
  }

  Future<void> _exportAndNotify() async {
    final data = await widget._controller.exportToPng();
    widget.signatureData = data;
    widget.onChanged?.call(data);
  }

  void _onClear() {
    widget._controller.clear();
    widget.signatureData = null;
    widget.onChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = widget.model.height ?? 200.0;
    final penColor = widget.model.penColor ?? theme.colorScheme.onSurface;
    final backgroundColor = widget.model.backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final penStrokeWidth = widget.model.penStrokeWidth ?? 2.0;
    final showClearButton = widget.model.showClearButton ?? true;
    final clearButtonText = widget.model.clearButtonText ?? 'Clear';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: GestureDetector(
              onPanStart: widget.model.enableReadOnly == true
                  ? null
                  : (details) {
                      widget._controller.startStroke(details.localPosition);
                    },
              onPanUpdate: widget.model.enableReadOnly == true
                  ? null
                  : (details) {
                      widget._controller.updateStroke(details.localPosition);
                    },
              onPanEnd: widget.model.enableReadOnly == true
                  ? null
                  : (details) {
                      widget._controller.endStroke();
                    },
              child: CustomPaint(
                painter: _SignaturePainter(
                  controller: widget._controller,
                  penColor: penColor,
                  strokeWidth: penStrokeWidth,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ),
        if (showClearButton && widget.model.enableReadOnly != true)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: widget._controller.hasSignature ? _onClear : null,
                  icon: const Icon(Icons.clear, size: 18),
                  label: Text(clearButtonText),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SignaturePainterController extends ChangeNotifier {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  bool get hasSignature => _strokes.isNotEmpty || _currentStroke.isNotEmpty;

  List<List<Offset>> get strokes => _strokes;
  List<Offset> get currentStroke => _currentStroke;

  void startStroke(Offset point) {
    _currentStroke = [point];
    notifyListeners();
  }

  void updateStroke(Offset point) {
    _currentStroke.add(point);
    notifyListeners();
  }

  void endStroke() {
    if (_currentStroke.isNotEmpty) {
      _strokes.add(List.from(_currentStroke));
      _currentStroke = [];
      notifyListeners();
    }
  }

  void clear() {
    _strokes.clear();
    _currentStroke.clear();
    notifyListeners();
  }

  Future<Uint8List?> exportToPng({int width = 400, int height = 200}) async {
    if (!hasSignature) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw all strokes
    for (final stroke in _strokes) {
      if (stroke.length > 1) {
        final path = Path();
        path.moveTo(stroke[0].dx, stroke[0].dy);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(width, height);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}

class _SignaturePainter extends CustomPainter {
  final _SignaturePainterController controller;
  final Color penColor;
  final double strokeWidth;

  _SignaturePainter({
    required this.controller,
    required this.penColor,
    required this.strokeWidth,
  }) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = penColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw completed strokes
    for (final stroke in controller.strokes) {
      _drawStroke(canvas, stroke, paint);
    }

    // Draw current stroke
    if (controller.currentStroke.isNotEmpty) {
      _drawStroke(canvas, controller.currentStroke, paint);
    }
  }

  void _drawStroke(Canvas canvas, List<Offset> stroke, Paint paint) {
    if (stroke.length < 2) return;

    final path = Path();
    path.moveTo(stroke[0].dx, stroke[0].dy);
    for (int i = 1; i < stroke.length; i++) {
      path.lineTo(stroke[i].dx, stroke[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return true;
  }
}
