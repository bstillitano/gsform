import 'package:flutter/material.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/model/fields_model/chip_select_model.dart';
import 'package:gsform/gs_form/widget/fields/chip_select_search_page.dart';

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
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateSelectedItems();
  }

  @override
  void didUpdateWidget(GSChipSelectField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selected items when model items change from parent
    // This handles cases where parent rebuilds with new selection state
    _updateSelectedItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateSelectedItems() {
    widget.selectedItems = widget.model.items.where((item) => item.isSelected).toList();
  }

  void _onChipTapped(ChipSelectItem item) {
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

  List<ChipSelectItem> get _filteredItems {
    if (_searchQuery.isEmpty) {
      return widget.model.items;
    }
    return widget.model.items.where((item) {
      return item.label.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Full-screen search mode
    if (widget.model.enableFullScreenSearch) {
      return _buildFullScreenSearchMode(context);
    }

    // Existing inline mode
    return _buildInlineMode(context);
  }

  Widget _buildFullScreenSearchMode(BuildContext context) {
    final theme = Theme.of(context);
    final hasTitle = widget.model.title != null && widget.model.title!.isNotEmpty;
    final isRequired = widget.model.required == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tappable search field with floating label
        GestureDetector(
          onTap: () => _openFullScreenSearch(context),
          child: AbsorbPointer(
            child: TextField(
              decoration: InputDecoration(
                label: hasTitle
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.model.title!),
                          if (isRequired)
                            const Text(' *', style: TextStyle(color: Colors.red)),
                        ],
                      )
                    : null,
                hintText: widget.model.searchHint ?? 'Search',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
          ),
        ),
        // Selected items as chips
        if (widget.selectedItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedItems.map((item) =>
              FilterChip(
                label: Text(item.label),
                selected: true,
                onSelected: (_) => _deselectItem(item),
                selectedColor: theme.colorScheme.primaryContainer,
                checkmarkColor: theme.colorScheme.primary,
                labelStyle: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ).toList(),
          ),
        ],
      ],
    );
  }

  Future<void> _openFullScreenSearch(BuildContext context) async {
    final result = await Navigator.push<List<ChipSelectItem>>(
      context,
      MaterialPageRoute(
        builder: (_) => ChipSelectSearchPage(
          title: widget.model.fullScreenSearchTitle ?? 'Select',
          items: widget.model.items,
          multiSelect: widget.model.multiSelect,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _updateSelectedItems();
      });
      widget.onChanged?.call(widget.selectedItems);
    }
  }

  void _deselectItem(ChipSelectItem item) {
    setState(() {
      item.isSelected = false;
      _updateSelectedItems();
    });
    widget.onChanged?.call(widget.selectedItems);
  }

  Widget _buildInlineMode(BuildContext context) {
    final theme = Theme.of(context);

    final chips = _filteredItems.map((item) {
      return Padding(
        padding: const EdgeInsets.only(right: 8, bottom: 8),
        child: FilterChip(
          label: Text(item.label),
          selected: item.isSelected,
          onSelected: (_) => _onChipTapped(item),
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

    final chipWidget = widget.model.wrap
        ? Wrap(children: chips)
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: chips),
          );

    if (!widget.model.searchable) {
      return chipWidget;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: widget.model.searchHint ?? 'Search',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        chipWidget,
      ],
    );
  }
}
