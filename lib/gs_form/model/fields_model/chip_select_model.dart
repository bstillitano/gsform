import 'package:gsform/gs_form/enums/filed_type.dart';
import 'package:gsform/gs_form/model/fields_model/field_model.dart';

class ChipSelectItem {
  final String label;
  final dynamic data;
  bool isSelected;

  ChipSelectItem({
    required this.label,
    this.data,
    this.isSelected = false,
  });
}

class GSChipSelectModel extends GSFieldModel {
  List<ChipSelectItem> items;
  bool multiSelect;
  bool wrap;
  bool searchable;
  String? searchHint;

  GSChipSelectModel({
    required super.tag,
    required this.items,
    this.multiSelect = false,
    this.wrap = true,
    this.searchable = false,
    this.searchHint,
    super.title,
    super.errorMessage,
    super.helpMessage,
    super.required,
    super.status,
    super.weight,
    super.showTitle,
    super.prefixWidget,
    super.postfixWidget,
    super.enableReadOnly,
  });

  @override
  GSFieldTypeEnum get type => GSFieldTypeEnum.chipSelect;
}
