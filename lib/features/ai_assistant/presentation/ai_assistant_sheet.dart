import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/ai_assistant_service.dart';
import '../domain/entities/ai_query.dart';
import '../domain/entities/ai_assistant_response.dart';
import '../domain/usecases/ask_ai_usecase.dart';

/// Bottom sheet for AI assistant interactions with selected PDF text
class AIAssistantSheet extends StatefulWidget {
  /// The selected text from the PDF
  final String selectedText;

  /// Additional context from surrounding text
  final String? context;

  /// Document context for better AI responses
  final DocumentContext? documentContext;

  /// API key for AI service (optional, uses mock if not provided)
  final String? apiKey;

  const AIAssistantSheet({
    super.key,
    required this.selectedText,
    this.context,
    this.documentContext,
    this.apiKey,
  });

  /// Show the AI assistant sheet as a modal bottom sheet
  static Future<void> show(
    BuildContext context, {
    required String selectedText,
    String? surroundingContext,
    DocumentContext? documentContext,
    String? apiKey,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => AIAssistantSheet(
        selectedText: selectedText,
        context: surroundingContext,
        documentContext: documentContext,
        apiKey: apiKey,
      ),
    );
  }

  @override
  State<AIAssistantSheet> createState() => _AIAssistantSheetState();
}

class _AIAssistantSheetState extends State<AIAssistantSheet> {
  late AskAIUseCase _askAIUseCase;
  late AIAssistantService _service;
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  AIQueryType _selectedQueryType = AIQueryType.explain;
  AIAssistantState _state = AIAssistantState.idle;
  AIAssistantResponse? _response;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  void _initializeService() {
    _service = widget.apiKey != null && widget.apiKey!.isNotEmpty
        ? AIAssistantService.withApiKey(widget.apiKey!)
        : AIAssistantService.mock();
    _askAIUseCase = AskAIUseCase(_service);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _submitQuery() async {
    if (_state == AIAssistantState.loading) return;

    // Validate for question/custom types
    if ((_selectedQueryType == AIQueryType.question ||
            _selectedQueryType == AIQueryType.custom) &&
        _questionController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = _selectedQueryType == AIQueryType.question
            ? 'Please enter a question'
            : 'Please enter a prompt';
      });
      return;
    }

    setState(() {
      _state = AIAssistantState.loading;
      _errorMessage = null;
    });

    final query = AIQuery(
      selectedText: widget.selectedText,
      context: widget.context,
      queryType: _selectedQueryType,
      customPrompt: _questionController.text.trim().isNotEmpty
          ? _questionController.text.trim()
          : null,
      documentContext: widget.documentContext,
    );

    final response = await _askAIUseCase.execute(query);

    if (mounted) {
      setState(() {
        _response = response;
        _state = response.isSuccess
            ? AIAssistantState.success
            : AIAssistantState.error;
        if (!response.isSuccess) {
          _errorMessage = response.errorMessage;
        }
      });

      // Scroll to response
      if (response.isSuccess) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    }
  }

  void _copyResponse() {
    if (_response?.isSuccess == true) {
      Clipboard.setData(ClipboardData(text: _response!.content));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Response copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar and header
          _buildHeader(theme),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected text preview
                  _buildSelectedTextPreview(theme),
                  const SizedBox(height: 16),

                  // Query type selector
                  _buildQueryTypeSelector(theme),
                  const SizedBox(height: 16),

                  // Question input (for question/custom types)
                  if (_selectedQueryType == AIQueryType.question ||
                      _selectedQueryType == AIQueryType.custom)
                    _buildQuestionInput(theme),

                  // Submit button
                  _buildSubmitButton(theme),
                  const SizedBox(height: 16),

                  // Error message
                  if (_errorMessage != null) _buildErrorMessage(theme),

                  // Response
                  if (_response?.isSuccess == true) _buildResponse(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Assistant',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Ask questions about selected text',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTextPreview(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.format_quote,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'Selected Text',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${widget.selectedText.length} chars',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 120),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              widget.selectedText,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQueryTypeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What would you like to do?',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AIQueryType.values.map((type) {
            final isSelected = _selectedQueryType == type;
            return FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(type.icon),
                  const SizedBox(width: 4),
                  Text(type.displayName),
                ],
              ),
              onSelected: (_) {
                setState(() {
                  _selectedQueryType = type;
                  _response = null;
                  _errorMessage = null;
                });
              },
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.onPrimaryContainer,
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        Text(
          _selectedQueryType.description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionInput(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _questionController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: _selectedQueryType == AIQueryType.question
              ? 'Your Question'
              : 'Your Prompt',
          hintText: _selectedQueryType == AIQueryType.question
              ? 'What would you like to know about this text?'
              : 'Enter your custom prompt...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          prefixIcon: Icon(
            _selectedQueryType == AIQueryType.question
                ? Icons.help_outline
                : Icons.edit_note,
          ),
        ),
        onSubmitted: (_) => _submitQuery(),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _state == AIAssistantState.loading ? null : _submitQuery,
        icon: _state == AIAssistantState.loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onPrimary,
                ),
              )
            : Icon(_getButtonIcon()),
        label: Text(_getButtonLabel()),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  IconData _getButtonIcon() {
    switch (_selectedQueryType) {
      case AIQueryType.explain:
        return Icons.lightbulb_outline;
      case AIQueryType.summarize:
        return Icons.summarize;
      case AIQueryType.define:
        return Icons.menu_book;
      case AIQueryType.analyze:
        return Icons.analytics;
      case AIQueryType.question:
        return Icons.question_answer;
      case AIQueryType.custom:
        return Icons.send;
    }
  }

  String _getButtonLabel() {
    if (_state == AIAssistantState.loading) {
      return 'Thinking...';
    }
    switch (_selectedQueryType) {
      case AIQueryType.explain:
        return 'Explain This';
      case AIQueryType.summarize:
        return 'Summarize';
      case AIQueryType.define:
        return 'Define Terms';
      case AIQueryType.analyze:
        return 'Analyze';
      case AIQueryType.question:
        return 'Ask Question';
      case AIQueryType.custom:
        return 'Send Prompt';
    }
  }

  Widget _buildErrorMessage(ThemeData theme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _errorMessage = null),
            icon: Icon(
              Icons.close,
              size: 18,
              color: theme.colorScheme.onErrorContainer,
            ),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildResponse(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'AI Response',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (_response?.responseTime != null)
              Text(
                '${_response!.responseTime!.inMilliseconds}ms',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            IconButton(
              onPressed: _copyResponse,
              icon: const Icon(Icons.copy, size: 18),
              tooltip: 'Copy response',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: SelectableText(
            _response!.content,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
