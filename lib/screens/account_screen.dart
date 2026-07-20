import 'package:flutter/material.dart';
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

const _stageBlack = Color(0xFF080604);
const _stageBrown = Color(0xFF21140D);
const _stageBrownDeep = Color(0xFF140B07);
const _stageGold = Color(0xFFEAB51B);
const _stageGoldMuted = Color(0xFF7A5200);
const _stageIvory = Color(0xFFF4E4BC);
const _stageBeige = Color(0xFFDCC79B);
const _stageRed = Color(0xFFFF6B5F);

String? validateProfileEmail(String? value) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value?.trim() ?? '')
    ? null
    : 'Enter a valid email address.';

String? validateProfilePassword(String? value) {
  if ((value ?? '').isEmpty) return 'Enter your password.';
  if (value!.length < 6) {
    return 'Password must contain at least 6 characters.';
  }
  return null;
}

String? validateProfilePasswordConfirmation({
  required String? value,
  required String password,
}) => value == password ? null : 'Passwords do not match.';

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
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmation = TextEditingController();
  bool registering = false;
  bool rememberMe = false;
  bool obscure = true;
  bool healthRequested = false;
  bool openingChatGpt = false;
  String? localMessage;

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

  bool get authenticationReady =>
      AppConfig.hasAuthConfiguration &&
      context.read<AuthController>().mode !=
          AuthenticationMode.configurationError;

  Future<void> submit() async {
    final auth = context.read<AuthController>();
    if (!authenticationReady) {
      setState(() {
        localMessage =
            'Authentication is not configured for this build. Add valid Supabase settings to enable sign in.';
      });
      return;
    }
    if (!formKey.currentState!.validate()) return;
    final success = registering
        ? await auth.register(email.text, password.text)
        : await auth.signIn(email.text, password.text);
    if (!mounted) return;
    if (success) {
      password.clear();
      confirmation.clear();
      setState(() {
        registering = false;
        localMessage = null;
      });
      if (widget.arguments != null && context.canPop()) {
        context.pop(true);
      }
    } else if (registering &&
        auth.error?.startsWith('Account created.') == true) {
      password.clear();
      confirmation.clear();
      setState(() {
        registering = false;
        localMessage = 'Check your email to confirm your account.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final ai = context.watch<CardAiProvider>();
    final backendOnline = ai.connectionAvailable;
    final protectedAi = auth.canUseProtectedAi && backendOnline;

    return Scaffold(
      backgroundColor: _stageBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_stageBlack, Color(0xFF0D0906)],
              ),
            ),
          ),
          const _CurtainSide(alignment: Alignment.centerLeft),
          const _CurtainSide(alignment: Alignment.centerRight),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 18, 32, 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 720;
                  return Stack(
                    children: [
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'PROFILE',
                          style: TextStyle(
                            color: _stageIvory,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const Align(
                        alignment: Alignment.topRight,
                        child: HomeNavigationButton(),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            narrow ? 0 : 24,
                            26,
                            narrow ? 0 : 24,
                            32,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 820),
                            child: Column(
                              children: [
                                const SizedBox(height: 4),
                                auth.user == null
                                    ? _authPanel(auth)
                                    : _signedInPanel(auth, backendOnline),
                                const SizedBox(height: 14),
                                _statusPanel(auth, ai, protectedAi),
                                const SizedBox(height: 14),
                                _externalChatGptPanel(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _authPanel(AuthController auth) {
    final ready = authenticationReady;
    final controlsEnabled = ready && !auth.busy;
    final message = auth.error ?? localMessage;

    return _ProfilePanel(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              registering ? 'Create your account' : 'Sign in to your account',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: _stageIvory,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Access protected AI features like Chat and Card Transcription.',
              style: TextStyle(color: _stageIvory, fontSize: 15),
            ),
            if (widget.arguments != null) ...[
              const SizedBox(height: 14),
              _InlineNotice(text: widget.arguments!.message),
            ],
            if (!ready) ...[
              const SizedBox(height: 14),
              const _InlineNotice(
                isError: true,
                text:
                    'Authentication is not configured for this build.\nAdd valid Supabase settings to enable sign in.',
              ),
            ],
            if (message != null) ...[
              const SizedBox(height: 14),
              _InlineNotice(
                isError: message.contains('Invalid') ||
                    message.contains('Incorrect') ||
                    message.contains('configured') ||
                    message.contains('unavailable'),
                text: message,
              ),
            ],
            const SizedBox(height: 16),
            _fieldLabel(registering ? 'Email address' : 'Email or username'),
            TextFormField(
              controller: email,
              enabled: !auth.busy,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Enter your email or username',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: validateProfileEmail,
            ),
            const SizedBox(height: 12),
            _fieldLabel('Password'),
            TextFormField(
              controller: password,
              enabled: !auth.busy,
              obscureText: obscure,
              autofillHints: [
                registering
                    ? AutofillHints.newPassword
                    : AutofillHints.password,
              ],
              textInputAction: registering
                  ? TextInputAction.next
                  : TextInputAction.done,
              onFieldSubmitted: (_) {
                if (controlsEnabled && !registering) submit();
              },
              decoration: InputDecoration(
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  tooltip: obscure ? 'Show password' : 'Hide password',
                  onPressed: () => setState(() => obscure = !obscure),
                  icon: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              validator: validateProfilePassword,
            ),
            if (registering) ...[
              const SizedBox(height: 12),
              _fieldLabel('Confirm password'),
              TextFormField(
                controller: confirmation,
                enabled: !auth.busy,
                obscureText: obscure,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (controlsEnabled) submit();
                },
                decoration: const InputDecoration(
                  hintText: 'Confirm your password',
                  prefixIcon: Icon(Icons.lock_reset_outlined),
                ),
                validator: (value) => validateProfilePasswordConfirmation(
                  value: value,
                  password: password.text,
                ),
              ),
            ],
            if (!registering) ...[
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 430;
                  final remember = CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: rememberMe,
                    onChanged: auth.busy
                        ? null
                        : (value) =>
                              setState(() => rememberMe = value ?? false),
                    title: const Text(
                      'Remember me',
                      style: TextStyle(color: _stageIvory),
                    ),
                  );
                  final forgot = TextButton(
                    onPressed: controlsEnabled
                        ? () => _resetPassword(auth)
                        : null,
                    child: const Text('Forgot password?'),
                  );
                  return compact
                      ? Column(
                          children: [
                            remember,
                            Align(
                              alignment: Alignment.centerRight,
                              child: forgot,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: remember),
                            forgot,
                          ],
                        );
                },
              ),
            ],
            const SizedBox(height: 12),
            _PrimaryGoldButton(
              onPressed: controlsEnabled ? submit : null,
              icon: registering ? Icons.person_add_alt_1 : Icons.login,
              loading: auth.busy,
              label: registering ? 'CREATE ACCOUNT' : 'SIGN IN',
            ),
            const SizedBox(height: 14),
            if (!registering) ...[
              const _OrDivider(),
              const SizedBox(height: 14),
              _OutlinedGoldButton(
                onPressed: controlsEnabled
                    ? () {
                        auth.clearError();
                        setState(() {
                          registering = true;
                          localMessage = null;
                        });
                      }
                    : null,
                icon: Icons.group_add,
                label: 'CREATE ACCOUNT',
              ),
            ] else
              TextButton(
                onPressed: auth.busy
                    ? null
                    : () {
                        auth.clearError();
                        setState(() {
                          registering = false;
                          localMessage = null;
                        });
                      },
                child: const Text('BACK TO SIGN IN'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _signedInPanel(AuthController auth, bool backendOnline) {
    final user = auth.user!;
    return _ProfilePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your account',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _stageIvory,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          _AccountLine(label: 'Email', value: user.email),
          const _AccountLine(label: 'Session', value: 'Active'),
          _AccountLine(
            label: 'AI access',
            value: backendOnline ? 'Available' : 'Backend unavailable',
          ),
          const SizedBox(height: 18),
          _PrimaryGoldButton(
            onPressed: backendOnline ? () => context.go(AppRoutes.aiChat) : null,
            icon: Icons.smart_toy_outlined,
            label: 'OPEN AI CHAT',
          ),
          const SizedBox(height: 10),
          _OutlinedGoldButton(
            onPressed: () => context.go(AppRoutes.cards),
            icon: Icons.document_scanner_outlined,
            label: 'OPEN CARD TRANSCRIPTION',
          ),
          const SizedBox(height: 10),
          _OutlinedGoldButton(
            onPressed: auth.busy ? null : () => _signOut(auth),
            icon: Icons.logout,
            label: 'SIGN OUT',
          ),
          if (widget.arguments != null) ...[
            const SizedBox(height: 10),
            _PrimaryGoldButton(
              onPressed: () => context.pop(true),
              icon: Icons.arrow_forward,
              label: widget.arguments!.returnLabel.toUpperCase(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusPanel(
    AuthController auth,
    CardAiProvider ai,
    bool protectedAi,
  ) => _ProfilePanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Session status',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: _stageIvory,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Icon(
              auth.user == null
                  ? Icons.error_outline
                  : Icons.check_circle_outline,
              color: auth.user == null ? _stageRed : _stageGold,
              size: 22,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Account session',
                style: TextStyle(
                  color: _stageIvory,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              auth.user == null ? 'Not signed in' : 'Signed in',
              style: const TextStyle(
                color: _stageIvory,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Divider(height: 28, color: Color(0x99DCC79B)),
        Text(
          protectedAi
              ? 'Protected AI access: Available'
              : auth.user == null
              ? 'Protected AI access: Disabled - sign in required'
              : 'Protected AI access: Backend unavailable',
          style: const TextStyle(color: _stageIvory),
        ),
        const SizedBox(height: 12),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          iconColor: _stageIvory,
          collapsedIconColor: _stageIvory,
          title: const Text(
            'Configuration status',
            style: TextStyle(
              color: _stageIvory,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          children: [
            ConfigurationStatusRow(
              label: 'Supabase URL',
              status: AppConfig.isValidSupabaseUrl(AppConfig.supabaseUrl)
                  ? 'Configured'
                  : 'Missing',
              isValid: AppConfig.isValidSupabaseUrl(AppConfig.supabaseUrl),
            ),
            ConfigurationStatusRow(
              label: 'Supabase client key',
              status: AppConfig.isValidSupabaseClientKey(
                AppConfig.supabaseClientKey,
              )
                  ? 'Configured'
                  : 'Missing or placeholder',
              isValid: AppConfig.isValidSupabaseClientKey(
                AppConfig.supabaseClientKey,
              ),
            ),
            ConfigurationStatusRow(
              label: 'AI backend URL',
              status: AppConfig.hasValidAiBackend ? 'Configured' : 'Missing',
              isValid: AppConfig.hasValidAiBackend,
            ),
            ConfigurationStatusRow(
              label: 'Supabase initialization',
              status: auth.mode == AuthenticationMode.configurationError
                  ? 'Failed'
                  : AppConfig.hasAuthConfiguration
                  ? 'Ready'
                  : 'Missing',
              isValid: AppConfig.hasAuthConfiguration &&
                  auth.mode != AuthenticationMode.configurationError,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => context.go(AppRoutes.settings),
                icon: const Icon(Icons.settings),
                label: const Text('Open settings'),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _externalChatGptPanel() => _ProfilePanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'External ChatGPT website',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: _stageIvory,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'ChatGPT opens separately in your browser.\n\n'
          'Signing into ChatGPT does not sign you into this application and '
          'does not enable protected AI features here. Use the application '
          'login above to access Chat and Card Transcription.',
          style: TextStyle(color: _stageIvory),
        ),
        const SizedBox(height: 16),
        _OutlinedGoldButton(
          onPressed: openingChatGpt ? null : _openChatGpt,
          icon: Icons.open_in_new,
          loading: openingChatGpt,
          label: 'OPEN CHATGPT IN BROWSER',
        ),
      ],
    ),
  );

  Widget _fieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      label,
      style: const TextStyle(
        color: _stageIvory,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Future<void> _openChatGpt() async {
    setState(() => openingChatGpt = true);
    try {
      await widget.externalChatGptService.openChatGptLogin();
    } on Object {
      if (mounted) {
        setState(() => localMessage = 'Could not open ChatGPT in the browser.');
      }
    } finally {
      if (mounted) setState(() => openingChatGpt = false);
    }
  }

  Future<void> _resetPassword(AuthController auth) async {
    if (!authenticationReady) {
      setState(() {
        localMessage =
            'Authentication is not configured for this build. Add valid Supabase settings to enable sign in.';
      });
      return;
    }
    final validation = validateProfileEmail(email.text);
    if (validation != null) {
      setState(() => localMessage = validation);
      return;
    }
    final sent = await auth.sendPasswordReset(email.text);
    if (sent && mounted) {
      setState(() {
        localMessage =
            'Password reset instructions have been sent if the account exists.';
      });
    }
  }

  Future<void> _signOut(AuthController auth) async {
    await auth.signOut();
    email.clear();
    password.clear();
    confirmation.clear();
    if (mounted) {
      setState(() {
        registering = false;
        localMessage = null;
      });
    }
  }
}

class _CurtainSide extends StatelessWidget {
  const _CurtainSide({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width < 560) return const SizedBox.shrink();
        final curtainWidth = width < 900 ? 92.0 : 210.0;
        return Align(
          alignment: alignment,
          child: SizedBox(
            width: curtainWidth,
            height: double.infinity,
            child: Image.asset(
              'assets/images/closed_curtains.png',
              fit: BoxFit.cover,
              alignment: alignment,
              opacity: const AlwaysStoppedAnimation(0.86),
            ),
          ),
        );
      },
    ),
  );
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_stageBrown, _stageBrownDeep],
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _stageGoldMuted),
      boxShadow: const [
        BoxShadow(
          color: Color(0x88000000),
          blurRadius: 24,
          offset: Offset(0, 14),
        ),
      ],
    ),
    child: Padding(padding: const EdgeInsets.all(22), child: child),
  );
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.text, this.isError = false});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: (isError ? _stageRed : _stageGold).withValues(alpha: 0.10),
      border: Border.all(
        color: (isError ? _stageRed : _stageGold).withValues(alpha: 0.70),
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(color: isError ? _stageRed : _stageIvory),
      ),
    ),
  );
}

class _PrimaryGoldButton extends StatelessWidget {
  const _PrimaryGoldButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool loading;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: loading ? null : onPressed,
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      backgroundColor: _stageGold,
      disabledBackgroundColor: _stageGold.withValues(alpha: 0.35),
      foregroundColor: _stageBlack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    ),
    icon: loading
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(icon),
    label: Text(label),
  );
}

class _OutlinedGoldButton extends StatelessWidget {
  const _OutlinedGoldButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool loading;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: loading ? null : onPressed,
    style: OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(46),
      foregroundColor: _stageGold,
      side: const BorderSide(color: _stageGoldMuted),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
    ),
    icon: loading
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(icon),
    label: Text(label),
  );
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Expanded(child: Divider(color: _stageGoldMuted)),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text('OR', style: TextStyle(color: _stageBeige)),
      ),
      Expanded(child: Divider(color: _stageGoldMuted)),
    ],
  );
}

class _AccountLine extends StatelessWidget {
  const _AccountLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: const TextStyle(color: _stageBeige)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: _stageIvory,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}
