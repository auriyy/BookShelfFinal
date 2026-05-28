import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/data/book_repository.dart';
import '../../domain/models/book.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

enum BookSortType {
  none,         
  newestFirst, 
  oldestFirst, 
}

final bookSortTypeProvider = StateProvider<BookSortType>((ref) => BookSortType.none);

final searchBooksProvider = FutureProvider<List<Book>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  
  if (query.trim().isEmpty) {
    return [];
  }

  final repository = ref.watch(bookRepositoryProvider);
  
  return repository.searchBooks(query);
});

final sortedBooksProvider = Provider<AsyncValue<List<Book>>>((ref) {
  final booksAsync = ref.watch(searchBooksProvider);
  final sortType = ref.watch(bookSortTypeProvider);

  return booksAsync.whenData((books) {
    final List<Book> sortedList = List.from(books);

    switch (sortType) {
      case BookSortType.newestFirst:
        sortedList.sort((a, b) {
          if (a.firstPublishYear == null) return 1;
          if (b.firstPublishYear == null) return -1;
          return b.firstPublishYear!.compareTo(a.firstPublishYear!);
        });
        break;
        
      case BookSortType.oldestFirst:
        sortedList.sort((a, b) {
          if (a.firstPublishYear == null) return 1;
          if (b.firstPublishYear == null) return -1;
          return a.firstPublishYear!.compareTo(b.firstPublishYear!);
        });
        break;
        
      case BookSortType.none:
        break;
    }
    return sortedList;
  });
});