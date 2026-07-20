import 'package:flutter/material.dart';

class AiConnectionStatus extends StatelessWidget {
  const AiConnectionStatus({required this.configured, super.key});
  final bool configured;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(
      configured ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
      color: configured ? Colors.green : Theme.of(context).colorScheme.error,
    ),
    title: Text(configured ? 'AI connection configured' : 'AI not configured'),
    subtitle: Text(
      configured
          ? 'Requests use the configured backend or explicit development mode.'
          : 'Set AI_BACKEND_URL when launching the application.',
    ),
  );
}
