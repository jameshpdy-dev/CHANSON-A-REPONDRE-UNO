import 'package:flutter/material.dart';

class SettingsSearch extends StatelessWidget {
  const SettingsSearch({required this.onChanged, super.key});
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => TextField(
    onChanged: onChanged,
    decoration: const InputDecoration(
      prefixIcon: Icon(Icons.search_rounded),
      labelText: 'Search settings',
      hintText: 'Background, AI, deck...',
      border: OutlineInputBorder(),
    ),
  );
}
