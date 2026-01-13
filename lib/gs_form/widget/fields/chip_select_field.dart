import 'package:flutter/material.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/model/fields_model/chip_select_model.dart';

class GSChipSelectField extends StatefulWidget implements GSFieldCallBack {
  final GSChipSelectModel model;
  final Function(List<ChipSelectItem>)? onChanged;

  GSChipSelectField({
    super.key,
    required this.model,
    this.onChanged,
  });

  List<ChipSelectItem> selectedItems = [];

  @override
  bool isValid() {
    if (model.required == true) {
      return selectedItems.isNotEmpty;
    }
    return true;
  }

  @override
  dynamic getValue() {
    return selectedItems;
  }

  void setValue(dynamic value) {
    if (value is List<ChipSelectItem>) {
      selectedItems = value;
    }
  }

  @override
  State<GSChipSelectField> createState() => _GSChipSelectFieldState();
}

class _GSChipSelectFieldState extends State<GSChipSelectField> {
  @override
  void initState() {
    super.initState();
    _updateSelectedItems();
  }

  void _updateSelectedItems() {
    widget.selectedItems = widget.model.items.where((item) => item.isSelected).toList();
  }

  void _onChipTapped(ChipSelectItem item) {
    if (widget.model.enableReadOnly == true) return;

    setState(() {
      if (widget.model.multiSelect) {
        item.isSelected = !item.isSelected;
      } else {
        // Single select - deselect all others
        for (final i in widget.model.items) {
          i.isSelected = i == item ? !i.isSelected : false;
        }
      }
      _updateSelectedItems();
    });

    widget.onChanged?.call(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final chips = widget.model.items.map((item) {
      return Padding(
        padding: const EdgeInsets.only(right: 8, bottom: 8),
        child: FilterChip(
          label: Text(item.label),
          selected: item.isSelected,
          onSelected: widget.model.enableReadOnly == true
              ? null
              : (_) => _onChipTapped(item),
          selectedColor: theme.colorScheme.primaryContainer,
          checkmarkColor: theme.colorScheme.primary,
          labelStyle: TextStyle(
            color: item.isSelected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
          ),
        ),
      );
    }).toList();

    if (widget.model.wrap) {
      return Wrap(
        children: chips,
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: chips),
      );
    }
  }
}
