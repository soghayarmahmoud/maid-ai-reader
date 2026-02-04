// Smart Notes Feature - Barrel Export

// Domain - Entities
export 'domain/entities/note_entity.dart';

// Domain - Repositories
export 'domain/repositories/notes_repository.dart';

// Domain - Use Cases
export 'domain/usecases/add_note.dart';
export 'domain/usecases/get_notes_by_pdf.dart';
export 'domain/usecases/summarize_note.dart';
export 'domain/usecases/summarize_content.dart';
export 'domain/usecases/generate_ai_notes.dart';

// Data - Repository Implementation
export 'data/notes_repository_impl.dart';

// Presentation
export 'presentation/notes_page.dart';
export 'presentation/notes_viewmodel.dart';
export 'presentation/widgets/note_card.dart';
export 'presentation/widgets/note_editor_sheet.dart';
export 'presentation/widgets/summarize_sheet.dart';
export 'presentation/widgets/ai_notes_sheet.dart';
export 'presentation/widgets/summarize_actions.dart';
