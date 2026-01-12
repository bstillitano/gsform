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
  String? _croppedFilePath;

  @override
  State<GSImagePickerField> createState() => _GSImagePickerFieldState();

  @override
  getValue() {
    return _croppedFilePath;
  }

  @override
  bool isValid() {
    if (!(model.required ?? false)) {
      return true;
    } else {
      return _croppedFilePath != null;
    }
  }
}

class _GSImagePickerFieldState extends State<GSImagePickerField> {
  @override
  void initState() {
    super.initState();
    if (widget.model.value != null) {
      widget._croppedFilePath = widget.model.value;
    } else {
      widget._croppedFilePath = null;
    }
  }

  @override
  void didUpdateWidget(covariant GSImagePickerField oldWidget) {
    if (widget.model.value != null) {
      widget._croppedFilePath = widget.model.value;
    } else {
      widget._croppedFilePath = oldWidget._croppedFilePath;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isError = widget.model.status == GSFieldStatusEnum.error;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        onTap: () {
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
            GSFormUtils.pickImage(ImageSource.camera).then(
              (imageFile) {
                if (imageFile != null) {
                  _fillImagePath(imageFile);
                }
              },
            );
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
          child: widget._croppedFilePath == null
              ? _NormalView(model: widget.model)
              : _ImagePickedView(
                  croppedFilePath: widget._croppedFilePath!,
                  model: widget.model,
                  onDeleteImage: () {
                    widget._croppedFilePath = null;
                    setState(() {});
                  },
                ),
        ),
      ),
    );
  }

  void _fillImagePath(File image) {
    if (widget.model.showCropper ?? false) {
      _cropImage(image);
    } else {
      setState(() {});
      if (widget.model.maximumSizePerImageInBytes != null) {
        if (image.lengthSync() / 1000 <
            widget.model.maximumSizePerImageInBytes!) {
          widget._croppedFilePath = image.path;
        } else {
          widget.model.onErrorSizeItem?.call();
        }
      } else {
        widget._croppedFilePath = image.path;
      }
    }
    widget.onChanged?.call(widget._croppedFilePath);
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
            widget._croppedFilePath = image.path;
          } else {
            widget.model.onErrorSizeItem?.call();
          }
        } else {
          widget._croppedFilePath = image.path;
        }
      });
    }
  }
}

class _NormalView extends StatelessWidget {
  const _NormalView({required this.model});
  final GSImagePickerModel model;

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
          model.iconWidget,
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
                model.title ?? '',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Text(
            model.hint ?? '',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePickedView extends StatelessWidget {
  final String croppedFilePath;
  final GSImagePickerModel model;
  final VoidCallback onDeleteImage;

  const _ImagePickedView({
    required this.croppedFilePath,
    required this.model,
    required this.onDeleteImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 140,
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.file(File(croppedFilePath), fit: BoxFit.contain),
            ],
          ),
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
