import 'package:flutter/material.dart';

/// Advanced Search Widget with filters and options
class AdvancedSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final VoidCallback onClose;
  final Function(SearchOptions) onOptionsChanged;

  const AdvancedSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onClose,
    required this.onOptionsChanged,
  });

  @override
  State<AdvancedSearchBar> createState() => _AdvancedSearchBarState();
}

class _AdvancedSearchBarState extends State<AdvancedSearchBar> {
  bool _caseSensitive = false;
  bool _wholeWord = false;
  final List<String> _searchHistory = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search input row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  decoration: InputDecoration(
                    hintText: 'Search in PDF...',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: widget.controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              widget.controller.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      widget.onSearch(value);
                      _addToHistory(value);
                    }
                  },
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  if (widget.controller.text.isNotEmpty) {
                    widget.onSearch(widget.controller.text);
                    _addToHistory(widget.controller.text);
                  }
                },
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Search'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
                tooltip: 'Close Search',
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Search options
          Row(
            children: [
              Checkbox(
                value: _caseSensitive,
                onChanged: (value) {
                  setState(() {
                    _caseSensitive = value ?? false;
                    widget.onOptionsChanged(SearchOptions(
                      caseSensitive: _caseSensitive,
                      wholeWord: _wholeWord,
                    ));
                  });
                },
              ),
              const Text('Case sensitive'),
              const SizedBox(width: 16),
              Checkbox(
                value: _wholeWord,
                onChanged: (value) {
                  setState(() {
                    _wholeWord = value ?? false;
                    widget.onOptionsChanged(SearchOptions(
                      caseSensitive: _caseSensitive,
                      wholeWord: _wholeWord,
                    ));
                  });
                },
              ),
              const Text('Whole word'),
              const Spacer(),
              if (_searchHistory.isNotEmpty)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.history),
                  tooltip: 'Search History',
                  onSelected: (value) {
                    widget.controller.text = value;
                    setState(() {});
                  },
                  itemBuilder: (context) {
                    return _searchHistory.reversed.take(5).map((term) {
                      return PopupMenuItem<String>(
                        value: term,
                        child: Row(
                          children: [
                            const Icon(Icons.history, size: 16),
                            const SizedBox(width: 8),
                            Text(term),
                          ],
                        ),
                      );
                    }).toList();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _addToHistory(String term) {
    if (!_searchHistory.contains(term)) {
      setState(() {
        _searchHistory.add(term);
        if (_searchHistory.length > 10) {
          _searchHistory.removeAt(0);
        }
      });
    }
  }
}

class SearchOptions {
  final bool caseSensitive;
  final bool wholeWord;

  SearchOptions({
    required this.caseSensitive,
    required this.wholeWord,
  });
}
