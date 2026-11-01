import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/list_query.dart';
import '../models/publisher.dart';
import '../repositories/book_repository.dart';
import '../widgets/entity_table.dart';
import 'entity_list_screen.dart';

class PublisherListScreen extends StatelessWidget {
  const PublisherListScreen({super.key, required this.query});

  final ListQuery query;

  @override
  Widget build(BuildContext context) {
    final books = context.read<BookRepository>();

    return EntityListScreen<Publisher>(
      query: query,
      searchLabel: 'Название',
      addLabel: 'Добавить издательство',
      emptyText: 'Издательства не найдены',
      idOf: (p) => p.id,
      nameOf: (p) => p.name,
      isDeleted: (p) => p.isDeleted,
      deleteCheck: (p) async {
        final count = await books.countByPublisher(p.id);
        if (count == 0) return null;
        return 'Нельзя удалить издательство «${p.name}»: '
            'на него ссылаются книги ($count).';
      },
      columns: [
        TableColumnSpec(
          label: 'Название',
          sortField: 'name',
          build: (p) => Text(p.name),
        ),
        TableColumnSpec(
          label: 'Город',
          sortField: 'city',
          build: (p) => Text(p.city),
        ),
        TableColumnSpec(
          label: 'Год основания',
          sortField: 'foundedYear',
          numeric: true,
          build: (p) => Text('${p.foundedYear}'),
        ),
      ],
    );
  }
}
