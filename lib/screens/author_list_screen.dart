import 'package:flutter/material.dart';

import '../models/author.dart';
import '../models/list_query.dart';
import '../widgets/entity_table.dart';
import 'entity_list_screen.dart';

class AuthorListScreen extends StatelessWidget {
  const AuthorListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context) {
    return EntityListScreen<Author>(
      query: query,
      searchLabel: 'ФИО',
      addLabel: 'Добавить автора',
      emptyText: 'Авторы не найдены',
      idOf: (a) => a.id,
      nameOf: (a) => a.fullName,
      isDeleted: (a) => a.isDeleted,
      columns: [
        TableColumnSpec(
          label: 'ФИО',
          sortField: 'fullName',
          build: (a) => Text(a.fullName),
        ),
        TableColumnSpec(
          label: 'Год рождения',
          sortField: 'birthYear',
          numeric: true,
          build: (a) => Text('${a.birthYear}'),
        ),
        TableColumnSpec(
          label: 'Страна',
          sortField: 'country',
          build: (a) => Text(a.country),
        ),
      ],
    );
  }
}
