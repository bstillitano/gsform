import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/model/fields_model/image_picker_model.dart';
import 'package:gsform/gs_form/model/fields_model/multi_image_picker_model.dart';
import 'package:gsform/gs_form/util/util.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class GSMultiImagePickerField extends StatefulWidget implements GSFieldCallBack {
  final GSMultiImagePickerModel model;
  final Function(List<String>?)? onChanged;

  GSMultiImagePickerField(this.model, this.onChanged, {super.key});
  List<String> croppedFilePaths = [];

  @override
  State<GSMultiImagePickerField> createState() =>
      _GSMultiImagePickerFieldState();

  @override
  getValue() {
    return croppedFilePaths;
  }

  @override
  bool isValid() {
    if (!(model.required ?? false)) {
      return true;
    } else {
      return (croppedFilePaths).isNotEmpty;
    }
  }
}

class _GSMultiImagePickerFieldState extends State<GSMultiImagePickerField> {
  @override
  void initState() {
    super.initState();
    if ((widget.model.defaultImagePath ?? []).isNotEmpty) {
      widget.croppedFilePaths.addAll(widget.model.defaultImagePath ?? []);
    } else {
      widget.croppedFilePaths = [];
    }
  }

  @override
  void didUpdateWidget(covariant GSMultiImagePickerField oldWidget) {
    if ((widget.model.defaultImagePath ?? []).isNotEmpty) {
      widget.croppedFilePaths.addAll(widget.model.defaultImagePath ?? []);
    } else {
      widget.croppedFilePaths = [];
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final isReadOnly = widget.model.enableReadOnly ?? false;
    final theme = Theme.of(context);

    // In read-only mode with no images, show a placeholder
    if (isReadOnly && widget.croppedFilePaths.isEmpty) {
      return Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.colorScheme.outline, width: 1),
        ),
        child: Center(
          child: Text(
            'No images',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.hintColor,
            ),
          ),
        ),
      );
    }

    // Calculate item count: include + button only if not read-only
    final itemCount = isReadOnly
        ? widget.croppedFilePaths.length
        : widget.croppedFilePaths.length + 1;

    return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // In read-only mode, all items are images (no + button)
          if (isReadOnly) {
            return _ImageBox(
              imagePath: widget.croppedFilePaths[index],
              isReadOnly: true,
              onDelete: (_) {},
            );
          }
          // In edit mode, first item is + button, rest are images
          return index == 0
              ? _SelectItem(
                  model: widget.model,
                  isEnable: _enableSelectImageButton(),
                  callBack: (imagePath) {
                    widget.croppedFilePaths.add(imagePath);
                    setState(() {});
                    widget.onChanged?.call(widget.croppedFilePaths);
                  },
                )
              : _ImageBox(
                  imagePath: widget.croppedFilePaths[index - 1],
                  isReadOnly: false,
                  onDelete: (value) {
                    widget.croppedFilePaths
                        .removeWhere((element) => element == value);
                    setState(() {});
                    widget.onChanged?.call(widget.croppedFilePaths);
                  },
                );
        },
      );
  }

  bool _enableSelectImageButton() {
    if (widget.model.maximumImageCount != null) {
      if (widget.croppedFilePaths.length >= widget.model.maximumImageCount!) {
        return false;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }
}

class _SelectItem extends StatelessWidget {
  const _SelectItem({
    required this.model,
    required this.callBack,
    required this.isEnable,
  });

  final GSMultiImagePickerModel model;
  final ValueChanged<String> callBack;
  final bool isEnable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox.expand(
      child: Material(
        color: Colors.transparent,
        child: AbsorbPointer(
          absorbing: !isEnable,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: colorScheme.outline, width: 1),
            ),
            child: InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              onTap: () {
                if (model.imageSource == GSImageSource.both) {
                  GSFormUtils.showImagePickerBottomSheet(
                    cameraName: model.cameraPopupTitle,
                    galleryName: model.galleryPopupTitle,
                    cameraAssets: model.cameraPopupIcon,
                    galleryAssets: model.galleryPopupIcon,
                    context,
                    (image) async {
                      _fillImagePath(context, image);
                    },
                  );
                } else if (model.imageSource == GSImageSource.camera) {
                  // On iOS simulator, generate a placeholder image instead
                  GSFormUtils.isIOSSimulator().then((isSimulator) async {
                    if (isSimulator) {
                      final placeholderFile = await GSFormUtils.generatePlaceholderImage();
                      if (placeholderFile != null) {
                        _fillImagePath(context, placeholderFile);
                      }
                    } else {
                      final imageFile = await GSFormUtils.pickImage(ImageSource.camera);
                      if (imageFile != null) {
                        _fillImagePath(context, imageFile);
                      }
                    }
                  });
                } else {
                  GSFormUtils.pickImage(ImageSource.gallery).then(
                    (imageFile) {
                      if (imageFile != null) {
                        _fillImagePath(context, imageFile);
                      }
                    },
                  );
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [model.iconWidget],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _fillImagePath(BuildContext context, File image) {
    if (model.showCropper ?? false) {
      _cropImage(context, image);
    } else {
      if (model.maximumSizePerImageInKB != null) {
        if (image.lengthSync() / 1000 < model.maximumSizePerImageInKB!) {
          callBack.call(image.path);
        } else {
          model.onErrorSizeItem?.call();
        }
      } else {
        callBack.call(image.path);
      }
    }
  }

  Future<void> _cropImage(BuildContext context, File image) async {
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
      if (model.maximumSizePerImageInKB != null) {
        if (image.lengthSync() / 1000 < model.maximumSizePerImageInKB!) {
          model.onErrorSizeItem?.call();
        } else {
          callBack.call(image.path);
        }
      } else {
        callBack.call(image.path);
      }
    }
  }
}

class _ImageBox extends StatelessWidget {
  const _ImageBox({
    required this.imagePath,
    required this.onDelete,
    this.isReadOnly = false,
  });

  final String imagePath;
  final ValueChanged<String> onDelete;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine image type: URL, base64, or file path
    final isUrl = imagePath.startsWith('http');
    final isBase64 = imagePath.startsWith('data:') ||
        (!imagePath.startsWith('/') && !imagePath.startsWith('http') && imagePath.length > 100);

    Widget imageWidget;
    if (isUrl) {
      imageWidget = Image.network(
        imagePath,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      );
    } else if (isBase64) {
      try {
        final base64String = imagePath.contains(',')
            ? imagePath.split(',').last
            : imagePath;
        final bytes = base64Decode(base64String);
        imageWidget = Image.memory(
          bytes,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
        );
      } catch (e) {
        imageWidget = const Icon(Icons.broken_image);
      }
    } else {
      imageWidget = Image.file(
        File(imagePath),
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      );
    }

    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(5.0)),
            clipBehavior: Clip.hardEdge,
            child: imageWidget,
          ),
          if (!isReadOnly)
            Positioned(
              bottom: 8.0,
              left: 8.0,
              child: InkWell(
                onTap: () {
                  onDelete.call(imagePath);
                },
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Icon(
                    Icons.delete,
                    size: 15,
                    color: colorScheme.onError,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
