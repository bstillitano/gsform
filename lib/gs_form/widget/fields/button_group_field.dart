import 'package:flutter/material.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/enums/field_status.dart';
import 'package:gsform/gs_form/model/fields_model/button_group_model.dart';

class GSButtonGroupField extends StatefulWidget implements GSFieldCallBack {
  final GSButtonGroupModel model;
  final Function(ButtonGroupItem?)? onChanged;

  int selectedIndex = -1;

  GSButtonGroupField(this.model, this.onChanged, {super.key});

  @override
  State<GSButtonGroupField> createState() => _GSButtonGroupFieldState();

  @override
  getValue() {
    if (selectedIndex >= 0 && selectedIndex < model.items.length) {
      return model.items[selectedIndex].label;
    }
    return null;
  }

  @override
  bool isValid() {
    if (!(model.required ?? false)) {
      return true;
    }
    return selectedIndex >= 0;
  }
}

class _GSButtonGroupFieldState extends State<GSButtonGroupField> {
  @override
  void initState() {
    super.initState();
    _initSelection();
  }

  void _initSelection() {
    // Check for pre-selected item or value match
    for (int i = 0; i < widget.model.items.length; i++) {
      if (widget.model.items[i].isSelected ||
          widget.model.items[i].label == widget.model.value) {
        widget.selectedIndex = i;
        break;
      }
    }
  }

  @override
  void didUpdateWidget(covariant GSButtonGroupField oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.selectedIndex = oldWidget.selectedIndex;
  }

  void _selectItem(int index) {
    setState(() {
      if (widget.model.allowDeselect && widget.selectedIndex == index) {
        // Deselect if already selected and deselect is allowed
        widget.selectedIndex = -1;
        widget.onChanged?.call(null);
      } else {
        widget.selectedIndex = index;
        widget.onChanged?.call(widget.model.items[index]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isError = widget.model.status == GSFieldStatusEnum.error;
    final isRequired = widget.model.required ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.model.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildLabel(widget.model.title!, isRequired, theme),
          ),
        Row(
          children: widget.model.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = widget.selectedIndex == index;
            final isLast = index == widget.model.items.length - 1;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 8),
                child: _buildButton(item, isSelected, index, theme),
              ),
            );
          }).toList(),
        ),
        if (widget.model.helpMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.model.helpMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (isError && widget.model.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
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

  Widget _buildButton(
      ButtonGroupItem item, bool isSelected, int index, ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.green : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: FilledButton(
        onPressed: widget.model.enableReadOnly == true
            ? null
            : () => _selectItem(index),
        style: FilledButton.styleFrom(
          backgroundColor: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.primaryContainer,
          foregroundColor: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onPrimaryContainer,
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          item.label,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
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
