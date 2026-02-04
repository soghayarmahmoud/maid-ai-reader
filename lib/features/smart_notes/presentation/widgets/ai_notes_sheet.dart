import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/ai/ai.dart';
import '../domain/entities/note_entity.dart';
import '../domain/usecases/generate_ai_notes.dart';
import 'notes_viewmodel.dart';

/// State for AI notes generation
enum AINotesState { initial, generating, generated, error }

/// Sheet for generating AI notes and merging with manual notes
class AINotesSheet extends StatefulWidget {
  /// Text content to analyze
  final String content;

  /// PDF path
  final String pdfPath;

  /// Page number
  final int pageNumber;

  /// Document title for context
  final String? documentTitle;

  /// Existing manual notes for this page
  final List<NoteEntity> existingNotes;

  /// Notes viewmodel for saving
  final NotesViewModel? notesViewModel;

  const AINotesSheet({
    super.key,
    required this.content,
    required this.pdfPath,
    required this.pageNumber,
    this.documentTitle,
    this.existingNotes = const [],
    this.notesViewModel,
  });

  /// Show the AI notes sheet
  static Future<void> show(
    BuildContext context, {
    required String content,
    required String pdfPath,
    required int pageNumber,
    String? documentTitle,
    List<NoteEntity> existingNotes = const [],
    NotesViewModel? notesViewModel,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AINotesSheet(
        content: content,
        pdfPath: pdfPath,
        pageNumber: pageNumber,
        documentTitle: documentTitle,
        existingNotes: existingNotes,
        notesViewModel: notesViewModel,
      ),
    );
  }

  @override
  State<AINotesSheet> createState() => _AINotesSheetState();
}

