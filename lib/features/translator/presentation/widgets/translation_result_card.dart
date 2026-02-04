import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/translation_result.dart';

/// Widget to display the translation result with copy functionality
class TranslationResultCard extends StatelessWidget {
  final TranslationResult result;
  final VoidCallback? onCopy;
  final VoidCallback? onDismiss;
  final bool showOriginal;

  const TranslationResultCard({
    super.key,
    required this.result,
    this.onCopy,
    this.onDismiss,
    this.showOriginal = true,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: result.translatedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Translation copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
    onCopy?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!result.isSuccess) {
      return _buildErrorCard(context, theme);
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with language info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${result.sourceLanguage.code.toUpperCase()} → ${result.targetLanguage.code.toUpperCase()}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (onDismiss != null)
                  IconButton(
                    onPressed: onDismiss,
                    icon: const Icon(Icons.close, size: 18),
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Dismiss',
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Original text (optional)
            if (showOriginal) ...[
              Text(
                'Original:',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                    0.3,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  result.originalText,
                  style: theme.textTheme.bodySmall,
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Translation
            Text(
              'Translation:',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: SelectableText(
                result.translatedText,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 8),

            // Copy button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _copyToClipboard(context),
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                result.errorMessage ?? 'Translation failed',
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
            if (onDismiss != null)
              IconButton(
                onPressed: onDismiss,
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: theme.colorScheme.onErrorContainer,
                ),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
}

/// Compact inline translation result for tooltips or overlays
class TranslationTooltip extends StatelessWidget {
  final TranslationResult result;
  final VoidCallback? onCopy;
  final VoidCallback? onExpand;

  const TranslationTooltip({
    super.key,
    required this.result,
    this.onCopy,
    this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!result.isSuccess) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          result.errorMessage ?? 'Translation failed',
          style: TextStyle(color: theme.colorScheme.onErrorContainer),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.translate, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                '${result.sourceLanguage.name} → ${result.targetLanguage.name}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(result.translatedText, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onCopy != null)
                IconButton(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy, size: 16),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Copy',
                ),
              if (onExpand != null)
                IconButton(
                  onPressed: onExpand,
                  icon: const Icon(Icons.open_in_full, size: 16),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Show details',
                ),
            ],
          ),
        ],
      ),
    );
  }
}
