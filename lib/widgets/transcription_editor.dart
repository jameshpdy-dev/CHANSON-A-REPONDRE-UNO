import 'package:flutter/material.dart';

class TranscriptionEditor extends StatelessWidget {
  const TranscriptionEditor({required this.controller, super.key});
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    minLines: 10,
    maxLines: 24,
    decoration: const InputDecoration(
      labelText: 'Review transcription',
      alignLabelWithHint: true,
      border: OutlineInputBorder(),
    ),
  );
}
