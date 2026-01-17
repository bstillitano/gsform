import 'package:flutter/material.dart';
import 'package:gsform/gs_form/model/fields_model/chip_select_model.dart';

/// Full-screen search page for chip selection.
/// Displays a searchable list of items with checkmarks for selection.
class ChipSelectSearchPage extends StatefulWidget {
  final String title;
  final List<ChipSelectItem> items;
  final bool multiSelect;

  const ChipSelectSearchPage({
    super.key,
    required this.title,
    required this.items,
    required this.multiSelect,
  });

  @override
  State<ChipSelectSearchPage> createState() => _ChipSelectSearchPageState();
}

class _ChipSelectSearchPageState extends State<ChipSelectSearchPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChipSelectItem> get _filteredItems {
    if (_searchQuery.isEmpty) return widget.items;
    return widget.items.where((item) =>
      item.label.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  void _onItemTapped(ChipSelectItem item) {
    setState(() {
      if (widget.multiSelect) {
        item.isSelected = !item.isSelected;
      } else {
        // Single select - deselect all others and select this one
        for (final i in widget.items) {
          i.isSelected = i == item;
        }
        // Auto-close on single select
        Navigator.pop(context, widget.items);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, widget.items),
        ),
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          // List of items
          Expanded(
            child: ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return ListTile(
                  leading: item.isSelected
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
                    : const SizedBox(width: 24),
                  title: Text(item.label),
                  onTap: () => _onItemTapped(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
