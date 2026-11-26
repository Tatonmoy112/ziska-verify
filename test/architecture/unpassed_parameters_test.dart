import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_otp_field.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_password_field.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_text_field.dart';

/// TC-ARCH-086 … -088 (docs/test-cases/18-architecture.md): the options no
/// caller used are gone; the fields behave as before (production audit
/// P-49). TC-SEC-014: the keyboard does not learn passwords or the code.
void main() {
  Future<TextField> pump(WidgetTester tester, Widget field) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: field),
      ),
    );
    return tester.widget<TextField>(find.byType(TextField));
  }

  group('TC-ARCH-086 normal: a text field as before', () {
    testWidgets('no counter by default; a counter of its own', (
      tester,
    ) async {
      var field = await pump(
        tester,
        const AppTextField(label: 'Note', maxLength: 10),
      );
      expect(field.decoration!.counterText, '');
      expect(field.enableSuggestions, isTrue);

      field = await pump(
        tester,
        const AppTextField(label: 'Note', maxLength: 10, counter: '3/10'),
      );
      expect(field.decoration!.counterText, '3/10');
    });
  });

  group('TC-ARCH-087 edge: secrets the keyboard does not learn '
      '(TC-SEC-014)', () {
    testWidgets('a password: hidden, no suggestions, no autocorrect', (
      tester,
    ) async {
      final field = await pump(
        tester,
        const AppPasswordField(
          label: 'Password',
          showLabel: 'Show',
          hideLabel: 'Hide',
        ),
      );
      expect(field.obscureText, isTrue);
      expect(field.enableSuggestions, isFalse);
      expect(field.autocorrect, isFalse);
    });

    testWidgets('the emailed code: digits, no autocorrect, filled from the '
        'message', (tester) async {
      final field = await pump(tester, const AppOtpField(label: 'Code'));
      expect(field.autocorrect, isFalse);
      expect(field.keyboardType, TextInputType.number);
      expect(field.autofillHints, [AutofillHints.oneTimeCode]);
    });
  });

  group('TC-ARCH-088 worst: the options are gone', () {
    test('none of them is declared', () {
      const gone = <String, List<String>>{
        'lib/shared/design_system/components/inputs/app_text_field.dart': [
          'this.secret',
          'this.showCounter',
          'this.suffix',
        ],
        'lib/shared/design_system/components/inputs/app_search_field.dart': [
          'this.autofocus',
        ],
        'lib/shared/design_system/components/inputs/app_otp_field.dart': [
          'this.errorText',
        ],
        'lib/shared/design_system/components/inputs/app_password_field.dart': [
          'this.hint',
        ],
        'lib/shared/widgets/network_status_banner.dart': ['this.settle'],
        'lib/features/verification/presentation/screens/verifying_view.dart': [
          'this.delay',
        ],
        'lib/features/verification/presentation/widgets/verification_result_card.dart':
            ['this.detail'],
        'lib/features/verification/domain/services/prepare_input.dart': [
          'this.parser',
          'this.normalizer',
          'this.validator',
        ],
        'lib/features/verification/domain/services/parse_stack.dart': [
          '[this._prepare',
        ],
        'lib/features/verification/presentation/bloc/lookup_bloc.dart': [
          'prepareInput',
        ],
        'lib/app/router/app_router.dart': ['RouteGuard? guard'],
      };
      final left = [
        for (final MapEntry(key: path, value: marks) in gone.entries)
          for (final mark in marks)
            if (File(path).readAsStringSync().contains(mark)) '$path: $mark',
      ];
      expect(left, isEmpty);
    });
  });
}
