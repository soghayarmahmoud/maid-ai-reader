import '../../../core/ai/ai.dart';

/// Types of AI-generated notes
enum AIInsightType {
  /// Key points extracted from the content
  keyPoints,

  /// Questions to deepen understanding
  questions,

  /// Connections to other concepts
  connections,

  /// Vocabulary and definitions
  vocabulary,

  /// Critical analysis points
  analysis,
}

/// Configuration for AI note generation
class AINotesConfig {
  /// Types of insights to generate
  final Set<AIInsightType> insightTypes;

  /// Maximum number of points per type
  final int maxPointsPerType;

  /// Whether to use concise format
  final bool conciseMode;

  const AINotesConfig({
    this.insightTypes = const {
      AIInsightType.keyPoints,
      AIInsightType.questions,
    },
    this.maxPointsPerType = 3,
    this.conciseMode = true,
  });

  /// Balanced config for reading enhancement
  static const balanced = AINotesConfig(
    insightTypes: {
      AIInsightType.keyPoints,
      AIInsightType.questions,
      AIInsightType.vocabulary,
    },
    maxPointsPerType: 3,
    conciseMode: true,
  );

  /// Deep analysis config
  static const deepAnalysis = AINotesConfig(
    insightTypes: {
      AIInsightType.keyPoints,
      AIInsightType.questions,
      AIInsightType.connections,
      AIInsightType.analysis,
    },
    maxPointsPerType: 5,
    conciseMode: false,
  );

  /// Quick insights config
  static const quick = AINotesConfig(
    insightTypes: {AIInsightType.keyPoints},
    maxPointsPerType: 3,
    conciseMode: true,
  );
}

/// Result of AI note generation
class AINotesResult {
  final bool isSuccess;
  final List<AIInsight> insights;
  final String? errorMessage;
  final String? sourceText;

  const AINotesResult._({
    required this.isSuccess,
    this.insights = const [],
    this.errorMessage,
    this.sourceText,
  });

  factory AINotesResult.success(List<AIInsight> insights, String sourceText) {
    return AINotesResult._(
      isSuccess: true,
      insights: insights,
      sourceText: sourceText,
    );
  }

  factory AINotesResult.failure(String errorMessage) {
    return AINotesResult._(isSuccess: false, errorMessage: errorMessage);
  }

  /// Get insights of a specific type
  List<AIInsight> getByType(AIInsightType type) {
    return insights.where((i) => i.type == type).toList();
  }

  /// Get all key points
  List<AIInsight> get keyPoints => getByType(AIInsightType.keyPoints);

  /// Get all questions
  List<AIInsight> get questions => getByType(AIInsightType.questions);

  /// Convert all insights to a formatted string
  String toFormattedString() {
    final buffer = StringBuffer();

    for (final type in AIInsightType.values) {
      final typeInsights = getByType(type);
      if (typeInsights.isEmpty) continue;

      buffer.writeln('## ${_typeTitle(type)}');
      for (final insight in typeInsights) {
        buffer.writeln('• ${insight.content}');
      }
      buffer.writeln();
    }

    return buffer.toString().trim();
  }

  String _typeTitle(AIInsightType type) {
    switch (type) {
      case AIInsightType.keyPoints:
        return 'Key Points';
      case AIInsightType.questions:
        return 'Questions to Consider';
      case AIInsightType.connections:
        return 'Connections';
      case AIInsightType.vocabulary:
        return 'Key Terms';
      case AIInsightType.analysis:
        return 'Analysis';
    }
  }
}

/// A single AI-generated insight
class AIInsight {
  final AIInsightType type;
  final String content;
  final String? explanation;

  const AIInsight({
    required this.type,
    required this.content,
    this.explanation,
  });
}

/// Use case for generating AI notes that enhance reading
class GenerateAINotesUseCase {
  final AIService _aiService;

  GenerateAINotesUseCase(this._aiService);

