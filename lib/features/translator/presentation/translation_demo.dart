import 'package:flutter/material.dart';
import '../translator.dart';

/// Example showing how to integrate the translation feature with PDF reader
///
/// Usage in PDF Reader page:
/// 1. When user selects text, show a context menu with "Translate" option
/// 2. When "Translate" is tapped, show the TranslateSheet
///
/// Example:
/// ```dart
/// void _showTextSelectionMenu(String selectedText, Offset position) {
///   showMenu(
///     context: context,
///     position: RelativeRect.fromLTRB(
///       position.dx,
///       position.dy,
///       position.dx,
///       position.dy,
///     ),
///     items: [
///       PopupMenuItem(
///         child: ListTile(
///           leading: Icon(Icons.translate),
///           title: Text('Translate'),
///           dense: true,
///         ),
///         onTap: () => _showTranslationSheet(selectedText),
///       ),
///       // ... other menu items
///     ],
///   );
/// }
///
/// void _showTranslationSheet(String selectedText) {
///   TranslateSheet.show(
///     context,
///     selectedText: selectedText,
///     apiKey: 'your-openai-api-key', // Get from settings
///   );
/// }
/// ```

/// Demo page showing the translation feature
class TranslationDemoPage extends StatefulWidget {
  final String? apiKey;

  const TranslationDemoPage({super.key, this.apiKey});

  @override
  State<TranslationDemoPage> createState() => _TranslationDemoPageState();
}

class _TranslationDemoPageState extends State<TranslationDemoPage> {
  final TextEditingController _textController = TextEditingController();
  late TranslationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.apiKey != null
        ? TranslationViewModel.withApiKey(widget.apiKey!)
        : TranslationViewModel.mock();
  }

  @override
  void dispose() {
    _textController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistory,
            tooltip: 'Translation history',
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Language selector
                LanguagePairSelector(
                  sourceLanguage: _viewModel.sourceLanguage,
                  targetLanguage: _viewModel.targetLanguage,
                  languages: _viewModel.supportedLanguages,
                  onSourceChanged: _viewModel.setSourceLanguage,
                  onTargetChanged: _viewModel.setTargetLanguage,
                  onSwap: _viewModel.swapLanguages,
                ),
                const SizedBox(height: 24),

                // Input text field
                TextField(
                  controller: _textController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Enter text to translate',
                    hintText: 'Type or paste text here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _textController.clear();
                        _viewModel.clearResult();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Translate button
                ElevatedButton.icon(
                  onPressed: _viewModel.isLoading ? null : _translate,
                  icon: _viewModel.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.translate),
                  label: Text(
                    _viewModel.isLoading ? 'Translating...' : 'Translate',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 24),

                // Result
                if (_viewModel.lastResult != null)
                  TranslationResultCard(
                    result: _viewModel.lastResult!,
                    onDismiss: _viewModel.clearResult,
                  ),
              ],
            ),
          );
        },
      ),
      // FAB to show quick translation sheet
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickTranslate(),
        icon: const Icon(Icons.translate),
        label: const Text('Quick Translate'),
      ),
    );
  }

  Future<void> _translate() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text to translate')),
      );
      return;
    }

    await _viewModel.translate(text);
  }

  void _showQuickTranslate() {
    final text = _textController.text.trim();
    TranslateSheet.show(
      context,
      selectedText: text.isNotEmpty ? text : 'Hello, how are you?',
      apiKey: widget.apiKey,
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) {
          final history = _viewModel.history;

          if (history.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No translation history yet'),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(8),
            itemCount: history.length,
            itemBuilder: (context, index) {
              return TranslationResultCard(
                result: history[index],
                showOriginal: true,
              );
            },
          );
        },
      ),
    );
  }
}

/// Extension to easily add translation capability to any widget
extension TranslationExtension on BuildContext {
  /// Show translation sheet for the given text
  Future<void> showTranslation(String text, {String? apiKey}) {
    return TranslateSheet.show(this, selectedText: text, apiKey: apiKey);
  }
}
