import 'package:flutter/material.dart';
import '../services/card_ai_service.dart';

class DiscussionModeSelector extends StatelessWidget {
  const DiscussionModeSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });
  final DiscussionMode value;
  final ValueChanged<DiscussionMode> onChanged;
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<DiscussionMode>(
    initialValue: value,
    decoration: const InputDecoration(labelText: 'Discussion mode'),
    items: DiscussionMode.values
        .map((mode) => DropdownMenuItem(value: mode, child: Text(_label(mode))))
        .toList(),
    onChanged: (mode) {
      if (mode != null) onChanged(mode);
    },
  );
  static String _label(DiscussionMode mode) => switch (mode) {
    DiscussionMode.general => 'General discussion',
    DiscussionMode.literary => 'Literary analysis',
    DiscussionMode.psychological => 'Psychological interpretation',
    DiscussionMode.historical => 'Historical context',
    DiscussionMode.creative => 'Creative response',
    DiscussionMode.translation => 'Translation',
    DiscussionMode.summary => 'Summary',
    DiscussionMode.factCheck => 'Fact check',
  };
}
