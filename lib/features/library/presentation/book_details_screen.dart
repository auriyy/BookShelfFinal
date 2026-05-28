import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/library_repository.dart';
import '../domain/models/book.dart';
import '../domain/models/user_book.dart';
import 'package:bookshelf/core/localization/l10n/app_localizations.dart';

class BookDetailsScreen extends ConsumerWidget {
  final String bookId;
  final Book? book;

  const BookDetailsScreen({
    super.key,
    required this.bookId,
    this.book,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final currentBook = book;
    
    if (currentBook == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(localizations.book_data_missing)),
      );
    }

    final title = currentBook.title;
    final authors = currentBook.authorName?.join(', ') ?? localizations.unknown_author;
    final coverUrl = currentBook.coverI != null
        ? 'https://covers.openlibrary.org/b/id/${currentBook.coverI}-L.jpg'
        : null;

    final userBooksAsync = ref.watch(userBooksStreamProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            stretch: true,
            backgroundColor: theme.colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2)),
                  Center(
                    child: Hero(
                      tag: 'cover_${currentBook.key}',
                      child: Container(
                        height: 220,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: coverUrl != null
                            ? Image.network(coverUrl, fit: BoxFit.cover)
                            : Container(
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: Icon(Icons.book_rounded, size: 64, color: theme.colorScheme.primary),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(authors, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
                  const SizedBox(height: 16),
                  
                  // --- БЛОК ЖАНРІВ (SUBJECTS) ---
                  if (currentBook.subject != null && currentBook.subject!.isNotEmpty) ...[
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: currentBook.subject!.take(5).map((genre) {
                        return Chip(
                          label: Text(
                            genre,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                          backgroundColor: theme.colorScheme.secondaryContainer.withValues(alpha: 0.05),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const Divider(),
                  const SizedBox(height: 16),
                  Text(localizations.about_book, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildInfoRow(context, Icons.calendar_today_rounded, localizations.publish_year, currentBook.firstPublishYear?.toString() ?? localizations.unknown_value),
                  _buildInfoRow(context, Icons.fingerprint_rounded, 'Open Library ID', bookId),
                  _buildInfoRow(context, Icons.language_rounded, localizations.original_language, localizations.lang_en),
                  const SizedBox(height: 32),
                  
                  userBooksAsync.when(
                    data: (libraryBooks) {
                      final bool isAlreadyInLibrary = libraryBooks.any((b) => b.book.key == currentBook.key);

                      if (isAlreadyInLibrary) {
                        final existingUserBook = libraryBooks.firstWhere(
                          (b) => b.book.key == currentBook.key,
                        );
                        return _buildExistingBookActions(context, ref, existingUserBook, currentBook);
                      } else {
                        return FilledButton.icon(
                          onPressed: () => _showStatusBottomSheet(context, ref, null, currentBook),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.bookmark_add_rounded),
                          label: Text(localizations.add_to_library, style: const TextStyle(fontSize: 16)),
                        );
                      }
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingBookActions(BuildContext context, WidgetRef ref, UserBook userBook, Book currentBook) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(_getStatusIcon(userBook.status), color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getStatusText(context, userBook.status),
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _showStatusBottomSheet(context, ref, userBook, currentBook),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.edit_note_rounded),
                label: Text(localizations.change_status_btn),
              ),
            ],
          ),
        ),
        
        if (userBook.rating != null || (userBook.review != null && userBook.review!.isNotEmpty)) ...[
          const SizedBox(height: 24),
          Text(localizations.my_review, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (userBook.rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          '${localizations.my_rating}: ',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${userBook.rating} / 10',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  if (userBook.rating != null && userBook.review != null && userBook.review!.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(height: 1),
                    ),
                  if (userBook.review != null && userBook.review!.isNotEmpty) ...[
                    Text(
                      localizations.review_label,
                      style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userBook.review!,
                      style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  IconData _getStatusIcon(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.reading: return Icons.menu_book_rounded;
      case ReadingStatus.completed: return Icons.check_circle_rounded;
      case ReadingStatus.backlog: return Icons.bookmark_rounded;
    }
  }

  String _getStatusText(BuildContext context, ReadingStatus status) {
    final localizations = AppLocalizations.of(context)!;
    switch (status) {
      case ReadingStatus.reading: return localizations.status_reading;
      case ReadingStatus.completed: return localizations.status_completed;
      case ReadingStatus.backlog: return localizations.status_backlog;
    }
  }

  void _showStatusBottomSheet(BuildContext context, WidgetRef ref, UserBook? existingBook, Book currentBook) {
    final reviewController = TextEditingController(text: existingBook?.review ?? '');
    final localizations = AppLocalizations.of(context)!;
    
    bool hasRating = existingBook?.rating != null;
    int selectedRating = existingBook?.rating ?? 5; 
    ReadingStatus selectedStatus = existingBook?.status ?? ReadingStatus.backlog;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final theme = Theme.of(context);
        
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      existingBook != null 
                          ? localizations.manage_book_title 
                          : localizations.add_to_library_title, 
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), 
                      textAlign: TextAlign.center
                    ),
                    const SizedBox(height: 20),
                    
                    Text(localizations.move_to_list, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    SegmentedButton<ReadingStatus>(
                      segments: [
                        ButtonSegment(value: ReadingStatus.reading, label: Text(localizations.status_reading_tab), icon: const Icon(Icons.menu_book_rounded)),
                        ButtonSegment(value: ReadingStatus.completed, label: Text(localizations.status_completed_tab), icon: const Icon(Icons.check_circle_rounded)),
                        ButtonSegment(value: ReadingStatus.backlog, label: Text(localizations.status_backlog_tab), icon: const Icon(Icons.bookmark_rounded)),
                      ],
                      selected: {selectedStatus},
                      onSelectionChanged: (Set<ReadingStatus> newSelection) {
                        setModalState(() {
                          selectedStatus = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    CheckboxListTile(
                      title: Text(localizations.want_to_rate),
                      value: hasRating,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (bool? value) {
                        setModalState(() {
                          hasRating = value ?? false;
                        });
                      },
                    ),

                    if (hasRating) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(localizations.your_rating_label, style: theme.textTheme.titleSmall),
                          Text(
                            '$selectedRating / 10',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: selectedRating.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: selectedRating.toString(),
                        onChanged: (value) {
                          setModalState(() {
                            selectedRating = value.toInt();
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 16),

                    Text(localizations.review_text_field_label, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reviewController,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: localizations.review_hint,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerLow,
                      ),
                    ),
                    const SizedBox(height: 24),

                    FilledButton.icon(
                      onPressed: () {
                        _saveBookWithStatus(
                          context, 
                          ref, 
                          selectedStatus, 
                          existingBook,
                          hasRating ? selectedRating : null, 
                          reviewController.text.trim(),
                          currentBook,
                        );
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.save_rounded),
                      label: Text(localizations.save_changes_btn, style: const TextStyle(fontSize: 16)),
                    ),
                    
                    if (existingBook != null) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          await ref.read(libraryRepositoryProvider).removeBook(currentBook.key);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(localizations.book_deleted_msg), behavior: SnackBarBehavior.floating),
                            );
                          }
                        },
                        icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                        label: Text(localizations.delete_from_library_btn, style: TextStyle(color: theme.colorScheme.error)),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _saveBookWithStatus(
    BuildContext context, 
    WidgetRef ref, 
    ReadingStatus status, 
    UserBook? existingBook,
    int? rating,
    String review,
    Book currentBook,
  ) async {
    Navigator.pop(context);
    final localizations = AppLocalizations.of(context)!;
    
    final finalReview = review.isEmpty ? null : review;
    final userBook = existingBook != null
        ? existingBook.copyWith(
            status: status,
            rating: rating, 
            review: finalReview,
            removeRating: rating == null,
            removeReview: finalReview == null,
            totalPages: status == ReadingStatus.reading ? 100 : existingBook.totalPages,
            currentPage: status == ReadingStatus.reading ? 1 : existingBook.currentPage,
          )
        : UserBook(
            book: currentBook,
            status: status,
            rating: rating, 
            review: finalReview,
            totalPages: status == ReadingStatus.reading ? 100 : 0,
            currentPage: status == ReadingStatus.reading ? 1 : 0,
          );

    try {
      await ref.read(libraryRepositoryProvider).saveBook(userBook);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(existingBook != null 
                ? localizations.book_updated_msg 
                : localizations.book_added_msg),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.save_error_msg} $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text('$label: ', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface), textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}