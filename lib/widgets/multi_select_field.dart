import 'package:flutter/material.dart';

class MultiSelectField extends StatelessWidget {
  const MultiSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.initialValue,
    required this.onChanged,
    this.validator,
  });

  final String label;
  final Map<int, String> options;
  final List<int> initialValue;
  final ValueChanged<List<int>> onChanged;
  final FormFieldValidator<List<int>>? validator;

  @override
  Widget build(BuildContext context) {
    return FormField<List<int>>(
      initialValue: initialValue,
      validator: validator,
      builder: (field) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            errorText: field.errorText,
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.entries.map((e) {
              final selected = field.value!.contains(e.key);
              return FilterChip(
                label: Text(e.value),
                selected: selected,
                onSelected: (_) {
                  final next = [...field.value!];
                  selected ? next.remove(e.key) : next.add(e.key);
                  field.didChange(next);
                  onChanged(next);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
