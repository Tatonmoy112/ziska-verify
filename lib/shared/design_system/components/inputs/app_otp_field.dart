import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ziska_verify/core/utils/ascii_digits.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_text_field.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

/// A field for the emailed 6-digit code: digits only, exactly 6.
class AppOtpField extends StatelessWidget {
  const AppOtpField({
    required this.label,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.fieldKey,
    this.enabled = true,
    super.key,
  });

  static const length = 6;

  final String label;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// False while a request runs: the value cannot change under it.
  final bool enabled;

  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      enabled: enabled,
      fieldKey: fieldKey,
      label: label,
      controller: controller,
      hint: '••••••',
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.oneTimeCode],
      inputFormatters: const [CodeInputFormatter()],
      maxLength: length,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: AppTypography.headline.copyWith(letterSpacing: 10),
    );
  }
}

/// The 6-digit code as typed or pasted (final.md §6):
/// - Bangla and other digits read as `0`–`9` (a Bangla keyboard);
/// - a pasted message holding exactly one group of 6 digits ("Your code for
///   2026: 123456") gives that group;
/// - otherwise its digits in order, the first 6.
class CodeInputFormatter extends TextInputFormatter {
  const CodeInputFormatter();

  static final _group = RegExp('(?<![0-9])[0-9]{6}(?![0-9])');
  static final _notDigit = RegExp('[^0-9]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = toAsciiDigits(newValue.text);
    final groups = _group.allMatches(text).toList();
    final digits = groups.length == 1 && text.length > AppOtpField.length
        ? groups.single.group(0)!
        : text.replaceAll(_notDigit, '');
    final code = digits.length > AppOtpField.length
        ? digits.substring(0, AppOtpField.length)
        : digits;
    if (code == newValue.text) return newValue;
    return TextEditingValue(
      text: code,
      selection: TextSelection.collapsed(offset: code.length),
    );
  }
}
