import 'package:flutter/material.dart';

import '../models/reader.dart';
import 'entity_detail_screen.dart';

String _date(DateTime d) => d.toIso8601String().substring(0, 10);

class ReaderDetailScreen extends StatelessWidget {
  const ReaderDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return EntityDetailScreen<Reader>(
      id: id,
      path: '/readers',
      backLabel: 'К списку читателей',
      titleOf: (r) => r.fullName,
      fieldsOf: (r) => {
        'Почта': r.email,
        'Телефон': r.phone,
        'Номер билета': r.card.number,
        'Дата выдачи': _date(r.card.issuedAt),
        'Действует до': _date(r.card.expiresAt),
      },
    );
  }
}
