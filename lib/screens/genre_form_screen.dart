import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../core/validators.dart';
import '../models/genre.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/entity_form.dart';
import '../widgets/state_views.dart';

class GenreFormScreen extends StatefulWidget {
  const GenreFormScreen({super.key, this.id});

  final int? id;

  bool get isEditing => id != null;

  @override
  State<GenreFormScreen> createState() => _GenreFormScreenState();
}

class _GenreFormScreenState extends State<GenreFormScreen> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  Genre? _genre;
  bool _loading = true;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.isEditing) {
      _genre =
          await context.read<EntityListNotifier<Genre>>().findById(widget.id!);
    }
    final genre = _genre;
    if (genre != null) {
      _name.text = genre.name;
      _description.text = genre.description;
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<bool> _save() async {
    final genre = Genre(
      id: _genre?.id ?? 0,
      name: _name.text.trim(),
      description: _description.text.trim(),
      deletedAt: _genre?.deletedAt,
    );
    try {
      await context
          .read<EntityListNotifier<Genre>>()
          .save(genre, isNew: !widget.isEditing);
    } on ValidationException catch (e) {
      _nameError = e.errors['name'];
      if (_nameError == null) rethrow;
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView();
    if (widget.isEditing && _genre == null) {
      return const EmptyView(text: 'Жанр не найден');
    }

    return EntityForm(
      title: widget.isEditing ? 'Изменение жанра' : 'Новый жанр',
      isEditing: widget.isEditing,
      donePath: '/genres',
      onSave: _save,
      fields: [
        TextFormField(
          controller: _name,
          decoration: const InputDecoration(
            labelText: 'Название',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _nameError = null,
          validator: (value) =>
              V.combine([V.required(), V.length(min: 2, max: 50)])(value) ??
              _nameError,
        ),
        TextFormField(
          controller: _description,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Описание',
            border: OutlineInputBorder(),
          ),
          validator: V.length(max: 200),
        ),
      ],
    );
  }
}
