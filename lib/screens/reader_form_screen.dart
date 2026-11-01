import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../core/validators.dart';
import '../models/reader.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/entity_form.dart';
import '../widgets/state_views.dart';

String _date(DateTime d) => d.toIso8601String().substring(0, 10);

class ReaderFormScreen extends StatefulWidget {
  const ReaderFormScreen({super.key, this.id});

  final int? id;

  bool get isEditing => id != null;

  @override
  State<ReaderFormScreen> createState() => _ReaderFormScreenState();
}

class _ReaderFormScreenState extends State<ReaderFormScreen> {
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _cardNumber = TextEditingController();
  final _issuedAt = TextEditingController();
  final _expiresAt = TextEditingController();
  Reader? _reader;
  bool _loading = true;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.isEditing) {
      _reader = await context
          .read<EntityListNotifier<Reader>>()
          .findById(widget.id!);
    }
    final reader = _reader;
    if (reader != null) {
      _fullName.text = reader.fullName;
      _email.text = reader.email;
      _phone.text = reader.phone;
      _cardNumber.text = reader.card.number;
      _issuedAt.text = _date(reader.card.issuedAt);
      _expiresAt.text = _date(reader.card.expiresAt);
    } else {
      final now = DateTime.now();
      _issuedAt.text = _date(now);
      _expiresAt.text = _date(DateTime(now.year + 1, now.month, now.day));
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _cardNumber.dispose();
    _issuedAt.dispose();
    _expiresAt.dispose();
    super.dispose();
  }

  Future<bool> _save() async {
    final notifier = context.read<EntityListNotifier<Reader>>();
    final email = _email.text.trim();
    final reader = Reader(
      id: _reader?.id ?? 0,
      fullName: _fullName.text.trim(),
      email: email,
      phone: _phone.text.trim(),
      card: LibraryCard(
        id: _reader?.card.id ?? 0,
        number: _cardNumber.text.trim(),
        issuedAt: DateTime.parse(_issuedAt.text.trim()),
        expiresAt: DateTime.parse(_expiresAt.text.trim()),
      ),
      deletedAt: _reader?.deletedAt,
    );
    try {
      await notifier.save(reader, isNew: !widget.isEditing);
    } on ValidationException catch (e) {
      _emailError = e.errors['email'];
      if (_emailError == null) rethrow;
      return false;
    }
    return true;
  }

  String? _expiresValidator(String? value) {
    final error = V.combine([V.required(), V.date()])(value);
    if (error != null) return error;
    final issued = DateTime.tryParse(_issuedAt.text.trim());
    final expires = DateTime.parse(value!.trim());
    if (issued != null && !expires.isAfter(issued)) {
      return 'Должна быть позже даты выдачи';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView();
    if (widget.isEditing && _reader == null) {
      return const EmptyView(text: 'Читатель не найден');
    }

    return EntityForm(
      title: widget.isEditing ? 'Изменение читателя' : 'Новый читатель',
      isEditing: widget.isEditing,
      donePath: '/readers',
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
          controller: _email,
          decoration: const InputDecoration(
            labelText: 'Почта',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _emailError = null,
          validator: (value) =>
              V.combine([V.required(), V.length(max: 100), V.email()])(value) ??
              _emailError,
        ),
        TextFormField(
          controller: _phone,
          decoration: const InputDecoration(
            labelText: 'Телефон',
            border: OutlineInputBorder(),
          ),
          validator: V.combine([
            V.required(),
            V.pattern(
              RegExp(r'^\+?[\d\s()-]{10,18}$'),
              'Телефон в формате +7 900 000-00-00',
            ),
          ]),
        ),
        InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Читательский билет',
            border: OutlineInputBorder(),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              TextFormField(
                controller: _cardNumber,
                decoration: const InputDecoration(
                  labelText: 'Номер билета',
                  border: OutlineInputBorder(),
                ),
                validator: V.combine([
                  V.required(),
                  V.pattern(RegExp(r'^RC-\d{6}$'), 'Номер в формате RC-000000'),
                ]),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _issuedAt,
                decoration: const InputDecoration(
                  labelText: 'Дата выдачи',
                  border: OutlineInputBorder(),
                ),
                validator: V.combine([V.required(), V.date()]),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _expiresAt,
                decoration: const InputDecoration(
                  labelText: 'Действует до',
                  border: OutlineInputBorder(),
                ),
                validator: _expiresValidator,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
