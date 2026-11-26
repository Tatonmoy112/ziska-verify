import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';

/// A search field (final.md §14.1): a search icon, the [hint], and,
/// when [onClear] is set, a labelled clear button while there is text.
/// History, Retail users, and the retail user picker.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    required this.hint,
    required this.onChanged,
    this.controller,
    this.onClear,
    this.maxLength,
    this.fieldKey,
    super.key,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  /// Clears the search; the clear button shows only while there is text
  /// (needs [controller]).
  final VoidCallback? onClear;
  final int? maxLength;

  /// Key of the inner [TextField], for tests.
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final field = controller;
    Widget build({required bool hasText}) => TextField(
      key: fieldKey,
      controller: field,
      maxLength: maxLength,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(LucideIcons.search, size: 20),
        counterText: '',
        hintMaxLines: 3,
        suffixIcon: onClear == null || !hasText
            ? null
            : IconButton(
                tooltip: l10n.clearSearch,
                icon: const Icon(LucideIcons.x, size: 18),
                onPressed: onClear,
              ),
      ),
    );
    if (field == null) return build(hasText: false);
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: field,
      builder: (context, value, _) => build(hasText: value.text.isNotEmpty),
    );
  }
}
