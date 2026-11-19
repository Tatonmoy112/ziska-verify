import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_colors.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_spacing.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

/// A labelled text field: an upper-case label above the input (Figma).
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.controller,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.errorText,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.style,
    this.fieldKey,
    this.secret = false,
    this.minLines,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.showCounter = false,
    this.counter,
    this.focusNode,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enabled;
  final String? errorText;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextStyle? style;

  /// Key of the inner [TextField], for tests.
  final Key? fieldKey;

  /// Lets the screen move the keyboard focus to the field (the scanner's
  /// "Enter manually" returns to the Check tab with the field focused).
  final FocusNode? focusNode;

  /// A secret the keyboard must not learn or suggest.
  final bool secret;

  /// A note over several lines (Report incident).
  final int? minLines;
  final int? maxLines;
  final TextCapitalization textCapitalization;

  /// Shows "12/1000" under the field when [maxLength] is set.
  final bool showCounter;

  /// A counter of the caller's own (it overrides [showCounter]), for a
  /// limit that is not counted the way [maxLength] counts.
  final String? counter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTypography.fieldLabel),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          key: fieldKey,
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          enabled: enabled,
          maxLength: maxLength,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          autocorrect: false,
          enableSuggestions: !obscureText && !secret,
          minLines: minLines,
          maxLines: obscureText ? 1 : maxLines,
          textCapitalization: textCapitalization,
          // A disabled field is drawn muted, never like an editable value.
          style: enabled
              ? style ?? AppTypography.body
              : (style ?? AppTypography.body).copyWith(
                  color: AppColors.textMuted,
                ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
            suffixIcon: suffix,
            errorText: errorText,
            counterText: counter ?? (showCounter ? null : ''),
            // A long hint wraps instead of ending with "…".
            hintMaxLines: 3,
          ),
        ),
      ],
    );
  }
}
