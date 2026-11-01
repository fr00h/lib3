import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/validators.dart';
import '../models/author.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/entity_form.dart';
import '../widgets/state_views.dart';

class AuthorFormScreen extends StatefulWidget {
  const AuthorFormScreen({super.key, this.id});

  final int? id;

  bool get isEditing => id != null;

  @override
  State<AuthorFormScreen> createState() => _AuthorFormScreenState();
}

class _AuthorFormScreenState extends State<AuthorFormScreen> {
  final _fullName = TextEditingController();
  final _birthYear = TextEditingController();
  final _country = TextEditingController();
  Author? _author;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.isEditing) {
      _author = await context
          .read<EntityListNotifier<Author>>()
          .findById(widget.id!);
    }
    final author = _author;
    if (author != null) {
      _fullName.text = author.fullName;
      _birthYear.text = '${author.birthYear}';
      _country.text = author.country;
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _fullName.dispose();
    _birthYear.dispose();
    _country.dispose();
    super.dispose();
  }

  Future<bool> _save() async {
    final author = Author(
      id: _author?.id ?? 0,
      fullName: _fullName.text.trim(),
      birthYear: int.parse(_birthYear.text.trim()),
      country: _country.text.trim(),
      deletedAt: _author?.deletedAt,
    );
    await context
        .read<EntityListNotifier<Author>>()
        .save(author, isNew: !widget.isEditing);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView();
    if (widget.isEditing && _author == null) {
      return const EmptyView(text: 'Автор не найден');
    }

    return EntityForm(
      title: widget.isEditing ? 'Изменение автора' : 'Новый автор',
      isEditing: widget.isEditing,
      donePath: '/authors',
      onSave: _save,
      fields: [
        TextFormField(
          controller: _fullName,
          decoration: const InputDecoration(
            labelText: 'ФИО',
            border: OutlineInputBorder(),
          ),
          validator: V.combine([V.required(), V.length(min: 2, max: 100)]),
        ),
        TextFormField(
          controller: _birthYear,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Год рождения',
            border: OutlineInputBorder(),
          ),
          validator: V.combine([
            V.required(),
            V.integer(min: 1000, max: DateTime.now().year),
          ]),
        ),
        TextFormField(
          controller: _country,
          decoration: const InputDecoration(
            labelText: 'Страна',
            border: OutlineInputBorder(),
          ),
          validator: V.combine([V.required(), V.length(min: 2, max: 60)]),
        ),
      ],
    );
  }
}
