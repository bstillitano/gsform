import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
                            final imageFile = await pickImage(ImageSource.camera);
                            if (imageFile != null) {
                              callback(imageFile);
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
