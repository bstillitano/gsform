import 'package:flutter/material.dart';
import 'package:gsform/gs_form/widget/field.dart';
import 'package:gsform/gs_form/widget/fields/text_plain_field.dart';

/// A section within a GSForm that groups related fields together.
///
/// Each section can have an optional title and contains a list of fields.
/// Fields are automatically arranged in rows based on their weight property
/// (out of 12 columns).
class GSSection extends StatelessWidget {
  final List<Widget> fields;
  final String? sectionTitle;

  const GSSection({
    super.key,
    required this.fields,
    required this.sectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    List<Row> rows = [];

    int i = 0;
    int weightSum = 0;

    while (i < fields.length) {
      if (fields[i] is GSField) {
        List<Widget> childrenAtRow = [];
        while (weightSum < 12 && i <= fields.length - 1) {
          GSField field = fields[i] as GSField;
          childrenAtRow.add(
            Expanded(
              flex: field.model?.weight ?? 12,
              child: field,
            ),
          );

          weightSum += field.model?.weight ?? 12;
          if (i < fields.length - 1 &&
              fields[i + 1] is GSField &&
              fields[i + 1] is! GSTextPlainField) {
            field.model?.nextFocusNode = (fields[i + 1] as GSField).model?.focusNode;
          }
          i++;

          if (weightSum != 12) {
            childrenAtRow.add(const SizedBox(width: 12));
          }
        }
        rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: childrenAtRow,
        ));
        weightSum = 0;
      } else {
        rows.add(
          Row(
            children: [
              Expanded(
                flex: 12,
                child: fields[i],
              )
            ],
          ),
        );
        i++;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sectionTitle != null && sectionTitle!.isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, bottom: 12),
            child: Text(
              sectionTitle!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rows.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16.0),
              itemBuilder: (context, index) {
                return rows[index];
              },
            ),
          ),
        ),
      ],
    );
  }
}