  /// Generate AI notes from content
  Future<AINotesResult> execute(
    String content, {
    AINotesConfig config = AINotesConfig.balanced,
    String? documentContext,
  }) async {
    if (content.trim().isEmpty) {
      return AINotesResult.failure('No content to analyze');
    }

    final prompt = _buildPrompt(content, config, documentContext);

    final response = await _aiService.prompt(
      prompt,
      systemPrompt: _systemPrompt(config),
      options: AICompletionOptions(
        temperature: 0.4,
        maxTokens: config.conciseMode ? 512 : 1024,
      ),
    );

    if (!response.isSuccess) {
      return AINotesResult.failure(
        response.errorMessage ?? 'Failed to generate notes',
      );
    }

    final insights = _parseResponse(response.content, config);
    return AINotesResult.success(insights, content);
  }

  String _systemPrompt(AINotesConfig config) {
    return '''You are a reading assistant that helps users understand and engage with text more deeply. Your role is to:
- Extract insights that ENHANCE understanding, not replace reading
- Provide concise, actionable notes
- Help readers think critically about the material
- Identify what's worth remembering

${config.conciseMode ? 'Keep responses brief and scannable.' : 'Provide thorough but focused analysis.'}

Format each insight on its own line, prefixed with its type tag.''';
  }

  String _buildPrompt(
    String content,
    AINotesConfig config,
    String? documentContext,
  ) {
    final buffer = StringBuffer();

    if (documentContext != null) {
      buffer.writeln('Document context: $documentContext\n');
    }

    buffer.writeln('Analyze this text and generate reading notes:\n');
    buffer.writeln('"$content"\n');
    buffer.writeln('Generate the following types of insights:');

    for (final type in config.insightTypes) {
      final typeDesc = _getTypeDescription(type);
      buffer.writeln(
        '- [${type.name.toUpperCase()}]: $typeDesc (max ${config.maxPointsPerType})',
      );
    }

    buffer.writeln('\nFormat each insight as: [TYPE] insight text');
    buffer.writeln(
      'Focus on what will help the reader understand and remember the content.',
    );

    return buffer.toString();
  }

  String _getTypeDescription(AIInsightType type) {
    switch (type) {
      case AIInsightType.keyPoints:
        return 'Main ideas worth remembering';
      case AIInsightType.questions:
        return 'Questions to deepen understanding';
      case AIInsightType.connections:
        return 'Links to other concepts or knowledge';
      case AIInsightType.vocabulary:
        return 'Important terms and their meanings';
      case AIInsightType.analysis:
        return 'Critical thinking observations';
    }
  }

  List<AIInsight> _parseResponse(String response, AINotesConfig config) {
    final insights = <AIInsight>[];
    final lines = response.split('\n');

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Try to parse [TYPE] format
      final match = RegExp(r'^\[(\w+)\]\s*(.+)$').firstMatch(trimmed);
      if (match != null) {
        final typeStr = match.group(1)!.toLowerCase();
        final content = match.group(2)!;

        final type = _parseType(typeStr);
        if (type != null && config.insightTypes.contains(type)) {
          insights.add(AIInsight(type: type, content: content));
        }
      } else {
        // Fallback: treat as key point if it looks like a bullet
        if (trimmed.startsWith('•') ||
            trimmed.startsWith('-') ||
            trimmed.startsWith('*')) {
          final content = trimmed.substring(1).trim();
          if (content.isNotEmpty) {
            insights.add(
              AIInsight(type: AIInsightType.keyPoints, content: content),
            );
          }
        }
      }
    }

    return insights;
  }

  AIInsightType? _parseType(String typeStr) {
    switch (typeStr) {
      case 'keypoints':
      case 'keypoint':
      case 'key':
        return AIInsightType.keyPoints;
      case 'questions':
      case 'question':
        return AIInsightType.questions;
      case 'connections':
      case 'connection':
        return AIInsightType.connections;
      case 'vocabulary':
      case 'vocab':
      case 'term':
        return AIInsightType.vocabulary;
      case 'analysis':
      case 'analyze':
        return AIInsightType.analysis;
      default:
        return null;
    }
  }
}
