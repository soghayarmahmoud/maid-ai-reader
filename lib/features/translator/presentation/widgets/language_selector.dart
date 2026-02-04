import 'package:flutter/material.dart';
import '../domain/entities/language.dart';

/// A compact language selector widget for use in toolbars or menus
class LanguageSelector extends StatelessWidget {
  final Language selectedLanguage;
  final List<Language> languages;
  final ValueChanged<Language> onLanguageChanged;
  final String? label;
  final bool showNativeName;
  final bool compact;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.languages,
    required this.onLanguageChanged,
    this.label,
    this.showNativeName = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (compact) {
      return _buildCompactSelector(context, theme);
    }

    return _buildFullSelector(context, theme);
  }

  Widget _buildCompactSelector(BuildContext context, ThemeData theme) {
    return PopupMenuButton<Language>(
      initialValue: selectedLanguage,
      onSelected: onLanguageChanged,
      tooltip: label ?? 'Select language',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedLanguage.code.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
      itemBuilder: (context) => languages.map((lang) {
        return PopupMenuItem<Language>(
          value: lang,
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  lang.code.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  showNativeName ? lang.nativeName : lang.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (lang == selectedLanguage)
                Icon(Icons.check, size: 18, color: theme.colorScheme.primary),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFullSelector(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
        ],
        DropdownButtonFormField<Language>(
          value: selectedLanguage,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: languages.map((lang) {
            return DropdownMenuItem<Language>(
              value: lang,
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      lang.code.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      showNativeName
                          ? '${lang.name} (${lang.nativeName})'
                          : lang.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (lang) {
            if (lang != null) onLanguageChanged(lang);
          },
        ),
      ],
    );
  }
}

/// A row with source and target language selectors with swap button
class LanguagePairSelector extends StatelessWidget {
  final Language sourceLanguage;
  final Language targetLanguage;
  final List<Language> languages;
  final ValueChanged<Language> onSourceChanged;
  final ValueChanged<Language> onTargetChanged;
  final VoidCallback? onSwap;
  final bool compact;

  const LanguagePairSelector({
    super.key,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.languages,
    required this.onSourceChanged,
    required this.onTargetChanged,
    this.onSwap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LanguageSelector(
            selectedLanguage: sourceLanguage,
            languages: languages,
            onLanguageChanged: onSourceChanged,
            label: compact ? null : 'From',
            compact: compact,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: IconButton(
            onPressed: onSwap,
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Swap languages',
            visualDensity: compact ? VisualDensity.compact : null,
          ),
        ),
        Expanded(
          child: LanguageSelector(
            selectedLanguage: targetLanguage,
            languages: languages,
            onLanguageChanged: onTargetChanged,
            label: compact ? null : 'To',
            compact: compact,
          ),
        ),
      ],
    );
  }
}
