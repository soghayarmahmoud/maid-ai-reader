/// AI Assistant feature for context-aware text analysis
///
/// Allows users to ask questions about selected PDF text,
/// get explanations, summaries, and more.
library ai_assistant;

export 'domain/entities/ai_query.dart';
export 'domain/entities/ai_assistant_response.dart';
export 'domain/repositories/ai_assistant_repository.dart';
export 'domain/usecases/ask_ai_usecase.dart';
export 'data/ai_assistant_service.dart';
export 'presentation/ai_assistant_sheet.dart';
export 'presentation/ai_assistant_viewmodel.dart';
export 'presentation/widgets/ai_quick_actions.dart';
export 'presentation/widgets/ai_response_card.dart';
