import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/app_config.dart';
import '../core/app_router.dart';
import '../providers/auth_controller.dart';
import '../providers/card_ai_provider.dart';
import '../services/external_chatgpt_service.dart';
import '../services/protected_ai_guard.dart';
import '../widgets/configuration_status_row.dart';
import '../widgets/home_navigation_button.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({
    this.arguments,
    this.externalChatGptService = const ExternalChatGptService(),
    super.key,
  });
  final ProfileRouteArguments? arguments;
  final ExternalChatGptService externalChatGptService;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  static const _launchTemplate =
      'flutter run -d windows `\n'
      '  --dart-define=AI_BACKEND_URL=http://127.0.0.1:3000 `\n'
      '  --dart-define=SUPABASE_URL=https://REAL_PROJECT_ID.supabase.co `\n'
      '  --dart-define=SUPABASE_ANON_KEY=REAL_PUBLISHABLE_KEY `\n'
      '  --dart-define=SKIP_AUTH_FOR_DEVELOPMENT=false';

  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmation = TextEditingController();
  bool registering = false;
  bool obscure = true;
  bool healthRequested = false;
  bool openingChatGpt = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (healthRequested) return;
    healthRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CardAiProvider>().testConnection();
    });
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confirmation.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    final success = registering
        ? await auth.register(email.text, password.text)
        : await auth.signIn(email.text, password.text);
    if (!mounted) return;
    if (success) {
      setState(() => registering = false);
    } else if (registering &&
        auth.error?.startsWith('Account created.') == true) {
      setState(() => registering = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(auth.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final ai = context.watch<CardAiProvider>();
    final backendOnline = ai.connectionAvailable;
    final protectedAi = auth.canUseProtectedAi && backendOnline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: HomeNavigationButton(),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            children: [
              if (widget.arguments != null) ...[
                Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(widget.arguments!.message),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _statusCard(auth, ai, protectedAi),
              const SizedBox(height: 16),
              auth.user != null
                  ? _authenticated(auth, backendOnline)
                  : AppConfig.hasAuthConfiguration
                  ? _authForm(auth)
                  : _configurationPanel(auth, ai),
              const SizedBox(height: 16),
              _externalChatGptPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusCard(
    AuthController auth,
    CardAiProvider ai,
    bool protectedAi,
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Session status', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ConfigurationStatusRow(
            label: 'UI access mode',
            status: AppConfig.shouldSkipAuthentication
                ? 'Development bypass'
                : 'Standard',
            isValid: true,
          ),
          ConfigurationStatusRow(
            label: 'Account session',
            status: auth.user == null ? 'Not signed in' : 'Real session',
            isValid: auth.user != null,
          ),
          const Divider(height: 24),
          Text(
            protectedAi
                ? 'Protected AI access: Enabled'
                : auth.user == null
                ? 'Protected AI access: Disabled - sign in required'
                : 'Protected AI access: Disabled - backend unavailable',
          ),
          const SizedBox(height: 8),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            initiallyExpanded: false,
            title: const Text('Configuration status'),
            children: [
              ConfigurationStatusRow(
                label: 'Backend URL',
                status: AppConfig.hasValidAiBackend ? 'Configured' : 'Missing',
                isValid: AppConfig.hasValidAiBackend,
              ),
              ConfigurationStatusRow(
                label: 'Supabase URL',
                status: AppConfig.isValidSupabaseUrl(AppConfig.supabaseUrl)
                    ? 'Configured'
                    : 'Missing or invalid',
                isValid: AppConfig.isValidSupabaseUrl(AppConfig.supabaseUrl),
              ),
              ConfigurationStatusRow(
                label: 'Supabase key',
                status:
                    AppConfig.isValidSupabaseClientKey(
                      AppConfig.supabaseAnonKey,
                    )
                    ? 'Configured'
                    : 'Missing or placeholder',
                isValid: AppConfig.isValidSupabaseClientKey(
                  AppConfig.supabaseAnonKey,
                ),
              ),
              ConfigurationStatusRow(
                label: 'Backend',
                status: ai.connectionChecking
                    ? 'Checking...'
                    : ai.connectionAvailable
                    ? 'Online'
                    : 'Offline',
                isValid: ai.connectionAvailable,
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _configurationPanel(AuthController auth, CardAiProvider ai) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Supabase configuration required',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          const Text(
            'Real account login is unavailable because the application was '
            'launched without valid Supabase credentials.',
          ),
          const SizedBox(height: 14),
          const ConfigurationStatusRow(
            label: 'Supabase URL',
            status: 'Missing',
            isValid: false,
          ),
          const ConfigurationStatusRow(
            label: 'Supabase client key',
            status: 'Missing or placeholder',
            isValid: false,
          ),
          const SizedBox(height: 14),
          const SelectableText(_launchTemplate),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => context.go(AppRoutes.settings),
            icon: const Icon(Icons.settings),
            label: const Text('Open authentication settings'),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              await Clipboard.setData(
                const ClipboardData(text: _launchTemplate),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Launch template copied.')),
                );
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy launch-command template'),
          ),
        ],
      ),
    ),
  );

  Widget _authForm(AuthController auth) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              registering ? 'Create account' : 'Sign in to your profile',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (AppConfig.shouldSkipAuthentication) ...[
              const SizedBox(height: 8),
              const Text(
                'Development bypass remains active for UI access. A real '
                'session is still required for protected AI requests.',
              ),
            ],
            if (auth.error != null) ...[
              const SizedBox(height: 12),
              Text(
                auth.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: email,
              enabled: !auth.busy,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) =>
                  RegExp(
                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                  ).hasMatch(value?.trim() ?? '')
                  ? null
                  : 'Enter a valid email address.',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: password,
              enabled: !auth.busy,
              obscureText: obscure,
              onFieldSubmitted: (_) {
                if (!auth.busy) submit();
              },
              autofillHints: [
                registering
                    ? AutofillHints.newPassword
                    : AutofillHints.password,
              ],
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  tooltip: obscure ? 'Show password' : 'Hide password',
                  onPressed: () => setState(() => obscure = !obscure),
                  icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                ),
              ),
              validator: (value) => (value?.length ?? 0) < 8
                  ? 'Use at least 8 characters.'
                  : null,
            ),
            if (registering) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmation,
                enabled: !auth.busy,
                obscureText: obscure,
                onFieldSubmitted: (_) {
                  if (!auth.busy) submit();
                },
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                ),
                validator: (value) =>
                    value == password.text ? null : 'Passwords do not match.',
              ),
            ],
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: auth.busy ? null : submit,
              icon: auth.busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(registering ? Icons.person_add : Icons.login),
              label: Text(registering ? 'Create account' : 'Sign in'),
            ),
            TextButton(
              onPressed: auth.busy
                  ? null
                  : () {
                      auth.clearError();
                      setState(() => registering = !registering);
                    },
              child: Text(registering ? 'Back to sign in' : 'Create account'),
            ),
            if (!registering)
              TextButton(
                onPressed: auth.busy ? null : () => _resetPassword(auth),
                child: const Text('Forgot password?'),
              ),
          ],
        ),
      ),
    ),
  );

  Widget _authenticated(AuthController auth, bool backendOnline) {
    final user = auth.user!;
    final shortId = user.id.length > 10
        ? '${user.id.substring(0, 8)}...'
        : user.id;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Signed in', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('Email: ${user.email}'),
            Text('User ID: $shortId'),
            Text('Provider: ${user.provider}'),
            const Text('Session: Active'),
            Text(
              'Protected AI access: '
              '${backendOnline ? 'Enabled' : 'Disabled - backend unavailable'}',
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: auth.busy ? null : auth.refreshSession,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh session'),
            ),
            OutlinedButton.icon(
              onPressed: auth.busy ? null : auth.signOut,
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
            if (widget.arguments != null)
              FilledButton(
                onPressed: () => context.pop(true),
                child: Text(widget.arguments!.returnLabel),
              ),
          ],
        ),
      ),
    );
  }

  Widget _externalChatGptPanel() => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'External ChatGPT website',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          const Text(
            'ChatGPT opens separately in your browser.\n\n'
            'Signing into ChatGPT does not sign you into this application and '
            'does not enable protected AI features here. Use the application '
            'login above to access Chat and Card Transcription.',
          ),
          const SizedBox(height: 16),
          Tooltip(
            message: 'Open the official ChatGPT website in your browser',
            child: OutlinedButton.icon(
              onPressed: openingChatGpt ? null : _openChatGpt,
              icon: openingChatGpt
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.open_in_new),
              label: const Text('Open ChatGPT in browser'),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _openChatGpt() async {
    setState(() => openingChatGpt = true);
    try {
      await widget.externalChatGptService.openChatGptLogin();
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open ChatGPT in the browser.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => openingChatGpt = false);
    }
  }

  Future<void> _resetPassword(AuthController auth) async {
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email address first.')),
      );
      return;
    }
    final sent = await auth.sendPasswordReset(email.text);
    if (sent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'If an account exists for this email, password-reset instructions '
            'have been sent.',
          ),
        ),
      );
    }
  }
}
