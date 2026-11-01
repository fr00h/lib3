import 'package:flutter/material.dart';

Future<bool> confirm(
  BuildContext context,
  String text, {
  String okLabel = 'Удалить',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Подтверждение'),
      content: Text(text),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(okLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<void> showMessage(BuildContext context, String text) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Удаление невозможно'),
      content: Text(text),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Понятно'),
        ),
      ],
    ),
  );
}
