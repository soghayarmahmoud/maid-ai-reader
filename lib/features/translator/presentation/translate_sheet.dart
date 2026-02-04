import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/translation_service.dart';
import '../domain/entities/language.dart';
import '../domain/entities/translation_result.dart';
import '../domain/translate_text.dart';

/// Bottom sheet widget for translating selected PDF text
class TranslateSheet extends StatefulWidget {
  /// The selected text to translate
  final String selectedText;

  /// Optional API key for translation service
  final String? apiKey;

  const TranslateSheet({super.key, required this.selectedText, this.apiKey});

  /// Show the translation sheet as a modal bottom sheet
  static Future<void> show(
    BuildContext context, {
    required String selectedText,
    String? apiKey,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          TranslateSheet(selectedText: selectedText, apiKey: apiKey),
    );
  }

  @override
  State<TranslateSheet> createState() => _TranslateSheetState();
}

class _TranslateSheetState extends State<TranslateSheet> {
  late TranslateTextUseCase _translateUseCase;
  late Language _sourceLanguage;
  late Language _targetLanguage;

  TranslationResult? _translationResult;
  bool _isLoading = false;
  bool _isDetectingLanguage = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeService();
    _sourceLanguage = SupportedLanguages.defaultSourceLanguage;
    _targetLanguage = SupportedLanguages.defaultTargetLanguage;
    _detectSourceLanguage();
  }

  void _initializeService() {
    // Use API key from parameter, or fall back to mock for testing/demo
    // In production, API key should come from secure storage, not hardcoded
    final repository = widget.apiKey != null && widget.apiKey!.isNotEmpty
        ? TranslationService.withApiKey(widget.apiKey!)
        : TranslationService.mock();
    _translateUseCase = TranslateTextUseCase(repository);
  }

  Future<void> _detectSourceLanguage() async {
    if (widget.selectedText.trim().isEmpty) return;

    setState(() => _isDetectingLanguage = true);

    final detected = await _translateUseCase.detectLanguage(
      widget.selectedText,
    );
    if (detected != null && mounted) {
      setState(() {
        _sourceLanguage = detected;
        // Ensure target is different from source
        if (_targetLanguage.code == detected.code) {
          _targetLanguage = SupportedLanguages.all.firstWhere(
            (lang) => lang.code != detected.code,
            orElse: () => SupportedLanguages.defaultTargetLanguage,
          );
        }
        _isDetectingLanguage = false;
      });
    } else if (mounted) {
      setState(() => _isDetectingLanguage = false);
    }
  }

  Future<void> _translate() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _translateUseCase.execute(
      text: widget.selectedText,
      sourceLanguage: _sourceLanguage,
      targetLanguage: _targetLanguage,
    );

    if (mounted) {
      setState(() {
        _translationResult = result;
        _isLoading = false;
        if (!result.isSuccess) {
          _errorMessage = result.errorMessage;
        }
      });
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
      _translationResult = null;
    });
  }

  void _copyToClipboard() {
    if (_translationResult?.translatedText.isNotEmpty == true) {
      Clipboard.setData(
        ClipboardData(text: _translationResult!.translatedText),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Translation copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Row(
            children: [
              Icon(Icons.translate, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Translate Text',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Language selector
          _buildLanguageSelector(theme),
          const SizedBox(height: 16),

          // Original text
          _buildTextSection(
            theme: theme,
            title: 'Original Text',
            text: widget.selectedText,
            isLoading: false,
          ),
          const SizedBox(height: 16),

          // Translate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _translate,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.translate),
              label: Text(_isLoading ? 'Translating...' : 'Translate'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Error message
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Translation result
          if (_translationResult?.isSuccess == true) ...[
            _buildTextSection(
              theme: theme,
              title: 'Translation',
              text: _translationResult!.translatedText,
              isLoading: false,
              showCopyButton: true,
            ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(ThemeData theme) {
    return Row(
      children: [
        // Source language dropdown
        Expanded(
          child: _buildLanguageDropdown(
            label: 'From',
            value: _sourceLanguage,
            isDetecting: _isDetectingLanguage,
            onChanged: (language) {
              if (language != null) {
                setState(() {
                  _sourceLanguage = language;
                  _translationResult = null;
                });
              }
            },
          ),
        ),

        // Swap button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: IconButton(
            onPressed: _swapLanguages,
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Swap languages',
          ),
        ),

        // Target language dropdown
        Expanded(
          child: _buildLanguageDropdown(
            label: 'To',
            value: _targetLanguage,
            onChanged: (language) {
              if (language != null) {
                setState(() {
                  _targetLanguage = language;
                  _translationResult = null;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown({
    required String label,
    required Language value,
    required ValueChanged<Language?> onChanged,
    bool isDetecting = false,
  }) {
    final languages = _translateUseCase.getSupportedLanguages();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (isDetecting) ...[
              const SizedBox(width: 4),
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<Language>(
          value: value,
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
              child: Text(lang.name, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextSection({
    required ThemeData theme,
    required String title,
    required String text,
    required bool isLoading,
    bool showCopyButton = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (showCopyButton)
              IconButton(
                onPressed: _copyToClipboard,
                icon: const Icon(Icons.copy, size: 20),
                tooltip: 'Copy to clipboard',
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor),
          ),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: SelectableText(
                    text,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
        ),
      ],
    );
  }
}
