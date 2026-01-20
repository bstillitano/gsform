import 'package:flutter/material.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/enums/required_check_list_enum.dart';
import 'package:gsform/gs_form/model/data_model/check_data_model.dart';
import 'package:gsform/gs_form/model/fields_model/checkbox_model.dart';

class GSCheckListField extends StatefulWidget implements GSFieldCallBack {
  final GSCheckBoxModel model;
  final ScrollController controller = ScrollController();
  final TextEditingController textController = TextEditingController();
  List<CheckDataModel> filteredItems = [];
  List<CheckDataModel> valueObject = [];

  String keyword = "";

  GSCheckListField(this.model, {super.key});

  @override
  State<GSCheckListField> createState() => _GSCheckListFieldState();

  @override
  getValue() {
    return valueObject;
  }

  @override
  bool isValid() {
    if (!(model.required ?? false)) {
      return true;
    } else {
      if (model.requiredCheckListEnum == RequiredCheckListEnum.atLeastOneItem) {
        return valueObject.isNotEmpty;
      } else {
        return valueObject.length == model.items.length;
      }
    }
  }
}

class _GSCheckListFieldState extends State<GSCheckListField> {
  @override
  void initState() {
    widget.filteredItems = widget.model.items;
    // Populate valueObject with initially selected items
    widget.valueObject = widget.model.items.where((item) => item.isSelected).toList();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant GSCheckListField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-initialize if items changed (e.g., when isSelected flags are updated for read-only mode)
    if (widget.model.items != oldWidget.model.items) {
      widget.filteredItems = widget.model.items;
      widget.valueObject = widget.model.items.where((item) => item.isSelected).toList();
      // Need to rebuild to reflect the new selection
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      widget.filteredItems = oldWidget.filteredItems;
      widget.valueObject = oldWidget.valueObject;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRequired = widget.model.required ?? false;
    final hasTitle = widget.model.title != null && widget.model.title!.isNotEmpty;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with required indicator
        if (hasTitle)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.model.title!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isRequired)
                  Text(
                    ' *',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        if (widget.model.searchable)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: widget.textController,
              decoration: InputDecoration(
                hintText: widget.model.searchHint,
                prefixIcon:
                    widget.model.searchIcon ?? const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    widget.keyword = '';
                    widget.textController.text = '';
                    widget.filteredItems = widget.model.items;
                    setState(() {});
                  },
                  icon: const Icon(Icons.close),
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (text) {
                setState(() {
                  widget.keyword = text;
                  widget.filteredItems = widget.model.items
                      .where(
                          (i) => i.title.contains(widget.keyword) == true)
                      .toList();
                });
              },
            ),
          ),
        SizedBox(
          height: widget.model.height,
          child: RawScrollbar(
            thumbColor:
                widget.model.scrollBarColor ?? theme.colorScheme.primary,
            trackRadius: const Radius.circular(6),
            radius: const Radius.circular(6),
            interactive: true,
            controller: widget.controller,
            trackVisibility: true,
            thumbVisibility: true,
            thickness: widget.model.showScrollBar ?? false ? 6 : 0,
            child: ListView.builder(
              controller: widget.controller,
              itemCount: widget.filteredItems.length,
              shrinkWrap: widget.model.scrollable == null
                  ? false
                  : !widget.model.scrollable!,
              physics: !widget.model.scrollable!
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final item = widget.filteredItems[index];
                return CheckboxListTile(
                  title: Text(item.title),
                  value: item.isSelected,
                  onChanged: widget.model.enableReadOnly == true ? null : (value) {
                    item.isSelected = value ?? false;
                    if (item.isSelected) {
                      widget.valueObject.add(item);
                    } else {
                      widget.valueObject
                          .removeWhere((element) => element.data == item.data);
                    }
                    widget.model.callBack(item);
                    setState(() {});
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
