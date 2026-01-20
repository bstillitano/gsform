import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class GSFormUtils {
  /// Shows a themed bottom sheet for picking an image from camera or gallery.
  static void showImagePickerBottomSheet(
    BuildContext context,
    void Function(File image) callback, {
    String? galleryName = 'Gallery',
    String? cameraName = 'Camera',
    String? cameraAssets,
    String? galleryAssets,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext bc) {
        return Container(
          alignment: Alignment.bottomCenter,
          child: Wrap(
            children: [
              SizedBox(
                height: 130.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            Navigator.pop(bc);
                            await Future.delayed(const Duration(milliseconds: 300));
                            // On iOS simulator, generate a placeholder image instead
                            if (await isIOSSimulator()) {
                              final placeholderFile = await generatePlaceholderImage();
                              if (placeholderFile != null) {
                                callback(placeholderFile);
                              }
                            } else {
                              final imageFile = await pickImage(ImageSource.camera);
                              if (imageFile != null) {
                                callback(imageFile);
                              }
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              cameraAssets == null
                                  ? Icon(
                                      Icons.camera,
                                      size: 40.0,
                                      color: colorScheme.primary,
                                    )
                                  : SvgPicture.asset(
                                      cameraAssets,
                                      width: 40.0,
                                      height: 40.0,
                                      colorFilter: ColorFilter.mode(
                                        colorScheme.primary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                              const SizedBox(height: 10.0),
                              Text(
                                cameraName ?? 'Camera',
                                style: theme.textTheme.titleMedium,
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            Navigator.pop(bc);
                            await Future.delayed(const Duration(milliseconds: 300));
                            final imageFile = await pickImage(ImageSource.gallery);
                            if (imageFile != null) {
                              callback(imageFile);
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              galleryAssets == null
                                  ? Icon(
                                      Icons.photo_library,
                                      size: 40.0,
                                      color: colorScheme.primary,
                                    )
                                  : SvgPicture.asset(
                                      galleryAssets,
                                      width: 40.0,
                                      height: 40.0,
                                      colorFilter: ColorFilter.mode(
                                        colorScheme.primary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                              const SizedBox(height: 10.0),
                              Text(
                                galleryName ?? 'Gallery',
                                style: theme.textTheme.titleMedium,
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Picks an image from the specified source (camera or gallery).
  static Future<File?> pickImage(ImageSource imageSource) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: imageSource,
      maxWidth: 400,
      maxHeight: 400,
    );

    if (image != null) {
      return File(image.path);
    }

    return null;
  }

  /// Returns true if the current locale uses RTL text direction.
  static bool isDirectionRTL(BuildContext context) {
    return Bidi.isRtlLanguage(Localizations.localeOf(context).languageCode);
  }

  /// Cached simulator check result
  static bool? _isIOSSimulatorCached;

  /// Returns true if running on iOS simulator (debug mode only).
  static Future<bool> isIOSSimulator() async {
    // Only check in debug mode
    if (!kDebugMode) return false;
    if (!Platform.isIOS) return false;

    // Use cached result if available
    if (_isIOSSimulatorCached != null) return _isIOSSimulatorCached!;

    try {
      final deviceInfo = DeviceInfoPlugin();
      final iosInfo = await deviceInfo.iosInfo;
      _isIOSSimulatorCached = !iosInfo.isPhysicalDevice;
      return _isIOSSimulatorCached!;
    } catch (e) {
      return false;
    }
  }

  /// Generates a random colored placeholder image for simulator testing.
  /// Returns a File containing the generated PNG image.
  static Future<File?> generatePlaceholderImage() async {
    try {
      final random = Random();

      // Generate random colors
      final bgColor = Color.fromARGB(
        255,
        random.nextInt(200) + 55,
        random.nextInt(200) + 55,
        random.nextInt(200) + 55,
      );

      // Create a simple colored image with text
      const width = 400;
      const height = 400;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw background
      final bgPaint = Paint()..color = bgColor;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        bgPaint,
      );

      // Draw some random shapes for visual interest
      final shapePaint = Paint()
        ..color = Color.fromARGB(
          100,
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
        );

      for (int i = 0; i < 5; i++) {
        final x = random.nextDouble() * width;
        final y = random.nextDouble() * height;
        final radius = random.nextDouble() * 80 + 20;
        canvas.drawCircle(Offset(x, y), radius, shapePaint);
      }

      // Draw "PLACEHOLDER" text
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'SIMULATOR\nPLACEHOLDER',
          style: TextStyle(
            color: bgColor.computeLuminance() > 0.5 ? Colors.black54 : Colors.white70,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout(maxWidth: width.toDouble());
      textPainter.paint(
        canvas,
        Offset(
          (width - textPainter.width) / 2,
          (height - textPainter.height) / 2,
        ),
      );

      // Draw timestamp
      final timestamp = DateTime.now().toString().substring(11, 19);
      final timePainter = TextPainter(
        text: TextSpan(
          text: timestamp,
          style: TextStyle(
            color: bgColor.computeLuminance() > 0.5 ? Colors.black38 : Colors.white54,
            fontSize: 18,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      timePainter.layout();
      timePainter.paint(
        canvas,
        Offset((width - timePainter.width) / 2, height - 40),
      );

      // Convert to image
      final picture = recorder.endRecording();
      final image = await picture.toImage(width, height);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return null;

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final fileName = 'placeholder_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      return file;
    } catch (e) {
      debugPrint('Error generating placeholder image: $e');
      return null;
    }
  }
}

/// A text input formatter for bank card numbers.
/// Formats the input as "0000 0000 0000 0000".
class CardNumberFormatter extends TextInputFormatter {
  final sampleNumber = '0000 0000 0000 0000';

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > oldValue.text.length) {
      if (newValue.text.length > sampleNumber.length) {
        return oldValue;
      }

      final lastEnteredLetter =
          newValue.text.substring(newValue.text.length - 1);
      if (!RegExp(r'[0-9]').hasMatch(lastEnteredLetter)) {
        return oldValue;
      }

      if (newValue.text.isNotEmpty &&
          sampleNumber[newValue.text.length - 1] == ' ') {
        return TextEditingValue(
          text:
              '${oldValue.text} ${newValue.text.substring(newValue.text.length - 1)}',
          selection:
              TextSelection.collapsed(offset: newValue.selection.end + 1),
        );
      }
    }
    return newValue;
  }
}
