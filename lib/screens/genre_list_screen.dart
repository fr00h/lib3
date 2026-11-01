import 'package:flutter/material.dart';

import '../models/genre.dart';
import '../models/list_query.dart';
import '../widgets/entity_table.dart';
import 'entity_list_screen.dart';

class GenreListScreen extends StatelessWidget {
  const GenreListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context) {
    return EntityListScreen<Genre>(
      query: query,
      searchLabel: 'Название',
      addLabel: 'Добавить жанр',
      emptyText: 'Жанры не найдены',
      idOf: (g) => g.id,
      nameOf: (g) => g.name,
      isDeleted: (g) => g.isDeleted,
      columns: [
        TableColumnSpec(
          label: 'Название',
          sortField: 'name',
          build: (g) => Text(g.name),
        ),
        TableColumnSpec(
          label: 'Описание',
          build: (g) => Text(g.description),
        ),
      ],
    );
  }
}
