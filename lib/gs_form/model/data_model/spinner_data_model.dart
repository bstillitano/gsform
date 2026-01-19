class SpinnerDataModel {
  String name;
  int id;
  bool? isSelected;
  dynamic data;

  SpinnerDataModel({required this.name, required this.id, this.data, bool? isSelected})
      : isSelected = isSelected ?? false;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpinnerDataModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
