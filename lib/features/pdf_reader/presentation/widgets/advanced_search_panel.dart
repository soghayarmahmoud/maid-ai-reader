import 'package:flutter/material.dart';
import 'package:maid_ai_reader/core/widgets/glass_widgets.dart';
import 'package:maid_ai_reader/features/pdf_reader/services/advanced_search_service.dart';


/// Advanced Search Panel
class AdvancedSearchPanel extends StatefulWidget {
  final String pdfPath;
  final String pdfText;

  const AdvancedSearchPanel({
    super.key,
    required this.pdfPath,
    required this.pdfText,
  });

  @override
  State<AdvancedSearchPanel> createState() => _AdvancedSearchPanelState();
}

class _AdvancedSearchPanelState extends State<AdvancedSearchPanel>
    with SingleTickerProviderStateMixin {
  final AdvancedSearchService _searchService = AdvancedSearchService();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  List<SearchResult> _results = [];
  bool _isSearching = false;
  SearchType _searchType = SearchType.basic;

  // Search options
  bool _caseSensitive = false;
  bool _wholeWord = false;
  bool _useRegex = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _searchService.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isSearching = true;
      _results = [];
    });

    List<SearchResult> results = [];

    try {
      switch (_searchType) {
        case SearchType.basic:
          results = await _searchService.basicSearch(
            text: widget.pdfText,
            searchTerm: _searchController.text,
            caseSensitive: _caseSensitive,
            wholeWord: _wholeWord,
          );
          break;

        case SearchType.regex:
          results = await _searchService.regexSearch(
            pdfText: widget.pdfText,
            pattern: _searchController.text,
            caseSensitive: _caseSensitive,
          );
          break;

        case SearchType.ocr:
          results = await _searchService.ocrSearch(
            pdfPath: widget.pdfPath,
            searchTerm: _searchController.text,
          );
          break;

        case SearchType.semantic:
          results = await _searchService.semanticSearch(
            pdfText: widget.pdfText,
            query: _searchController.text,
            aiSimilarityCheck: (q, chunk) async => chunk,
          );
          break;
      }
    } catch (e) {
      print('Search error: $e');
    }

    setState(() {
      _results = results;
      _isSearching = false;
    });

    // Save search bookmark
    if (results.isNotEmpty) {
      await _searchService.saveSearchBookmark(
        pdfPath: widget.pdfPath,
        searchTerm: _searchController.text,
        results: results,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Search tabs
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Basic', icon: Icon(Icons.search, size: 20)),
              Tab(text: 'Regex', icon: Icon(Icons.code, size: 20)),
              Tab(text: 'OCR', icon: Icon(Icons.document_scanner, size: 20)),
              Tab(text: 'Semantic', icon: Icon(Icons.psychology, size: 20)),
            ],
            onTap: (index) {
              setState(() {
                _searchType = SearchType.values[index];
              });
            },
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicSearchTab(),
                _buildRegexSearchTab(),
                _buildOcrSearchTab(),
                _buildSemanticSearchTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicSearchTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search field
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search in document...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _results = [];
                });
              },
            ),
          ),
          onSubmitted: (_) => _performSearch(),
        ),

        const SizedBox(height: 16),

        // Search options
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Case sensitive'),
                value: _caseSensitive,
                onChanged: (value) {
                  setState(() {
                    _caseSensitive = value;
                  });
                },
                dense: true,
              ),
              SwitchListTile(
                title: const Text('Whole word'),
                value: _wholeWord,
                onChanged: (value) {
                  setState(() {
                    _wholeWord = value;
                  });
                },
                dense: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Search button
        ElevatedButton.icon(
          onPressed: _isSearching ? null : _performSearch,
          icon: _isSearching
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.search),
          label: Text(_isSearching ? 'Searching...' : 'Search'),
        ),

        const SizedBox(height: 16),

        // Results
        _buildResults(),
      ],
    );
  }

  Widget _buildRegexSearchTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter regex pattern...',
            prefixIcon: Icon(Icons.code),
            helperText: r'Example: \d{3}-\d{4} for phone numbers',
          ),
          onSubmitted: (_) => _performSearch(),
        ),
        const SizedBox(height: 16),

        // Common patterns
        const Text('Common Patterns:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPatternChip(r'\d+', 'Numbers'),
            _buildPatternChip(r'\w+@\w+\.\w+', 'Emails'),
            _buildPatternChip(r'\d{3}-\d{3}-\d{4}', 'Phone'),
            _buildPatternChip(r'https?://\S+', 'URLs'),
          ],
        ),

        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _isSearching ? null : _performSearch,
          icon: const Icon(Icons.search),
          label: const Text('Search with Regex'),
        ),

        const SizedBox(height: 16),
        _buildResults(),
      ],
    );
  }

  Widget _buildOcrSearchTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.document_scanner,
                  size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 12),
              const Text(
                'OCR Search',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Search in scanned documents using Optical Character Recognition',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search in scanned pages...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (_) => _performSearch(),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _isSearching ? null : _performSearch,
          icon: const Icon(Icons.search),
          label: const Text('Search with OCR'),
        ),
        const SizedBox(height: 16),
        _buildResults(),
      ],
    );
  }

  Widget _buildSemanticSearchTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.psychology,
                  size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 12),
              const Text(
                'Semantic Search',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'AI-powered search that understands meaning and context',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Ask a question or describe what you\'re looking for...',
            prefixIcon: Icon(Icons.search),
          ),
          maxLines: 3,
          onSubmitted: (_) => _performSearch(),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _isSearching ? null : _performSearch,
          icon: const Icon(Icons.search),
          label: const Text('Semantic Search'),
        ),
        const SizedBox(height: 16),
        _buildResults(),
      ],
    );
  }

  Widget _buildResults() {
    if (_isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_results.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No results found'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_results.length} results found',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _results.length,
          itemBuilder: (context, index) {
            final result = _results[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${result.pageNumber}'),
                ),
                title: Text(
                  result.text,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  result.context,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: result.isOcrResult
                    ? const Icon(Icons.document_scanner, size: 20)
                    : result.semanticScore != null
                        ? Text('${(result.semanticScore! * 100).round()}%')
                        : null,
                onTap: () {
                  // Jump to page
                  Navigator.pop(context, result.pageNumber);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPatternChip(String pattern, String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _searchController.text = pattern;
      },
    );
  }
}

enum SearchType {
  basic,
  regex,
  ocr,
  semantic,
}
