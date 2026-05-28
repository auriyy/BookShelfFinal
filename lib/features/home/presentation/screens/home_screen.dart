import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookshelf/core/localization/l10n/app_localizations.dart';
import '../../../../core/providers/app_settings_providers.dart';
import '../../../library/data/providers/search_provider.dart';
import '../widgets/book_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _searchController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lastQuery = ref.read(lastSearchQueryProvider);
      if (lastQuery.isNotEmpty) {
        _searchController.text = lastQuery;
        ref.read(searchQueryProvider.notifier).state = lastQuery;
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final cleanQuery = query.trim();
      ref.read(searchQueryProvider.notifier).state = cleanQuery;
      if (cleanQuery.isNotEmpty) {
        ref.read(lastSearchQueryProvider.notifier).updateSearchQuery(cleanQuery);
      }
    });
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(sortedBooksProvider);
    final currentQuery = ref.watch(searchQueryProvider);
    final currentSort = ref.watch(bookSortTypeProvider);
    
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          loc.search_data_section,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (currentQuery.isNotEmpty)
            PopupMenuButton<BookSortType>(
              icon: Icon(
                Icons.sort_rounded,
                color: currentSort != BookSortType.none 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurface,
              ),
              onSelected: (BookSortType type) {
                ref.read(bookSortTypeProvider.notifier).state = type;
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<BookSortType>>[
                const PopupMenuItem<BookSortType>(
                  value: BookSortType.none,
                  child: Row(
                    children: [
                      Icon(Icons.youtube_searched_for_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Релевантність'),
                    ],
                  ),
                ),
                const PopupMenuItem<BookSortType>(
                  value: BookSortType.newestFirst,
                  child: Row(
                    children: [
                      Icon(Icons.arrow_downward_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Нові спочатку'),
                    ],
                  ),
                ),
                const PopupMenuItem<BookSortType>(
                  value: BookSortType.oldestFirst,
                  child: Row(
                    children: [
                      Icon(Icons.arrow_upward_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Старі спочатку'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: loc.search_hint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              _debounceTimer?.cancel();
                              ref.read(searchQueryProvider.notifier).state = '';
                              ref.read(lastSearchQueryProvider.notifier).updateSearchQuery('');
                              ref.read(bookSortTypeProvider.notifier).state = BookSortType.none;
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),

            Expanded(
              child: searchResults.when(
                data: (books) {
                  if (currentQuery.isEmpty) {
                    return _buildEmptyState(
                      context,
                      loc.search_empty_welcome,
                      Icons.menu_book_rounded,
                    );
                  }

                  if (books.isEmpty) {
                    return _buildEmptyState(
                      context,
                      loc.search_no_results,
                      Icons.search_off_rounded,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      return BookCard(book: books[index]);
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 60, color: theme.colorScheme.error),
                        const SizedBox(height: 16),
                        Text(
                          loc.error,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String text, IconData icon) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 80,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}