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

  // State reference for accessing controller from widget interface
  _GSSignatureFieldState? _state;

  // Getter/setter for signatureData that delegates to state
  Uint8List? get signatureData => _state?.signatureData;
  set signatureData(Uint8List? value) {
    if (_state != null) {
      _state!.signatureData = value;
    }
  }

  @override
  bool isValid() {
    if (model.required == true) {
      return _state?._controller.hasSignature ?? false;
    }
    return true;
  }

  @override
  dynamic getValue() {
    return _state?.signatureData;
  }

  @override
  void setValue(dynamic value) {
    // Signature cannot be set programmatically
  }

  Future<Uint8List?> exportSignature() async {
    return await _state?._controller.exportToPng(backgroundImage: _state?._backgroundImage);
  }

  void clear() {
    _state?._controller.clear();
    _state?.signatureData = null;
  }

  @override
  State<GSSignatureField> createState() => _GSSignatureFieldState();
}

class _GSSignatureFieldState extends State<GSSignatureField> {
  // Controller is now held in State to persist across widget rebuilds
  final _SignaturePainterController _controller = _SignaturePainterController();
  ui.Image? _backgroundImage;
  Size? _canvasSize;
  Uint8List? signatureData;

  @override
  void initState() {
    super.initState();
    widget._state = this;
    _controller.addListener(_onSignatureChanged);
    _loadBackgroundImage();
  }

  @override
  void didUpdateWidget(GSSignatureField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update state reference when widget is rebuilt
    widget._state = this;
  }

  @override
  void dispose() {
    _controller.removeListener(_onSignatureChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadBackgroundImage() async {
    if (widget.model.backgroundImageBytes != null) {
      final codec = await ui.instantiateImageCodec(widget.model.backgroundImageBytes!);
      final frame = await codec.getNextFrame();
      setState(() {
        _backgroundImage = frame.image;
      });
    }
  }

  void _onSignatureChanged() {
    setState(() {});
    _exportAndNotify();
  }

  Future<void> _exportAndNotify() async {
    final data = await _controller.exportToPng(
      backgroundImage: _backgroundImage,
      width: _canvasSize?.width.toInt() ?? 400,
      height: _canvasSize?.height.toInt() ?? 200,
    );
    signatureData = data;
    widget.onChanged?.call(data);
  }

  void _onClear() {
    _controller.clear();
    signatureData = null;
    widget.onChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final penColor = widget.model.penColor ?? theme.colorScheme.onSurface;
    final backgroundColor = widget.model.backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final penStrokeWidth = widget.model.penStrokeWidth ?? 2.0;
    final showClearButton = widget.model.showClearButton ?? true;
    final clearButtonText = widget.model.clearButtonText ?? 'Clear';
    final height = widget.model.height ?? 200.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
              return Container(
                decoration: BoxDecoration(
                  color: _backgroundImage == null ? backgroundColor : null,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_backgroundImage != null)
                        RawImage(
                          image: _backgroundImage,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(color: backgroundColor),
                      GestureDetector(
                        onPanStart: widget.model.enableReadOnly == true
                            ? null
                            : (details) {
                                _controller.startStroke(details.localPosition);
                              },
                        onPanUpdate: widget.model.enableReadOnly == true
                            ? null
                            : (details) {
                                _controller.updateStroke(details.localPosition);
                              },
                        onPanEnd: widget.model.enableReadOnly == true
                            ? null
                            : (details) {
                                _controller.endStroke();
                              },
                        child: CustomPaint(
                          painter: _SignaturePainter(
                            controller: _controller,
                            penColor: penColor,
                            strokeWidth: penStrokeWidth,
                          ),
                          size: Size.infinite,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (showClearButton && widget.model.enableReadOnly != true)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _controller.hasSignature ? _onClear : null,
              icon: const Icon(Icons.clear, size: 14),
              label: Text(clearButtonText, style: const TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
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

  Future<Uint8List?> exportToPng({
    ui.Image? backgroundImage,
    int width = 400,
    int height = 200,
  }) async {
    if (!hasSignature && backgroundImage == null) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw background image if provided
    if (backgroundImage != null) {
      final srcRect = Rect.fromLTWH(
        0,
        0,
        backgroundImage.width.toDouble(),
        backgroundImage.height.toDouble(),
      );
      final dstRect = Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
      canvas.drawImageRect(backgroundImage, srcRect, dstRect, Paint());
    }

    // Draw strokes
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

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
