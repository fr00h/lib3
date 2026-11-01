import 'package:flutter/material.dart';

class TableColumnSpec<T> {
  final String label;
  final String? sortField;
  final bool numeric;
  final Widget Function(T item) build;

  const TableColumnSpec({
    required this.label,
    required this.build,
    this.sortField,
    this.numeric = false,
  });
}

class EntityTable<T> extends StatelessWidget {
  final List<TableColumnSpec<T>> columns;
  final List<T> items;
  final int Function(T item) idOf;
  final Set<int> selected;
  final ValueChanged<int>? onToggleSelect;
  final String? sortField;
  final bool sortAscending;
  final void Function(String field)? onSort;
  final List<Widget> Function(T item)? actions;

  const EntityTable({
    super.key,
    required this.columns,
    required this.items,
    required this.idOf,
    this.selected = const {},
    this.onToggleSelect,
    this.sortField,
    this.sortAscending = true,
    this.onSort,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) return _buildCards(context);
        return _buildTable(context, constraints.maxWidth);
      },
    );
  }

  Widget _buildTable(BuildContext context, double width) {
    final sortIndex =
        columns.indexWhere((c) => c.sortField != null && c.sortField == sortField);

    final table = DataTable(
      sortColumnIndex: sortIndex == -1 ? null : sortIndex,
      sortAscending: sortAscending,
      showCheckboxColumn: onToggleSelect != null,
      columns: [
        for (final column in columns)
          DataColumn(
            label: Text(column.label),
            numeric: column.numeric,
            onSort: column.sortField == null || onSort == null
                ? null
                : (_, _) => onSort!(column.sortField!),
          ),
        if (actions != null) const DataColumn(label: Text('Действия')),
      ],
      rows: [
        for (final item in items)
          DataRow(
            selected: selected.contains(idOf(item)),
            onSelectChanged: onToggleSelect == null
                ? null
                : (_) => onToggleSelect!(idOf(item)),
            cells: [
              for (final column in columns)
                DataCell(column.build(item)),
              if (actions != null)
                DataCell(
                  Row(mainAxisSize: MainAxisSize.min, children: actions!(item)),
                ),
            ],
          ),
      ],
    );

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: width),
          child: table,
        ),
      ),
    );
  }

  Widget _buildCards(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final id = idOf(item);

        return Card(
          child: ListTile(
            leading: onToggleSelect == null
                ? null
                : Checkbox(
                    value: selected.contains(id),
                    onChanged: (_) => onToggleSelect!(id),
                  ),
            title: columns.first.build(item),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  children: [
                    for (final column in columns.skip(1)) column.build(item),
                  ],
                ),
                if (actions != null) Wrap(children: actions!(item)),
              ],
            ),
          ),
        );
      },
    );
  }
}
