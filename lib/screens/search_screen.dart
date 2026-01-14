import 'package:flutter/material.dart';
import '../models/thought.dart';
import '../services/hive_service.dart';
import '../widgets/thought_item.dart';
import 'thought_detail_screen.dart';

/// Screen for searching thoughts across all categories
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<Thought> _searchResults = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Perform search as user types
  void _performSearch() {
    final query = _searchController.text.trim();
    setState(() {
      if (query.isEmpty) {
        _searchResults = [];
        _hasSearched = false;
      } else {
        _searchResults = HiveService.searchThoughts(query);
        _hasSearched = true;
      }
    });
  }

  /// Navigate to thought detail screen
  void _navigateToThoughtDetail(Thought thought) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ThoughtDetailScreen(thought: thought),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = Color(0xFF4b3832);
    const secondaryColor = Color(0xFF854442);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Search Thoughts'),
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search thoughts...',
                    hintStyle: TextStyle(
                      color: primaryColor.withValues(alpha: 0.4),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: secondaryColor,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: primaryColor.withValues(alpha: 0.6),
                            ),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: primaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: primaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: secondaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  autofocus: true,
                ),
              ),
            ),
            // Results
            Expanded(
              child: _searchController.text.isEmpty && !_hasSearched
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: secondaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.search_rounded,
                              size: 64,
                              color: primaryColor.withValues(alpha: 0.4),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Search your thoughts',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: primaryColor.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Type to search across all categories',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: primaryColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _searchResults.isEmpty && _hasSearched
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.search_off_rounded,
                                  size: 64,
                                  color: primaryColor.withValues(alpha: 0.4),
                                ),
                              ),
                          const SizedBox(height: 24),
                          Text(
                            'No results found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: primaryColor.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try different keywords',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: primaryColor.withValues(alpha: 0.5),
                            ),
                          ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final thought = _searchResults[index];
                            return ThoughtItem(
                              text: thought.text,
                              createdAt: thought.createdAt,
                              onTap: () => _navigateToThoughtDetail(thought),
                              category: thought.category,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
