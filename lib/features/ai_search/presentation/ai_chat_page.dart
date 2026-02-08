// ignore_for_file: avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../data/gemini_ai_service.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';

class AiChatPage extends StatefulWidget {
  final String pdfPath;
  final String? selectedText;

  const AiChatPage({
    super.key,
    required this.pdfPath,
    this.selectedText,
  });

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final GeminiAiService _aiService = GeminiAiService();
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _pdfContext;
  
  // AI Suggestion chips
  final List<String> _suggestions = [
    'Summarize this document',
    'What are the key points?',
    'Explain the main concepts',
    'Create study questions',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAi();
    if (widget.selectedText != null && widget.selectedText!.isNotEmpty) {
      _messageController.text = 'Explain this: "${widget.selectedText}"';
    }
  }

  Future<void> _initializeAi() async {
    try {
      await _aiService.initialize();
      await _extractPdfContext();
      _aiService.startChatSession(pdfContext: _pdfContext);
      setState(() {
        _isInitialized = true;
      });
      
      // Add welcome message
      _messages.add(ChatMessage(
        text: '👋 Hi! I\'m your AI assistant. I\'ve analyzed your PDF and I\'m ready to help!\n\n'
            'Ask me anything about the document, or try one of the suggestions below.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      print('Error initializing AI: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _extractPdfContext() async {
    try {
      // Extract text from first few pages for context
      final PdfDocument document = PdfDocument(inputBytes: await File(widget.pdfPath).readAsBytes());
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      
      StringBuffer context = StringBuffer();
      int pagesToExtract = document.pages.count < 3 ? document.pages.count : 3;
      
      for (int i = 0; i < pagesToExtract; i++) {
        String pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
        context.write(pageText);
        if (context.length > 3000) break; // Limit context size
      }
      
      _pdfContext = context.toString();
      document.dispose();
    } catch (e) {
      print('Error extracting PDF context: $e');
      _pdfContext = null;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _aiService.dispose();
    super.dispose();
  }

  Future<void> _sendMessage({String? predefinedMessage}) async {
    final message = predefinedMessage ?? _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      String response;
      
      if (message.toLowerCase().contains('summarize')) {
        response = await _aiService.analyzePdf(_pdfContext ?? 'No context available');
      } else if (message.toLowerCase().contains('key points')) {
        final points = await _aiService.extractKeyPoints(_pdfContext ?? message);
        response = points.join('\n');
      } else if (message.toLowerCase().contains('questions')) {
        final questions = await _aiService.generateQuestions(_pdfContext ?? message);
        response = questions.join('\n');
      } else {
        response = await _aiService.sendChatMessage(message);
      }

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: '❌ Error: $e',
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _searchGoogle(String query) async {
    final url = Uri.parse('https://www.google.com/search?q=${Uri.encodeComponent(query)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _exportConversation() {
    final conversation = _messages.map((msg) {
      return '${msg.isUser ? "You" : "AI"} (${_formatTime(msg.timestamp)}):\n${msg.text}\n';
    }).join('\n---\n\n');
    
    Clipboard.setData(ClipboardData(text: conversation));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conversation copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.aiSearch),
        actions: [
          if (_messages.length > 1)
            IconButton(
              icon: const Icon(Icons.file_download),
              onPressed: _exportConversation,
              tooltip: 'Export Conversation',
            ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              setState(() {
                _messages.clear();
                _aiService.endChatSession();
                _aiService.startChatSession(pdfContext: _pdfContext);
              });
            },
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // AI Suggestions Chips
          if (_messages.length <= 1)
            Container(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestions.map((suggestion) {
                  return ActionChip(
                    avatar: const Icon(Icons.auto_awesome, size: 18),
                    label: Text(suggestion),
                    onPressed: () => _sendMessage(predefinedMessage: suggestion),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                  );
                }).toList(),
              ),
            ),
          
          // Messages List
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          !_isInitialized 
                              ? 'Initializing AI assistant...'
                              : 'Ask a question about your PDF',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.grey600,
                              ),
                        ),
                        if (!_isInitialized)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    physics: const ClampingScrollPhysics(),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return RepaintBoundary(
                        child: _MessageBubble(
                          message: message,
                          onGoogleSearch: widget.selectedText != null
                              ? () => _searchGoogle(widget.selectedText!)
                              : null,
                        ),
                      );
                    },
                  ),
          ),
          
          // Loading Indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    AppStrings.thinking,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Google Search Button (if text selected)
                if (widget.selectedText != null && widget.selectedText!.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _searchGoogle(widget.selectedText!),
                    tooltip: 'Search on Google',
                    color: Colors.blue,
                  ),
                
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: AppStrings.askQuestion,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading ? null : () => _sendMessage(),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onGoogleSearch;

  const _MessageBubble({
    required this.message,
    this.onGoogleSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primary : AppColors.grey200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser)
              const Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'AI Assistant',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            if (!message.isUser) const SizedBox(height: 6),
            SelectableText(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: message.isUser
                    ? Colors.white.withOpacity(0.7)
                    : AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
