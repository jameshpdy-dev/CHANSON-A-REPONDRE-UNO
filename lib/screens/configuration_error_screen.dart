import 'package:flutter/material.dart';

import '../core/app_config.dart';

class ConfigurationErrorScreen extends StatelessWidget {
  const ConfigurationErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supplied = AppConfig.rawAiBackendUrl;
    return Scaffold(
      backgroundColor: const Color(0xFF090806),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppConfig.aiBackendConfigurationError ??
                        'AI backend configuration error.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (supplied.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SelectableText(
                      'Supplied value: ${supplied.trim()}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text(
                    'Launch the application with:',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const SelectionArea(
                    child: Text(
                      'flutter run --dart-define=AI_BACKEND_URL=https://your-backend.example.com',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'The URL must use HTTP or HTTPS and include a valid host. Restart after changing the dart-define value.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
