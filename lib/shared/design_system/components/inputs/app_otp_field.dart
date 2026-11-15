import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_text_field.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

/// A field for the emailed 6-digit code: digits only, exactly 6.
class AppOtpField extends StatelessWidget {
  const AppOtpField({
    required this.label,
    this.controller,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.fieldKey,
    super.key,
  });

  static const length = 6;

  final String label;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      fieldKey: fieldKey,
      label: label,
      controller: controller,
      hint: '••••••',
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.oneTimeCode],
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(length),
      ],
      maxLength: length,
      errorText: errorText,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: AppTypography.headline.copyWith(letterSpacing: 10),
    );
  }
}
