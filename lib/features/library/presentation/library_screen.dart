import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookshelf/core/localization/l10n/app_localizations.dart';
import '../domain/library_repository.dart';
import '../domain/models/user_book.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(userBooksStreamProvider);
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          title: Text(
            loc.lib_title, 
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            tabs: [
              Tab(icon: const Icon(Icons.menu_book_rounded), text: loc.status_reading_tab),
              Tab(icon: const Icon(Icons.check_circle_outline_rounded), text: loc.status_completed_tab),
              Tab(icon: const Icon(Icons.bookmark_border_rounded), text: loc.status_backlog_tab),
            ],
          ),
        ),
        body: booksAsync.when(
          data: (books) {
            final reading = books.where((b) => b.status == ReadingStatus.reading).toList();
            final completed = books.where((b) => b.status == ReadingStatus.completed).toList();
            final backlog = books.where((b) => b.status == ReadingStatus.backlog).toList();

            return TabBarView(
              children: [
                _buildBookList(context, ref, reading, loc.lib_empty_reading),
                _buildBookList(context, ref, completed, loc.lib_empty_completed),
                _buildBookList(context, ref, backlog, loc.lib_empty_backlog),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('${loc.error}: $err')),
        ),
      ),
    );
  }

  Widget _buildBookList(BuildContext context, WidgetRef ref, List<UserBook> userBooks, String emptyMessage) {
    if (userBooks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: userBooks.length,
      itemBuilder: (context, index) {
        final userBook = userBooks[index];
        final theme = Theme.of(context);
        final loc = AppLocalizations.of(context)!;
        
        final double progressPercent = userBook.totalPages > 0 
            ? (userBook.currentPage / userBook.totalPages) 
            : 0.0;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            onTap: () {
              final cleanId = userBook.book.key.replaceAll('/works/', '');
              context.go('/home/details/$cleanId', extra: userBook.book);
            },
            onLongPress: () {
              _showChangeStatusSheet(context, ref, userBook);
            },
            leading: userBook.book.coverI != null
                ? Image.network(
                    'https://covers.openlibrary.org/b/id/${userBook.book.coverI}-S.jpg',
                    width: 40,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.book),
            title: Text(userBook.book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userBook.book.authorName?.join(', ') ?? loc.unknown_author),
                if (userBook.status == ReadingStatus.reading && userBook.totalPages > 0) ...[
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 6,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progressPercent.clamp(0.0, 1.0),
                      child: Container(color: theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${userBook.currentPage} ${loc.page_from} ${userBook.totalPages} ${loc.page_short}. (${(progressPercent * 100).toInt()}%)',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.more_vert_rounded, color: theme.colorScheme.onSurfaceVariant),
              onPressed: () {
                _showChangeStatusSheet(context, ref, userBook);
              },
            ),
          ),
        );
      },
    );
  }

  void _showChangeStatusSheet(BuildContext context, WidgetRef ref, UserBook userBook) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                loc.sheet_title,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                userBook.book.title,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.menu_book_rounded, color: Colors.blue),
                title: Text(loc.move_to_reading),
                trailing: userBook.status == ReadingStatus.reading ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () => _updateStatus(context, ref, userBook, ReadingStatus.reading),
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_rounded, color: Colors.green),
                title: Text(loc.move_to_completed),
                trailing: userBook.status == ReadingStatus.completed ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () => _updateStatus(context, ref, userBook, ReadingStatus.completed),
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_rounded, color: Colors.orange),
                title: Text(loc.move_to_backlog),
                trailing: userBook.status == ReadingStatus.backlog ? const Icon(Icons.check, color: Colors.orange) : null,
                onTap: () => _updateStatus(context, ref, userBook, ReadingStatus.backlog),
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                title: Text(loc.delete_from_lib, style: TextStyle(color: theme.colorScheme.error)),
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(libraryRepositoryProvider).removeBook(userBook.book.key);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(loc.snack_deleted), 
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateStatus(BuildContext context, WidgetRef ref, UserBook userBook, ReadingStatus newStatus) async {
    final loc = AppLocalizations.of(context)!;
    Navigator.pop(context);
    if (userBook.status == newStatus) return;

    final updatedBook = userBook.copyWith(
      status: newStatus,
      totalPages: newStatus == ReadingStatus.reading ? 350 : userBook.totalPages,
      currentPage: newStatus == ReadingStatus.reading ? 45 : userBook.currentPage,
    );

    await ref.read(libraryRepositoryProvider).saveBook(updatedBook);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.snack_status_changed),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}