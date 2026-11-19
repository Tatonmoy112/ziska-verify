import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';

const serialStackLimit = 50;

class SerialStackRow {
  const SerialStackRow({required this.serial, required this.result});
  final String serial;
  final LookupResult result;
}

class SerialStackResult {
  const SerialStackResult({required this.session, required this.items});
  final SessionTotals session;
  final List<SerialStackRow> items;
}
