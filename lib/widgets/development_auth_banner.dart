import 'package:flutter/material.dart';

import '../core/app_router.dart';

class DevelopmentAuthBanner extends StatelessWidget {
  const DevelopmentAuthBanner({super.key});

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFF6A3900),
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.developer_mode, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Development UI mode. The application interface is available '
                'for testing. '
                'Protected AI requests require a real Supabase login.',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () => AppRouter.router.go(AppRoutes.profile),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('Configure Supabase'),
            ),
          ],
        ),
      ),
    ),
  );
}
