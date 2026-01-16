import 'package:flutter/material.dart';
import 'package:gsform/gs_form/core/field_callback.dart';
import 'package:gsform/gs_form/enums/field_status.dart';
import 'package:gsform/gs_form/model/fields_model/matrix_model.dart';

class GSMatrixField extends StatefulWidget implements GSFieldCallBack {
  final GSMatrixModel model;

  /// Currently selected cell coordinates (preserved across rebuilds)
  int? selectedXId;
  int? selectedYId;
  int? selectedCellId;

  GSMatrixField(this.model, {super.key}) {
    // Initialize from model
    selectedXId = model.selectedXId;
    selectedYId = model.selectedYId;
    selectedCellId = model.selectedCellId;
  }

  @override
  State<GSMatrixField> createState() => _GSMatrixFieldState();

  @override
  getValue() {
    final cell = model.findCell(selectedXId ?? 0, selectedYId ?? 0);
    if (cell == null) return null;

    return {
      'xid': selectedXId,
      'yid': selectedYId,
      'xyId': selectedCellId,
      'score': int.tryParse(cell.xy) ?? 0,
      'xyName': cell.xyName,
    };
  }

  @override
  bool isValid() {
    if (!(model.required ?? false)) {
      return true;
    }
    return selectedCellId != null;
  }
}

class _GSMatrixFieldState extends State<GSMatrixField> {
  static const double _cellWidth = 80.0;
  static const double _cellHeight = 60.0;
  static const double _rowHeaderWidth = 140.0;

  @override
  Widget build(BuildContext context) {
    final isError = widget.model.status == GSFieldStatusEnum.error;
    final isRequired = widget.model.required ?? false;
    final isReadOnly = widget.model.enableReadOnly ?? false;
    final defaultErrorMessage =
        isRequired ? 'Selection is required' : 'Please make a selection';

    if (widget.model.cells.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        if (widget.model.showTitle ?? true) _buildTitle(context, isRequired),

        const SizedBox(height: 8),

        // Matrix with frozen row headers
        _buildMatrixWithFrozenHeaders(context, isReadOnly),

        // Help message
        if (widget.model.helpMessage != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.model.helpMessage!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],

        // Error message
        if (isError) ...[
          const SizedBox(height: 4),
          Text(
            widget.model.errorMessage ?? defaultErrorMessage,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final borderColor = Theme.of(context).dividerColor;
    final textColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'No matrix data available',
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, bool isRequired) {
    if (widget.model.title == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.model.title!,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 16,
            ),
          ),
      ],
    );
  }

  /// Build the matrix with frozen row headers on the left
  Widget _buildMatrixWithFrozenHeaders(BuildContext context, bool isReadOnly) {
    final columns = widget.model.uniqueColumns;
    final rows = widget.model.uniqueRows;
    final borderColor = Theme.of(context).dividerColor;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section: Corner + Likelihood header + Column headers
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Corner cell (fixed)
                _buildCornerCell(context),
                // Scrollable: Likelihood + column headers
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Likelihood header (full width, auto height)
                        _buildLikelihoodHeader(context, columns.length),
                        // Column headers row (auto height)
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: columns.map((col) => _buildColumnHeader(context, col)).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Data rows: each row is IntrinsicHeight to sync heights
          ...rows.map((row) => IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Fixed row header
                    _buildRowHeader(context, row),
                    // Scrollable cells
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: columns.map((col) => _buildCell(context, row, col, isReadOnly)).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// Corner cell containing Severity label and description
  Widget _buildCornerCell(BuildContext context) {
    final labelColor = Theme.of(context).colorScheme.onSurface;
    final descriptionColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final borderColor = Theme.of(context).dividerColor;

    return Container(
      width: _rowHeaderWidth,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: borderColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${widget.model.severityLabel}:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
          if (widget.model.severityDescription != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.model.severityDescription!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.normal,
                color: descriptionColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Likelihood header that spans all columns
  Widget _buildLikelihoodHeader(BuildContext context, int columnCount) {
    final labelColor = Theme.of(context).colorScheme.onSurface;
    final borderColor = Theme.of(context).dividerColor;

    return Container(
      width: columnCount * _cellWidth,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Center(
        child: Text(
          widget.model.likelihoodLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: labelColor,
          ),
        ),
      ),
    );
  }

  Widget _buildColumnHeader(BuildContext context, MatrixColumn column) {
    final textColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final borderColor = Theme.of(context).dividerColor;

    return Container(
      width: _cellWidth,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor),
          right: BorderSide(color: borderColor.withOpacity(0.3)),
        ),
      ),
      child: Center(
        child: Text(
          column.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildRowHeader(BuildContext context, MatrixRow row) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final borderColor = Theme.of(context).dividerColor;

    return Container(
      width: _rowHeaderWidth,
      constraints: BoxConstraints(minHeight: _cellHeight),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor.withOpacity(0.3)),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          row.label,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildCell(BuildContext context, MatrixRow row, MatrixColumn column, bool isReadOnly) {
    final cell = widget.model.findCell(column.xid, row.yid);
    if (cell == null) {
      return SizedBox(width: _cellWidth);
    }

    final isSelected = widget.selectedXId == cell.xid &&
        widget.selectedYId == cell.yid;
    final backgroundColor = _parseHexColor(cell.xyColor);
    final textColor = _getContrastColor(backgroundColor);

    // Use surface color for cell gaps (matches section/card background)
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return GestureDetector(
      onTap: isReadOnly ? null : () => _selectCell(cell),
      child: Container(
        width: _cellWidth,
        constraints: BoxConstraints(minHeight: _cellHeight),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: isSelected
              ? Border.all(color: Colors.blue, width: 3)
              : Border.all(color: surfaceColor, width: 0.5),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              cell.xyName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectCell(MatrixCell cell) {
    setState(() {
      widget.selectedXId = cell.xid;
      widget.selectedYId = cell.yid;
      widget.selectedCellId = cell.xyId;

      // Also update the model
      widget.model.selectedXId = cell.xid;
      widget.model.selectedYId = cell.yid;
      widget.model.selectedCellId = cell.xyId;
    });

    // Notify callback
    final score = int.tryParse(cell.xy) ?? 0;
    widget.model.onCellSelected?.call(cell.xid, cell.yid, cell.xyId, score);
  }

  /// Parse a hex color string to a Color
  Color _parseHexColor(String hexColor) {
    try {
      String hex = hexColor.replaceFirst('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex'; // Add alpha
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.grey; // Fallback color
    }
  }

  /// Calculate contrasting text color based on background luminance
  Color _getContrastColor(Color backgroundColor) {
    // Calculate relative luminance (perceived brightness)
    // Using the formula: 0.299*R + 0.587*G + 0.114*B
    final luminance = (0.299 * backgroundColor.red +
            0.587 * backgroundColor.green +
            0.114 * backgroundColor.blue) /
        255;

    // Use white text on dark backgrounds, black on light
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
