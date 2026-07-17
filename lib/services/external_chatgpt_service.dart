import 'package:url_launcher/url_launcher.dart';

typedef ExternalUrlLauncher =
    Future<bool> Function(Uri uri, {required LaunchMode mode});

class ExternalChatGptService {
  const ExternalChatGptService({ExternalUrlLauncher? launcher})
    : _launcher = launcher ?? launchUrl;

  static final Uri loginUri = Uri.parse('https://chatgpt.com/auth/login');
  final ExternalUrlLauncher _launcher;

  Future<void> openChatGptLogin() async {
    final launched = await _launcher(
      loginUri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      throw StateError('Could not open ChatGPT in the external browser.');
    }
  }
}
