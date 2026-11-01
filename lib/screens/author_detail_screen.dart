import 'package:flutter/material.dart';

import '../models/author.dart';
import 'entity_detail_screen.dart';

class AuthorDetailScreen extends StatelessWidget {
  const AuthorDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return EntityDetailScreen<Author>(
      id: id,
      path: '/authors',
      backLabel: 'К списку авторов',
      titleOf: (a) => a.fullName,
      fieldsOf: (a) => {
        'Год рождения': '${a.birthYear}',
        'Страна': a.country,
      },
    );
  }
}
