import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/validators.dart';
import '../models/publisher.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/entity_form.dart';
import '../widgets/state_views.dart';

class PublisherFormScreen extends StatefulWidget {
  const PublisherFormScreen({super.key, this.id});

  final int? id;

  bool get isEditing => id != null;

  @override
  State<PublisherFormScreen> createState() => _PublisherFormScreenState();
}

class _PublisherFormScreenState extends State<PublisherFormScreen> {
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _foundedYear = TextEditingController();
  Publisher? _publisher;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.isEditing) {
      _publisher = await context
          .read<EntityListNotifier<Publisher>>()
          .findById(widget.id!);
    }
    final publisher = _publisher;
    if (publisher != null) {
      _name.text = publisher.name;
      _city.text = publisher.city;
      _foundedYear.text = '${publisher.foundedYear}';
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _foundedYear.dispose();
    super.dispose();
  }

  Future<bool> _save() async {
    final publisher = Publisher(
      id: _publisher?.id ?? 0,
      name: _name.text.trim(),
      city: _city.text.trim(),
      foundedYear: int.parse(_foundedYear.text.trim()),
      deletedAt: _publisher?.deletedAt,
    );
    await context
        .read<EntityListNotifier<Publisher>>()
        .save(publisher, isNew: !widget.isEditing);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView();
    if (widget.isEditing && _publisher == null) {
      return const EmptyView(text: 'Издательство не найдено');
    }

    return EntityForm(
      title: widget.isEditing ? 'Изменение издательства' : 'Новое издательство',
      isEditing: widget.isEditing,
      donePath: '/publishers',
      onSave: _save,
      fields: [
        TextFormField(
          controller: _name,
          decoration: const InputDecoration(
            labelText: 'Название',
            border: OutlineInputBorder(),
          ),
          validator: V.combine([V.required(), V.length(min: 2, max: 100)]),
        ),
        TextFormField(
          controller: _city,
          decoration: const InputDecoration(
            labelText: 'Город',
            border: OutlineInputBorder(),
          ),
          validator: V.combine([V.required(), V.length(min: 2, max: 60)]),
        ),
        TextFormField(
          controller: _foundedYear,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Год основания',
            border: OutlineInputBorder(),
          ),
          validator: V.combine([
            V.required(),
            V.integer(min: 1500, max: DateTime.now().year),
          ]),
        ),
      ],
    );
  }
}
