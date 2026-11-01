import 'package:flutter/material.dart';

import '../models/publisher.dart';
import 'entity_detail_screen.dart';

class PublisherDetailScreen extends StatelessWidget {
  const PublisherDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return EntityDetailScreen<Publisher>(
      id: id,
      path: '/publishers',
      backLabel: 'К списку издательств',
      titleOf: (p) => p.name,
      fieldsOf: (p) => {
        'Город': p.city,
        'Год основания': '${p.foundedYear}',
      },
    );
  }
}
