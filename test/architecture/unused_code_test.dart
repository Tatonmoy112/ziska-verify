import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/history/domain/repositories/history_repository.dart';
import 'package:ziska_verify/features/history/domain/usecases/check_usecases.dart';
import 'package:ziska_verify/features/history/presentation/bloc/history_bloc.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/repositories/verification_repository.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';
import 'package:ziska_verify/features/verification/presentation/bloc/lookup_bloc.dart';

import 'layer_rules.dart';

class _History extends Mock implements HistoryRepository {}

class _Verification extends Mock implements VerificationRepository {}

const _formats = InputFormats(
  serialMaxDigits: 19,
  qr: CodeFormat(length: 12, characters: 'ABC'),
);

/// TC-ARCH-080 … -082 (docs/test-cases/18-architecture.md): code nothing
/// used is gone, and what the screens show still comes from where it did
/// (production audit P-47).
void main() {
  final lib = readLib('lib');

  /// Each piece P-47 removed: its file and what marked it.
  const gone = <String, String>{
    'core/pagination/paginated_state.dart': 'bool get isLoading',
    'features/verification/presentation/bloc/scan_session_cubit.dart':
        'bool get loading',
    'features/verification/presentation/screens/verifying_view.dart':
        'bool get isShown',
    'core/utils/display_time.dart': 'withOffset(',
    'features/verification/presentation/bloc/lookup_bloc.dart':
        'formatsLoading',
    'features/history/presentation/bloc/history_bloc.dart':
        '    CheckTotals? totals,',
  };

  group('TC-ARCH-080 normal: the code nothing used is gone', () {
    test('the step row widget', () {
      expect(
        lib.keys,
        isNot(contains('shared/widgets/numbered_step_row.dart')),
      );
      expect(lib.values.join(), isNot(contains('NumberedStepRow')));
    });

    for (final MapEntry(key: file, value: mark) in gone.entries) {
      test('$file: $mark', () {
        expect(lib[file], isNotNull, reason: file);
        expect(lib[file], isNot(contains(mark)));
      });
    }
  });

  group('TC-ARCH-081 edge: what the screens show, from where it did', () {
    setUpAll(() {
      registerFallbackValue(const CheckQuery());
      registerFallbackValue(const PageRequest());
    });

    test('History: the first page counts the chips', () async {
      const totals = CheckTotals(
        total: 2,
        valid: 1,
        warning: 1,
        notFound: 0,
        unassigned: 0,
      );
      final repo = _History();
      when(() => repo.getChecks(any(), any())).thenAnswer(
        (_) async => const Success(
          CheckPage(
            page: CursorPage(items: []),
            totals: totals,
          ),
        ),
      );
      final bloc = HistoryBloc(GetChecks(repo))
        ..add(const HistoryQueryChanged(CheckQuery()));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.chipTotals, totals);
      await bloc.close();
    });

    test('the lookup form: no formats and no failure while they load; '
        'Try again clears the failure', () async {
      final repo = _Verification();
      final answer = Completer<Result<InputFormats>>();
      var calls = 0;
      when(repo.getFormats).thenAnswer(
        (_) => ++calls == 1
            ? Future.value(const Err(Failure(NetworkException())))
            : answer.future,
      );
      final bloc = LookupBloc(
        getFormats: GetFormats(repo),
        lookupItem: LookupItem(repo),
      )..add(const FormatsRequested());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.formatsFailure, isNotNull);

      bloc.add(const FormatsRequested());
      await Future<void>.delayed(Duration.zero);
      // Loading again: the form shows its spinner (no failure, no formats).
      expect(bloc.state.formatsFailure, isNull);
      expect(bloc.state.formats, isNull);

      answer.complete(const Success(_formats));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.formats, _formats);
      await bloc.close();
    });
  });

  group('TC-ARCH-082 worst: nothing still names them', () {
    test('neither the app nor the tests', () {
      final names = [
        'NumberedStepRow',
        'numbered_step_row',
        'withOffset',
        'formatsLoading:',
        '.isShown',
      ];
      final hits = <String>[
        for (final f in [
          ...Directory('lib').listSync(recursive: true),
          ...Directory('test').listSync(recursive: true),
        ])
          if (f is File &&
              f.path.endsWith('.dart') &&
              !f.path.endsWith('unused_code_test.dart'))
            for (final n in names)
              if (f.readAsStringSync().contains(n)) '${f.path}: $n',
      ];
      expect(hits, isEmpty);
    });
  });
}
