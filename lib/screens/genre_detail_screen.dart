import 'package:flutter/material.dart';

import '../models/genre.dart';
import 'entity_detail_screen.dart';

class GenreDetailScreen extends StatelessWidget {
  const GenreDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return EntityDetailScreen<Genre>(
      id: id,
      path: '/genres',
      backLabel: 'К списку жанров',
      titleOf: (g) => g.name,
      fieldsOf: (g) => {'Описание': g.description},
    );
  }
}
