import 'package:flutter/material.dart';
import '../domain/entities/ai_assistant_response.dart';

/// Widget to display AI response with loading and error states
class AIResponseCard extends StatelessWidget {
  final AIAssistantResponse? response;
  final AIAssistantState state;
  final String? errorMessage;
  final VoidCallback? onCopy;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;

  const AIResponseCard({
    super.key,
    this.response,
    required this.state,
    this.errorMessage,
    this.onCopy,
    this.onDismiss,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case AIAssistantState.idle:
        return const SizedBox.shrink();
      case AIAssistantState.loading:
        return _buildLoadingState(context);
      case AIAssistantState.success:
        return _buildSuccessState(context);
      case AIAssistantState.error:
        return _buildErrorState(context);
    }
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'AI is thinking...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            _buildLoadingAnimation(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingAnimation(ThemeData theme) {
    return SizedBox(
      height: 4,
      width: 100,
      child: LinearProgressIndicator(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    final theme = Theme.of(context);

    if (response == null) return const SizedBox.shrink();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI Response',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (response!.responseTime != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '${response!.responseTime!.inMilliseconds}ms',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                if (onCopy != null)
                  IconButton(
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: 'Copy',
                    visualDensity: VisualDensity.compact,
                  ),
                if (onDismiss != null)
                  IconButton(
                    onPressed: onDismiss,
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: 'Dismiss',
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              response!.content,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage ?? 'An error occurred',
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
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.onErrorContainer,
                  side: BorderSide(color: theme.colorScheme.onErrorContainer),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline loading indicator for AI operations
class AILoadingIndicator extends StatefulWidget {
  final String? message;
  final double size;

  const AILoadingIndicator({super.key, this.message, this.size = 24});

  @override
  State<AILoadingIndicator> createState() => _AILoadingIndicatorState();
}

class _AILoadingIndicatorState extends State<AILoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _pulseAnimation,
          child: Icon(
            Icons.auto_awesome,
            size: widget.size,
            color: theme.colorScheme.primary,
          ),
        ),
        if (widget.message != null) ...[
          const SizedBox(width: 8),
          Text(
            widget.message!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
