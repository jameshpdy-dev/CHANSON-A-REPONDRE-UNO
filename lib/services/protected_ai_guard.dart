import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/app_config.dart';
import '../core/app_router.dart';
import '../providers/auth_controller.dart';

class ProfileRouteArguments {
  const ProfileRouteArguments({
    required this.message,
    required this.returnLabel,
  });
  final String message;
  final String returnLabel;
}

Future<bool> requireRealAuthentication(
  BuildContext context, {
  required String featureName,
}) async {
  final auth = context.read<AuthController>();
  if (auth.canUseProtectedAi) return true;

  await context.push<bool>(
    AppRoutes.profile,
    extra: ProfileRouteArguments(
      message: AppConfig.shouldSkipAuthentication
          ? 'Real Supabase login required\n\n'
                'This feature is unavailable in development UI mode.'
          : 'Sign in through Profile to use $featureName.',
      returnLabel: 'Return to $featureName',
    ),
  );
  return context.mounted && auth.canUseProtectedAi;
}
