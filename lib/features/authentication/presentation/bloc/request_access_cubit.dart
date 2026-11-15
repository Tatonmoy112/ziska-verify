import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ziska_verify/core/services/launcher/launcher_service.dart';

enum RequestAccessResult { idle, opened, noApp }

/// Request access (final.md Section 13.9, backend D27): opens an email or a
/// call to the client's office. Nothing is sent to the backend.
class RequestAccessCubit extends Cubit<RequestAccessResult> {
  RequestAccessCubit({
    required LauncherService launcher,
    required this.officeEmail,
    required this.officePhone,
  }) : _launcher = launcher,
       super(RequestAccessResult.idle);

  final LauncherService _launcher;
  final String officeEmail;
  final String officePhone;

  bool get hasPhone => officePhone.isNotEmpty;

  Future<void> email({required String subject, required String body}) async {
    final ok = await _launcher.email(
      to: officeEmail,
      subject: subject,
      body: body,
    );
    emit(ok ? RequestAccessResult.opened : RequestAccessResult.noApp);
  }

  Future<void> call() async {
    final ok = await _launcher.call(officePhone);
    emit(ok ? RequestAccessResult.opened : RequestAccessResult.noApp);
  }
}