class _AINotesSheetState extends State<AINotesSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AINotesState _state = AINotesState.initial;
  AINotesResult? _aiNotesResult;
  String? _errorMessage;
  AINotesConfig _config = AINotesConfig.balanced;
  Set<AIInsight> _selectedInsights = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _generateNotes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _generateNotes() async {
    setState(() {
      _state = AINotesState.generating;
      _errorMessage = null;
    });

    try {
      final aiService = AIServiceFactory.create();
      final useCase = GenerateAINotesUseCase(aiService);

      final result = await useCase.execute(
        widget.content,
        config: _config,
        documentContext: widget.documentTitle,
      );

      if (mounted) {
        setState(() {
          if (result.isSuccess) {
            _aiNotesResult = result;
            _state = AINotesState.generated;
          } else {
            _errorMessage = result.errorMessage;
            _state = AINotesState.error;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to generate notes: $e';
          _state = AINotesState.error;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Smart Notes',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'AI insights + Your notes',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Tab bar
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.merge_type, size: 18),
                        const SizedBox(width: 6),
                        const Text('Combined'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, size: 18),
                        const SizedBox(width: 6),
                        const Text('AI'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit_note, size: 18),
                        const SizedBox(width: 6),
                        Text('Manual (${widget.existingNotes.length})'),
                      ],
                    ),
                  ),
                ],
              ),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCombinedTab(theme, scrollController),
                    _buildAITab(theme, scrollController),
                    _buildManualTab(theme, scrollController),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCombinedTab(ThemeData theme, ScrollController controller) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(16),
      children: [
        // Info card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AI notes enhance your understanding. Your notes capture your thoughts.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // AI Key Points section
        if (_state == AINotesState.generated &&
            _aiNotesResult!.keyPoints.isNotEmpty) ...[
          _buildSectionHeader(
            theme,
            '✨ Key Points',
            'AI-generated',
            isAI: true,
          ),
          ..._aiNotesResult!.keyPoints.map((i) => _buildInsightCard(theme, i)),
          const SizedBox(height: 16),
        ],

        // Manual notes section
        if (widget.existingNotes.isNotEmpty) ...[
          _buildSectionHeader(
            theme,
            '📝 Your Notes',
            '${widget.existingNotes.length} notes',
            isAI: false,
          ),
          ...widget.existingNotes.map((n) => _buildManualNoteCard(theme, n)),
          const SizedBox(height: 16),
        ],

        // AI Questions section
        if (_state == AINotesState.generated &&
            _aiNotesResult!.questions.isNotEmpty) ...[
          _buildSectionHeader(
            theme,
            '❓ Questions to Consider',
            'Deepen understanding',
            isAI: true,
          ),
          ..._aiNotesResult!.questions.map((i) => _buildInsightCard(theme, i)),
          const SizedBox(height: 16),
        ],

        // Other AI insights
        if (_state == AINotesState.generated) ...[
          for (final type in [
            AIInsightType.vocabulary,
            AIInsightType.connections,
            AIInsightType.analysis,
          ])
            if (_aiNotesResult!.getByType(type).isNotEmpty) ...[
              _buildSectionHeader(
                theme,
                _getTypeEmoji(type) + ' ' + _getTypeTitle(type),
                'AI-generated',
                isAI: true,
              ),
              ..._aiNotesResult!
                  .getByType(type)
                  .map((i) => _buildInsightCard(theme, i)),
              const SizedBox(height: 16),
            ],
        ],

        // Loading state
        if (_state == AINotesState.generating) _buildLoadingSection(theme),

        // Error state
        if (_state == AINotesState.error) _buildErrorSection(theme),

        const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildAITab(ThemeData theme, ScrollController controller) {
    if (_state == AINotesState.generating) {
      return _buildLoadingSection(theme);
    }

    if (_state == AINotesState.error) {
      return _buildErrorSection(theme);
    }

    if (_aiNotesResult == null || _aiNotesResult!.insights.isEmpty) {
      return Center(
        child: Text(
          'No AI insights generated',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Config selector
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildConfigChip(
                  theme,
                  'Quick',
                  AINotesConfig.quick,
                  Icons.flash_on,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildConfigChip(
                  theme,
                  'Balanced',
                  AINotesConfig.balanced,
                  Icons.balance,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildConfigChip(
                  theme,
                  'Deep',
                  AINotesConfig.deepAnalysis,
                  Icons.psychology,
                ),
              ),
            ],
          ),
        ),

        // Insights list
        Expanded(
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final type in AIInsightType.values)
                if (_aiNotesResult!.getByType(type).isNotEmpty) ...[
                  _buildSectionHeader(
                    theme,
                    _getTypeEmoji(type) + ' ' + _getTypeTitle(type),
                    '${_aiNotesResult!.getByType(type).length} insights',
                    isAI: true,
                  ),
                  ..._aiNotesResult!
                      .getByType(type)
                      .map((i) => _buildSelectableInsightCard(theme, i)),
                  const SizedBox(height: 16),
                ],
              const SizedBox(height: 60),
            ],
          ),
        ),

        // Save selected button
        if (_selectedInsights.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: FilledButton.icon(
              onPressed: _saveSelectedInsights,
              icon: const Icon(Icons.save),
              label: Text('Save ${_selectedInsights.length} to Notes'),
            ),
          ),
      ],
    );
  }

  Widget _buildManualTab(ThemeData theme, ScrollController controller) {
    if (widget.existingNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit_note,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No manual notes yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select text in the PDF to create notes',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.all(16),
      itemCount: widget.existingNotes.length,
      itemBuilder: (context, index) {
        return _buildManualNoteCard(theme, widget.existingNotes[index]);
      },
    );
  }

  Widget _buildSectionHeader(
    ThemeData theme,
    String title,
    String subtitle, {
    required bool isAI,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isAI
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              subtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isAI
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(ThemeData theme, AIInsight insight) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _getTypeIcon(insight.type),
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SelectableText(
                insight.content,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: insight.content));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableInsightCard(ThemeData theme, AIInsight insight) {
    final isSelected = _selectedInsights.contains(insight);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedInsights.remove(insight);
            } else {
              _selectedInsights.add(insight);
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedInsights.add(insight);
                    } else {
                      _selectedInsights.remove(insight);
                    }
                  });
                },
              ),
              Expanded(
                child: Text(insight.content, style: theme.textTheme.bodyMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualNoteCard(ThemeData theme, NoteEntity note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.title != null)
              Text(
                note.title!,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (note.selectedText != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '"${note.selectedText}"',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            Text(note.content, style: theme.textTheme.bodyMedium),
            if (note.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: note.tags
                    .map(
                      (tag) => Chip(
                        label: Text('#$tag'),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfigChip(
    ThemeData theme,
    String label,
    AINotesConfig config,
    IconData icon,
  ) {
    final isSelected = _config == config;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 4), Text(label)],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected && _config != config) {
          setState(() {
            _config = config;
          });
          _generateNotes();
        }
      },
    );
  }

  Widget _buildLoadingSection(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Generating insights...', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'AI is analyzing the content',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSection(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Failed to generate notes',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _generateNotes,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeTitle(AIInsightType type) {
    switch (type) {
      case AIInsightType.keyPoints:
        return 'Key Points';
      case AIInsightType.questions:
        return 'Questions';
      case AIInsightType.connections:
        return 'Connections';
      case AIInsightType.vocabulary:
        return 'Key Terms';
      case AIInsightType.analysis:
        return 'Analysis';
    }
  }

  String _getTypeEmoji(AIInsightType type) {
    switch (type) {
      case AIInsightType.keyPoints:
        return '✨';
      case AIInsightType.questions:
        return '❓';
      case AIInsightType.connections:
        return '🔗';
      case AIInsightType.vocabulary:
        return '📚';
      case AIInsightType.analysis:
        return '🔍';
    }
  }

  IconData _getTypeIcon(AIInsightType type) {
    switch (type) {
      case AIInsightType.keyPoints:
        return Icons.star;
      case AIInsightType.questions:
        return Icons.help_outline;
      case AIInsightType.connections:
        return Icons.link;
      case AIInsightType.vocabulary:
        return Icons.menu_book;
      case AIInsightType.analysis:
        return Icons.analytics;
    }
  }

  Future<void> _saveSelectedInsights() async {
    if (_selectedInsights.isEmpty) return;

    final viewModel = widget.notesViewModel ?? NotesViewModel();
    if (widget.notesViewModel == null) {
      await viewModel.initialize();
    }

    final content = _selectedInsights.map((i) => '• ${i.content}').join('\n');

    final note = await viewModel.addNote(
      content: content,
      pdfPath: widget.pdfPath,
      pageNumber: widget.pageNumber,
      title: 'AI Notes - Page ${widget.pageNumber}',
      tags: ['ai-generated', 'insights'],
    );

    if (note != null && mounted) {
      Navigator.pop(context, note);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Insights saved to notes')));
    }
  }
}
