import 'package:url_launcher/url_launcher.dart';
import 'package:ziska_verify/core/services/launcher/launcher_service.dart';

class UrlLauncherService implements LauncherService {
  const UrlLauncherService();

  @override
  Future<bool> email({
    required String to,
    required String subject,
    required String body,
  }) => _open(
    Uri(
      scheme: 'mailto',
      path: to,
      // `queryParameters` would encode spaces as `+`, which mail apps show.
      query:
          'subject=${Uri.encodeComponent(subject)}'
          '&body=${Uri.encodeComponent(body)}',
    ),
  );

  @override
  Future<bool> call(String phone) =>
      _open(Uri(scheme: 'tel', path: phone.replaceAll(' ', '')));

  Future<bool> _open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Exception {
      return false;
    }
  }
}
