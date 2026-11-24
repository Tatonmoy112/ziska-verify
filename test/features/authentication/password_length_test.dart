import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/features/authentication/domain/services/password_policy.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_password_field.dart';

import '../../ui/ui_helpers.dart';

/// TC-AUTH-101: the password field and the password rule count the same
/// thing — characters (code points), as the backend does (app API guide
/// §3.6; final.md §6). TC-SEC-011: no Android backup.
void main() {
  testWidgets('TC-AUTH-101 the field stops at 128 characters, as the rule '
      'counts them', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await pumpUi(
      tester,
      AppPasswordField(
        fieldKey: const Key('pw'),
        label: 'Password',
        showLabel: 'Show password',
        hideLabel: 'Hide password',
        controller: controller,
      ),
    );
    // 44 Bangla conjuncts: 44 letters on screen, 132 characters (3 each).
    await tester.enterText(find.byKey(const Key('pw')), 'ক্ষ' * 44);
    await tester.pump();
    expect(controller.text.runes.length, 128);
    // The field and the rule agree: what the field holds passes the length
    // rule.
    expect(const PasswordPolicy().check(controller.text).hasLength, isTrue);
  });

  test('TC-SEC-011 the app allows no Android backup', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android:dataExtractionRules='));
    expect(manifest, contains('android:fullBackupContent='));
  });
}
