import 'package:flutter/cupertino.dart';
import 'package:gsform/gs_form/model/fields_model/field_model.dart';

/// Represents a column in the risk matrix (X-axis / Severity)
class MatrixColumn {
  final int xid;
  final String label;

  MatrixColumn({required this.xid, required this.label});
}

/// Represents a row in the risk matrix (Y-axis / Likelihood)
class MatrixRow {
  final int yid;
  final String label;

  MatrixRow({required this.yid, required this.label});
}

/// Represents a single cell in the risk matrix
class MatrixCell {
  final int xid;
  final int yid;
  final int xyId;
  final String x; // Column label (severity)
  final String y; // Row label (likelihood)
  final String xyName; // Risk level name (e.g., "Critical", "High", "Medium")
  final String xyColor; // Hex color (e.g., "#633636")
  final String xy; // Score value

  MatrixCell({
    required this.xid,
    required this.yid,
    required this.xyId,
    required this.x,
    required this.y,
    required this.xyName,
    required this.xyColor,
    required this.xy,
  });

  /// Create a MatrixCell from a JSON map
  factory MatrixCell.fromJson(Map<String, dynamic> json) {
    return MatrixCell(
      xid: json['xid'] as int? ?? 0,
      yid: json['yid'] as int? ?? 0,
      xyId: json['xyId'] as int? ?? 0,
      x: json['x']?.toString() ?? '',
      y: json['y']?.toString() ?? '',
      xyName: json['xyName']?.toString() ?? '',
      xyColor: json['xyColor']?.toString() ?? '#CCCCCC',
      xy: json['xy']?.toString() ?? '0',
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'xid': xid,
      'yid': yid,
      'xyId': xyId,
      'x': x,
      'y': y,
      'xyName': xyName,
      'xyColor': xyColor,
      'xy': xy,
    };
  }
}

/// Model for the Risk Matrix field
class GSMatrixModel extends GSFieldModel {
  /// The full matrix data from API - list of all cells
  List<MatrixCell> cells;

  /// Axis labels (headers)
  String severityLabel; // X-axis header (default: "Severity")
  String likelihoodLabel; // Y-axis header (default: "Likelihood")

  /// Axis descriptions (optional, shown below the labels in corner cell)
  String? severityDescription; // Description for severity axis
  String? likelihoodDescription; // Description for likelihood axis

  /// Currently selected cell coordinates
  int? selectedXId;
  int? selectedYId;
  int? selectedCellId; // xyId of selected cell

  /// Callback when a cell is selected
  /// Parameters: xid, yid, xyId, score
  Function(int xid, int yid, int xyId, int score)? onCellSelected;

  GSMatrixModel({
    super.type,
    required super.tag,
    super.title,
    super.errorMessage,
    super.helpMessage,
    super.prefixWidget,
    super.postfixWidget,
    super.required,
    super.status,
    super.value,
    super.validateRegEx,
    super.weight,
    super.showTitle,
    super.enableReadOnly,
    super.onTap,
    this.cells = const [],
    this.severityLabel = 'Severity',
    this.likelihoodLabel = 'Likelihood',
    this.severityDescription,
    this.likelihoodDescription,
    this.selectedXId,
    this.selectedYId,
    this.selectedCellId,
    this.onCellSelected,
  }) : super(focusNode: FocusNode());

  /// Get unique columns from cells, sorted by xid
  /// This dynamically determines grid width from the data
  List<MatrixColumn> get uniqueColumns {
    final seen = <int>{};
    final cols = <MatrixColumn>[];

    for (final cell in cells) {
      if (!seen.contains(cell.xid)) {
        seen.add(cell.xid);
        cols.add(MatrixColumn(xid: cell.xid, label: cell.x));
      }
    }

    cols.sort((a, b) => a.xid.compareTo(b.xid));
    return cols;
  }

  /// Get unique rows from cells, sorted by yid
  /// This dynamically determines grid height from the data
  List<MatrixRow> get uniqueRows {
    final seen = <int>{};
    final rows = <MatrixRow>[];

    for (final cell in cells) {
      if (!seen.contains(cell.yid)) {
        seen.add(cell.yid);
        rows.add(MatrixRow(yid: cell.yid, label: cell.y));
      }
    }

    rows.sort((a, b) => a.yid.compareTo(b.yid));
    return rows;
  }

  /// Find a cell by its row and column IDs
  MatrixCell? findCell(int xid, int yid) {
    for (final cell in cells) {
      if (cell.xid == xid && cell.yid == yid) {
        return cell;
      }
    }
    return null;
  }

  /// Get the currently selected cell
  MatrixCell? get selectedCell {
    if (selectedXId == null || selectedYId == null) return null;
    return findCell(selectedXId!, selectedYId!);
  }
}
