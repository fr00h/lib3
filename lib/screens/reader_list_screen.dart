import 'package:flutter/material.dart';

import '../models/list_query.dart';
import '../models/reader.dart';
import '../widgets/entity_table.dart';
import 'entity_list_screen.dart';

class ReaderListScreen extends StatelessWidget {
  const ReaderListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context) {
    return EntityListScreen<Reader>(
      query: query,
      searchLabel: 'ФИО или почта',
      addLabel: 'Добавить читателя',
      emptyText: 'Читатели не найдены',
      idOf: (r) => r.id,
      nameOf: (r) => r.fullName,
      isDeleted: (r) => r.isDeleted,
      columns: [
        TableColumnSpec(
          label: 'ФИО',
          sortField: 'fullName',
          build: (r) => Text(r.fullName),
        ),
        TableColumnSpec(
          label: 'Почта',
          sortField: 'email',
          build: (r) => Text(r.email),
        ),
        TableColumnSpec(
          label: 'Телефон',
          build: (r) => Text(r.phone),
        ),
        TableColumnSpec(
          label: 'Билет',
          sortField: 'card',
          build: (r) => Text(r.card.number),
        ),
      ],
    );
  }
}
