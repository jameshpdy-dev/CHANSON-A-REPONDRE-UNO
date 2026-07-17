import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uno_chanson_2/services/external_chatgpt_service.dart';

void main() {
  test('opens the official ChatGPT login in an external application', () async {
    Uri? openedUri;
    LaunchMode? openedMode;
    final service = ExternalChatGptService(
      launcher: (uri, {required mode}) async {
        openedUri = uri;
        openedMode = mode;
        return true;
      },
    );

    await service.openChatGptLogin();

    expect(openedUri, Uri.parse('https://chatgpt.com/auth/login'));
    expect(openedMode, LaunchMode.externalApplication);
  });

  test('reports a failed external launch', () async {
    final service = ExternalChatGptService(
      launcher: (uri, {required mode}) async => false,
    );

    expect(service.openChatGptLogin(), throwsStateError);
  });
}
