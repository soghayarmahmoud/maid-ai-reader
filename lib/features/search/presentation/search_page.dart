import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../core/constants/app_colors.dart';
import '../../pdf_reader/presentation/pdf_reader_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, dynamic>> _searchResults = [];
  List<String> _recentSearches = [];
  bool _isSearching = false;
  List<Map<String, dynamic>> _allFiles = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _loadAllFiles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    try {
      final box = await Hive.openBox('search_history');
      final searches =
          box.get('recent_searches', defaultValue: <String>[]) as List;
      setState(() {
        _recentSearches = searches.cast<String>().toList().reversed.toList();
      });
    } catch (e) {
      print('Error loading recent searches: $e');
    }
  }

  Future<void> _loadAllFiles() async {
    try {
      final box = await Hive.openBox('recent_files');
      final files = <Map<String, dynamic>>[];

      for (var key in box.keys) {
        final data = box.get(key);
        if (data is Map) {
          files.add({
            'path': data['path']?.toString() ?? '',
            'name': data['name']?.toString() ?? 'Unknown',
            'openedAt': data['openedAt'] ?? 0,
          });
        }
      }

      setState(() {
        _allFiles = files;
      });
    } catch (e) {
      print('Error loading files: $e');
    }
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Search through files by name
    final results = _allFiles.where((file) {
      final name = (file['name'] as String).toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    // Save search to history
    _saveSearch(query);

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  Future<void> _saveSearch(String query) async {
    try {
      final box = await Hive.openBox('search_history');
      final searches =
          box.get('recent_searches', defaultValue: <String>[]) as List;
      final searchList = searches.cast<String>().toList();

      // Remove duplicate if exists
      searchList
          .removeWhere((item) => item.toLowerCase() == query.toLowerCase());

      // Add to front
      searchList.insert(0, query);

      // Keep only last 10 searches
      if (searchList.length > 10) {
        searchList.removeLast();
      }

      await box.put('recent_searches', searchList);
    } catch (e) {
      print('Error saving search: $e');
    }
  }

  void _clearSearchHistory() async {
    try {
      final box = await Hive.openBox('search_history');
      await box.put('recent_searches', <String>[]);
      setState(() {
        _recentSearches = [];
      });
    } catch (e) {
      print('Error clearing history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF5F3FF),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: _performSearch,
                decoration: InputDecoration(
                  hintText: 'Search documents...',
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.primary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            // Results or Recent Searches
            Expanded(
              child: _isSearching
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary))
                  : _searchController.text.isEmpty
                      ? _buildRecentSearches(isDark)
                      : _searchResults.isEmpty
                          ? _buildNoResults()
                          : _buildSearchResults(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches(bool isDark) {
    return ListView(
      children: [
        if (_recentSearches.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: _clearSearchHistory,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentSearches.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.history, color: AppColors.primary),
              title: Text(
                _recentSearches[index],
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                _searchController.text = _recentSearches[index];
                _performSearch(_recentSearches[index]);
              },
            );
          },
        ),
        if (_recentSearches.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.search,
                    size: 64,
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No searches yet',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchResults(bool isDark) {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final file = _searchResults[index];
        final name = file['name'] as String;
        final path = file['path'] as String;

        return ListTile(
          leading: Icon(
            name.toLowerCase().endsWith('.pdf')
                ? Icons.picture_as_pdf
                : Icons.insert_drive_file,
            color: AppColors.primary,
          ),
          title: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            path,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PdfReaderPage(filePath: path),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNoResults() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No documents found',
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
