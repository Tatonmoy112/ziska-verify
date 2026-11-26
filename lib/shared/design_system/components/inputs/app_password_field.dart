import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/core/utils/text_limits.dart';
import 'package:ziska_verify/shared/design_system/components/inputs/app_text_field.dart';
import 'package:ziska_verify/shared/design_system/tokens/app_typography.dart';

/// A password field with "Show password" (app build guide §4.9). A pasted
/// control character is kept, never removed without telling: the screen's
/// own rule then refuses the password (final.md §6).
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    required this.label,
    required this.showLabel,
    required this.hideLabel,
    this.controller,
    this.textInputAction,
    this.autofillHints = const [AutofillHints.password],
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.fieldKey,
    this.enabled = true,
    super.key,
  });

  final String label;

  /// "Show password" / "Hide password", localized by the caller.
  final String showLabel;
  final String hideLabel;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// False while a request runs: the value cannot change under it.
  final bool enabled;

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
          enabled: widget.enabled,
          fieldKey: widget.fieldKey,
          label: widget.label,
          controller: widget.controller,
          prefixIcon: LucideIcons.lock,
          obscureText: !_visible,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          // 128 characters as the backend and PasswordPolicy count them
          // (code points), not as the screen shows them (final.md 6.6).
          inputFormatters: const [CodePointLimit(128)],
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

/// At most [max] characters counted as code points, as the backend counts
/// a password (app API guide §3.6) or a report's note (§6.1). A longer edit
/// is cut at a whole character.
///
/// With [outerSpaceFree], the spaces and line breaks around the text do not
/// count: the backend removes them before counting (a report's note, §6).
class CodePointLimit extends TextInputFormatter {
  const CodePointLimit(this.max, {this.outerSpaceFree = false});

  final int max;
  final bool outerSpaceFree;

  /// The characters of [text] that count.
  static int counted(String text, {bool outerSpaceFree = false}) =>
      (outerSpaceFree ? text.trim() : text).runes.length;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final all = newValue.text;
    final body = outerSpaceFree ? all.trim() : all;
    final runes = body.runes;
    if (runes.length <= max) return newValue;
    // The spaces before the text stay; it is cut after [max] of its own.
    final before = outerSpaceFree ? all.length - all.trimLeft().length : 0;
    final text =
        all.substring(0, before) + String.fromCharCodes(runes.take(max));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// At most [max] UTF-16 units, as the server counts a name or a search
/// (an emoji counts two). A longer edit is cut at a whole character.
class Utf16Limit extends TextInputFormatter {
  const Utf16Limit(this.max);

  final int max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length <= max) return newValue;
    final text = TextLimits.fitUtf16(newValue.text, max);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
