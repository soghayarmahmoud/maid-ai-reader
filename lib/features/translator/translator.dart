/// Translator feature exports
library translator;

// Domain entities
export 'domain/entities/language.dart';
export 'domain/entities/translation_result.dart';

// Domain repositories
export 'domain/repositories/translation_repository.dart';

// Domain use cases
export 'domain/translate_text.dart';

// Data layer
export 'data/translation_service.dart';

// Presentation
export 'presentation/translate_sheet.dart';
export 'presentation/translation_viewmodel.dart';
export 'presentation/widgets/language_selector.dart';
export 'presentation/widgets/translation_result_card.dart';
