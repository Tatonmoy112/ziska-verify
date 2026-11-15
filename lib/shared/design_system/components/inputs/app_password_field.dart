import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_text_field.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

/// A password field with "Show password" (app build guide §4.9). A pasted
/// control character is kept, never removed without telling: the screen's
/// own rule then refuses the password (final.md Section 6.6).
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    required this.label,
    required this.showLabel,
    required this.hideLabel,
    this.controller,
    this.hint,
    this.textInputAction,
    this.autofillHints = const [AutofillHints.password],
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.fieldKey,
    super.key,
  });

  final String label;

  /// "Show password" / "Hide password", localized by the caller.
  final String showLabel;
  final String hideLabel;
  final TextEditingController? controller;
  final String? hint;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Key? fieldKey;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AppTextField(
          fieldKey: widget.fieldKey,
          label: widget.label,
          controller: widget.controller,
          hint: widget.hint,
          prefixIcon: LucideIcons.lock,
          obscureText: !_visible,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          maxLength: 128,
          errorText: widget.errorText,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
        ),
        TextButton(
          onPressed: () => setState(() => _visible = !_visible),
          child: Text(
            _visible ? widget.hideLabel : widget.showLabel,
            style: AppTypography.link,
          ),
        ),
      ],
    );
  }
}
