import 'package:flutter/material.dart';

class AuthConfigurationScreen extends StatelessWidget {
  const AuthConfigurationScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            children: [
              const Icon(Icons.admin_panel_settings_outlined, size: 64),
              const SizedBox(height: 20),
              Text(
                'Application authentication is not configured',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              const Text(
                'Configure a Supabase project and launch with both values:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const SelectableText(
                'flutter run -d windows '
                '--dart-define=AI_BACKEND_URL=http://127.0.0.1:3000 '
                '--dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co '
                '--dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
