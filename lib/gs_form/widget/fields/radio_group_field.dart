import 'package:flutter/material.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/enums/field_status.dart';
import 'package:gsform/gs_form/model/data_model/radio_data_model.dart';
import 'package:gsform/gs_form/model/fields_model/radio_model.dart';

class GSRadioGroupField extends StatefulWidget implements GSFieldCallBack {
  final GSRadioModel model;
  final TextEditingController textController = TextEditingController();

  GSRadioGroupField(this.model, {super.key});

  RadioDataModel? returnedData;
  List<RadioDataModel> filteredItems = [];
  String keyword = "";

  @override
  State<GSRadioGroupField> createState() => _GSRadioGroupFieldState();

  @override
  getValue() {
    return returnedData;
  }

  @override
  bool isValid() {
    if (!(model.required ?? false)) {
      return true;
    } else {
      return returnedData != null;
    }
  }
}

class _GSRadioGroupFieldState extends State<GSRadioGroupField> {
  ScrollController controller = ScrollController();

  @override
  void initState() {
    widget.filteredItems = widget.model.items;
    for (var element in widget.model.items) {
      if (element.isSelected) {
        widget.returnedData = element;
      }
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant GSRadioGroupField oldWidget) {
    widget.filteredItems = oldWidget.filteredItems;
    widget.returnedData = oldWidget.returnedData;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHorizontal = widget.model.scrollDirection == Axis.horizontal;
    final isError = widget.model.status == GSFieldStatusEnum.error;
    final isRequired = widget.model.required ?? false;
    final defaultErrorMessage = isRequired ? 'Please select an option' : null;

    widget.filteredItems = widget.model.items
        .where((i) => i.title.contains(widget.keyword) == true)
        .toList();

    for (var element in widget.model.items) {
      if (element.isSelected) {
        widget.returnedData = element;
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                widget.keyword = text;
                widget.filteredItems = widget.model.items
                    .where((i) => i.title.contains(widget.keyword) == true)
                    .toList();
                setState(() {});
              },
            ),
          ),
        SizedBox(
          height: widget.model.height,
          child: isHorizontal
              ? _buildHorizontalList(theme)
              : _buildVerticalList(theme),
        ),
        if (isError)
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 8.0),
            child: Text(
              widget.model.errorMessage ?? defaultErrorMessage ?? '',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHorizontalList(ThemeData theme) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      controller: controller,
      itemCount: widget.filteredItems.length,
      shrinkWrap: widget.model.scrollable == null
          ? false
          : !widget.model.scrollable!,
      physics: !widget.model.scrollable!
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final item = widget.filteredItems[index];
        final isSelected = widget.returnedData == item;
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              for (var element in widget.filteredItems) {
                element.isSelected = false;
              }
              item.isSelected = true;
              widget.model.callBack(item);
              widget.returnedData = item;
              setState(() {});
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<RadioDataModel>(
                  value: item,
                  groupValue: widget.returnedData,
                  onChanged: (value) {
                    for (var element in widget.filteredItems) {
                      element.isSelected = false;
                    }
                    item.isSelected = true;
                    widget.model.callBack(item);
                    widget.returnedData = item;
                    setState(() {});
                  },
                ),
                Text(
                  item.title,
                  style: isSelected
                      ? theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        )
                      : theme.textTheme.bodyMedium,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerticalList(ThemeData theme) {
    return RawScrollbar(
      thumbColor: widget.model.scrollBarColor ?? theme.colorScheme.primary,
      trackRadius: const Radius.circular(6),
      radius: const Radius.circular(6),
      interactive: true,
      controller: controller,
      trackVisibility: true,
      thumbVisibility: true,
      thickness: widget.model.showScrollBar ?? false ? 6 : 0,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        controller: controller,
        itemCount: widget.filteredItems.length,
        shrinkWrap: widget.model.scrollable == null
            ? false
            : !widget.model.scrollable!,
        physics: !widget.model.scrollable!
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final item = widget.filteredItems[index];
          return RadioListTile<RadioDataModel>(
            title: Text(item.title),
            value: item,
            groupValue: widget.returnedData,
            onChanged: (value) {
              for (var element in widget.filteredItems) {
                element.isSelected = false;
              }
              item.isSelected = true;
              widget.model.callBack(item);
              widget.returnedData = item;
              setState(() {});
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          );
        },
      ),
    );
  }
}
