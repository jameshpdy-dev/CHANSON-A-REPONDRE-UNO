import 'package:flutter/material.dart';

class SettingsDropdownTile<T> extends StatelessWidget {
  const SettingsDropdownTile({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
  });
  final String title;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;
  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(title),
    trailing: DropdownButton<T>(
      value: value,
      items: items.entries
          .map(
            (item) =>
                DropdownMenuItem(value: item.key, child: Text(item.value)),
          )
          .toList(),
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    ),
  );
}
