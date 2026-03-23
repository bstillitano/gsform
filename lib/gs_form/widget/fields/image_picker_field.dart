import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/enums/field_status.dart';
import 'package:gsform/gs_form/model/fields_model/image_picker_model.dart';
import 'package:gsform/gs_form/util/util.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class GSImagePickerField extends StatefulWidget implements GSFieldCallBack {
  final GSImagePickerModel model;
  final Function(String?)? onChanged;

  GSImagePickerField(this.model, this.onChanged, {super.key});
  String? croppedFilePath;

  @override
  State<GSImagePickerField> createState() => _GSImagePickerFieldState();

  @override
  getValue() {
    return croppedFilePath;
  }

  @override
  bool isValid() {
    if (!(model.required ?? false)) {
      return true;
    } else {
      return croppedFilePath != null;
    }
  }
}

class _GSImagePickerFieldState extends State<GSImagePickerField> {
  @override
  void initState() {
    super.initState();
    // Only set from model.value if croppedFilePath wasn't already
    // set by GSField._fillChild() during widget recycling
    if (widget.croppedFilePath == null) {
      widget.croppedFilePath = widget.model.value;
    }
  }

  @override
  void didUpdateWidget(covariant GSImagePickerField oldWidget) {
    if (widget.model.value != null) {
      widget.croppedFilePath = widget.model.value;
    } else {
      widget.croppedFilePath = oldWidget.croppedFilePath;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isError = widget.model.status == GSFieldStatusEnum.error;
    final isReadOnly = widget.model.enableReadOnly ?? false;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        onTap: isReadOnly
            ? null
            : () {
                if (widget.model.imageSource == GSImageSource.both) {
                  GSFormUtils.showImagePickerBottomSheet(
                    cameraName: widget.model.cameraPopupTitle,
                    galleryName: widget.model.galleryPopupTitle,
                    cameraAssets: widget.model.cameraPopupIcon,
                    galleryAssets: widget.model.galleryPopupIcon,
                    context,
                    (image) async {
                      _fillImagePath(image);
                    },
                  );
                } else if (widget.model.imageSource == GSImageSource.camera) {
                  // On iOS simulator, generate a placeholder image instead
                  GSFormUtils.isIOSSimulator().then((isSimulator) async {
                    if (isSimulator) {
                      final placeholderFile = await GSFormUtils.generatePlaceholderImage();
                      if (placeholderFile != null) {
                        _fillImagePath(placeholderFile);
                      }
                    } else {
                      final imageFile = await GSFormUtils.pickImage(ImageSource.camera);
                      if (imageFile != null) {
                        _fillImagePath(imageFile);
                      }
                    }
                  });
                } else {
                  GSFormUtils.pickImage(ImageSource.gallery).then(
                    (imageFile) {
                      if (imageFile != null) {
                        _fillImagePath(imageFile);
                      }
                    },
                  );
                }
              },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isError ? colorScheme.error : colorScheme.outline,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: widget.croppedFilePath == null
              ? _NormalView(model: widget.model, isReadOnly: isReadOnly)
              : _ImagePickedView(
                  croppedFilePath: widget.croppedFilePath!,
                  model: widget.model,
                  isReadOnly: isReadOnly,
                  onDeleteImage: () {
                    widget.croppedFilePath = null;
                    widget.model.value = null;
                    widget.onChanged?.call(null);
                    setState(() {});
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _fillImagePath(File image) async {
    if (widget.model.showCropper ?? false) {
      await _cropImage(image);
    } else {
      if (widget.model.maximumSizePerImageInBytes != null) {
        if (image.lengthSync() / 1000 <
            widget.model.maximumSizePerImageInBytes!) {
          widget.croppedFilePath = image.path;
        } else {
          widget.model.onErrorSizeItem?.call();
        }
      } else {
        widget.croppedFilePath = image.path;
      }
      setState(() {});
    }
    // Update model.value so it survives widget recycling
    widget.model.value = widget.croppedFilePath;
    widget.onChanged?.call(widget.croppedFilePath);
  }

  Future<void> _cropImage(File image) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Preview',
          toolbarColor: colorScheme.surface,
          toolbarWidgetColor: colorScheme.onSurface,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    if (croppedFile != null) {
      setState(() {
        if (widget.model.maximumSizePerImageInBytes != null) {
          if (image.lengthSync() / 1000 <
              widget.model.maximumSizePerImageInBytes!) {
            widget.croppedFilePath = image.path;
          } else {
            widget.model.onErrorSizeItem?.call();
          }
        } else {
          widget.croppedFilePath = image.path;
        }
        widget.model.value = widget.croppedFilePath;
      });
    }
  }
}

class _NormalView extends StatelessWidget {
  const _NormalView({required this.model, this.isReadOnly = false});
  final GSImagePickerModel model;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isReadOnly) model.iconWidget,
          const SizedBox(height: 6.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (model.required ?? false)
                Padding(
                  padding: const EdgeInsets.only(right: 4, left: 4),
                  child: Text(
                    '*',
                    style: TextStyle(
                      color: colorScheme.error,
                      fontSize: 10,
                    ),
                  ),
                ),
              Text(
                isReadOnly ? 'No image' : (model.title ?? ''),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isReadOnly ? theme.hintColor : null,
                ),
              ),
            ],
          ),
          if (!isReadOnly) ...[
            const SizedBox(height: 6.0),
            Text(
              model.hint ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ImagePickedView extends StatelessWidget {
  final String croppedFilePath;
  final GSImagePickerModel model;
  final VoidCallback onDeleteImage;
  final bool isReadOnly;

  const _ImagePickedView({
    required this.croppedFilePath,
    required this.model,
    required this.onDeleteImage,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Check if path is a URL, file path, or base64 data
    final isUrl = croppedFilePath.startsWith('http');
    final isBase64 = croppedFilePath.startsWith('data:') ||
        (!croppedFilePath.startsWith('/') && !croppedFilePath.startsWith('http') && croppedFilePath.length > 100);

    Widget imageWidget;
    Widget errorFallback = const Center(child: Icon(Icons.broken_image, size: 40));
    if (isUrl) {
      imageWidget = Image.network(croppedFilePath, fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => errorFallback);
    } else if (isBase64) {
      // Handle base64 data URL or raw base64 string
      try {
        final base64String = croppedFilePath.contains(',')
            ? croppedFilePath.split(',').last
            : croppedFilePath;
        final bytes = base64Decode(base64String);
        imageWidget = Image.memory(bytes, fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => errorFallback);
      } catch (e) {
        imageWidget = errorFallback;
      }
    } else {
      imageWidget = Image.file(File(croppedFilePath), fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => errorFallback);
    }

    return SizedBox(
      height: 140,
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageWidget,
          if (!isReadOnly)
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 32.0,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(9.0),
                      bottomRight: Radius.circular(9.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                    child: Row(
                      children: [
                        Text(
                          model.title!,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          height: 20.0,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.error,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              onDeleteImage.call();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  maxLines: 1,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onError,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }
}
