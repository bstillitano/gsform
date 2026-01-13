import 'package:flutter/material.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/enums/field_status.dart';
import 'package:gsform/gs_form/model/fields_model/star_rating_model.dart';

class GSStarRatingField extends StatefulWidget implements GSFieldCallBack {
  final GSStarRatingModel model;
  final Function(String?)? onChanged;

  int currentRating = 0;

  GSStarRatingField(this.model, this.onChanged, {super.key});

  @override
  State<GSStarRatingField> createState() => _GSStarRatingFieldState();

  @override
  getValue() {
    return currentRating.toString();
  }

  @override
  bool isValid() {
    if (!(model.required ?? false)) {
      return true;
    }
    return currentRating > 0;
  }
}

class _GSStarRatingFieldState extends State<GSStarRatingField> {
  @override
  void initState() {
    super.initState();
    if (widget.model.value != null) {
      widget.currentRating = int.tryParse(widget.model.value.toString()) ?? 0;
    }
  }

  @override
  void didUpdateWidget(covariant GSStarRatingField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model.value == widget.model.value) {
      widget.currentRating = oldWidget.currentRating;
    } else {
      widget.currentRating = int.tryParse(widget.model.value?.toString() ?? '') ?? 0;
    }
  }

  void _setRating(int rating) {
    setState(() {
      widget.currentRating = rating;
      widget.onChanged?.call(rating.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isError = widget.model.status == GSFieldStatusEnum.error;
    final isRequired = widget.model.required ?? false;
    final maxRate = widget.model.maximumRate;
    final starSize = widget.model.starSize ?? 32.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.model.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildLabel(widget.model.title!, isRequired, theme),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxRate, (index) {
            final starIndex = index + 1;
            return GestureDetector(
              onTap: widget.model.enableReadOnly == true
                  ? null
                  : () => _setRating(starIndex),
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  index < widget.currentRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: starSize,
                ),
              ),
            );
          }),
        ),
        if (widget.model.leftText?.isNotEmpty == true ||
            widget.model.rightText?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.model.leftText?.isNotEmpty == true)
                  Text(
                    '1 star: ${widget.model.leftText}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (widget.model.rightText?.isNotEmpty == true)
                  Text(
                    '$maxRate stars: ${widget.model.rightText}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        if (widget.model.helpMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              widget.model.helpMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (isError && widget.model.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              widget.model.errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLabel(String title, bool isRequired, ThemeData theme) {
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
