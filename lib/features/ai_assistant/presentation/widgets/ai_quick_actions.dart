import 'package:flutter/material.dart';
import '../domain/entities/ai_query.dart';
import 'ai_assistant_sheet.dart';

/// Quick action buttons for common AI operations on selected text
class AIQuickActions extends StatelessWidget {
  /// The selected text to process
  final String selectedText;

  /// Additional context
  final String? context;

  /// Document context
  final DocumentContext? documentContext;

  /// API key for AI service
  final String? apiKey;

  /// Callback when an action is triggered
  final void Function(AIQueryType)? onActionTriggered;

  const AIQuickActions({
    super.key,
    required this.selectedText,
    this.context,
    this.documentContext,
    this.apiKey,
    this.onActionTriggered,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QuickActionButton(
          icon: Icons.lightbulb_outline,
          label: 'Explain',
          onTap: () => _showAssistant(context, AIQueryType.explain),
        ),
        _QuickActionButton(
          icon: Icons.summarize,
          label: 'Summarize',
          onTap: () => _showAssistant(context, AIQueryType.summarize),
        ),
        _QuickActionButton(
          icon: Icons.menu_book,
          label: 'Define',
          onTap: () => _showAssistant(context, AIQueryType.define),
        ),
        _QuickActionButton(
          icon: Icons.question_answer,
          label: 'Ask',
          onTap: () => _showAssistant(context, AIQueryType.question),
        ),
      ],
    );
  }

  void _showAssistant(BuildContext context, AIQueryType queryType) {
    onActionTriggered?.call(queryType);
    AIAssistantSheet.show(
      context,
      selectedText: selectedText,
      surroundingContext: this.context,
      documentContext: documentContext,
      apiKey: apiKey,
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 4),
              Text(label, style: theme.textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

/// Floating action menu for AI operations
class AIFloatingMenu extends StatefulWidget {
  final String selectedText;
  final String? context;
  final DocumentContext? documentContext;
  final String? apiKey;
  final Offset position;

  const AIFloatingMenu({
    super.key,
    required this.selectedText,
    required this.position,
    this.context,
    this.documentContext,
    this.apiKey,
  });

  /// Show as an overlay
  static OverlayEntry show(
    BuildContext context, {
    required String selectedText,
    required Offset position,
    String? surroundingContext,
    DocumentContext? documentContext,
    String? apiKey,
  }) {
    final overlay = OverlayEntry(
      builder: (context) => AIFloatingMenu(
        selectedText: selectedText,
        position: position,
        context: surroundingContext,
        documentContext: documentContext,
        apiKey: apiKey,
      ),
    );

    Overlay.of(context).insert(overlay);
    return overlay;
  }

  @override
  State<AIFloatingMenu> createState() => _AIFloatingMenuState();
}

class _AIFloatingMenuState extends State<AIFloatingMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      // Remove overlay - parent should handle this
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    // Calculate position to keep menu on screen
    double left = widget.position.dx;
    double top = widget.position.dy;

    const menuWidth = 200.0;
    const menuHeight = 180.0;

    if (left + menuWidth > screenSize.width) {
      left = screenSize.width - menuWidth - 16;
    }
    if (top + menuHeight > screenSize.height) {
      top = widget.position.dy - menuHeight - 16;
    }

    return Stack(
      children: [
        // Backdrop
        Positioned.fill(
          child: GestureDetector(
            onTap: _dismiss,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),
        ),

        // Menu
        Positioned(
          left: left,
          top: top,
          child: ScaleTransition(
            scale: _scaleAnimation,
            alignment: Alignment.topLeft,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: menuWidth,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMenuItem(
                        context,
                        icon: Icons.auto_awesome,
                        label: 'Ask AI',
                        color: theme.colorScheme.primary,
                        onTap: () => _showSheet(context),
                      ),
                      const Divider(height: 1),
                      _buildMenuItem(
                        context,
                        icon: Icons.lightbulb_outline,
                        label: 'Explain',
                        onTap: () => _quickAction(context, AIQueryType.explain),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.summarize,
                        label: 'Summarize',
                        onTap: () =>
                            _quickAction(context, AIQueryType.summarize),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.menu_book,
                        label: 'Define',
                        onTap: () => _quickAction(context, AIQueryType.define),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.analytics,
                        label: 'Analyze',
                        onTap: () => _quickAction(context, AIQueryType.analyze),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? theme.colorScheme.onSurface),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: color != null ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    _dismiss();
    AIAssistantSheet.show(
      context,
      selectedText: widget.selectedText,
      surroundingContext: widget.context,
      documentContext: widget.documentContext,
      apiKey: widget.apiKey,
    );
  }

  void _quickAction(BuildContext context, AIQueryType type) {
    _dismiss();
    // Could implement direct quick action here
    // For now, show sheet with pre-selected type
    AIAssistantSheet.show(
      context,
      selectedText: widget.selectedText,
      surroundingContext: widget.context,
      documentContext: widget.documentContext,
      apiKey: widget.apiKey,
    );
  }
}

/// Extension for easy context menu integration
extension AIAssistantContextExtension on BuildContext {
  /// Show AI assistant sheet for selected text
  Future<void> showAIAssistant({
    required String selectedText,
    String? context,
    DocumentContext? documentContext,
    String? apiKey,
  }) {
    return AIAssistantSheet.show(
      this,
      selectedText: selectedText,
      surroundingContext: context,
      documentContext: documentContext,
      apiKey: apiKey,
    );
  }
}
