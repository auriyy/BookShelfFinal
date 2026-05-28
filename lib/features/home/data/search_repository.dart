import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/book_repository.dart';
import '../../library/domain/models/book.dart';
import '../../../../core/local_storage/shared_prefs_service.dart';

void _setupCacheTimer(Ref ref) {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), () {
    link.close();
  });
  ref.onDispose(() => timer.cancel());
}

final searchBooksProvider = FutureProvider.autoDispose.family<List<Book>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  _setupCacheTimer(ref);
  return await ref.watch(bookRepositoryProvider).searchBooks(query);
});

final booksByAuthorNameProvider = FutureProvider.autoDispose.family<List<Book>, String>((ref, authorName) async {
  if (authorName.trim().isEmpty) return [];
  _setupCacheTimer(ref);
  return await ref.watch(bookRepositoryProvider).searchByAuthor(authorName);
});

final workDetailsProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, workId) async {
  if (workId.isEmpty) return {};
  _setupCacheTimer(ref);
  return await ref.watch(bookRepositoryProvider).getWorkDetails(workId);
});

final authorDetailsProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, authorId) async {
  if (authorId.isEmpty) return {};
  _setupCacheTimer(ref);
  return await ref.watch(bookRepositoryProvider).getAuthorDetails(authorId);
});

final authorWorksProvider = FutureProvider.autoDispose.family<List<Book>, String>((ref, authorId) async {
  if (authorId.isEmpty) return [];
  _setupCacheTimer(ref);
  return await ref.watch(bookRepositoryProvider).getAuthorWorks(authorId);
});

final lastSearchQueryProvider = StateNotifierProvider<LastSearchNotifier, String>((ref) {
  final prefsService = ref.watch(sharedPrefsServiceProvider);
  return LastSearchNotifier(prefsService);
});

class LastSearchNotifier extends StateNotifier<String> {
  final SharedPrefsService _prefsService;

  LastSearchNotifier(this._prefsService) : super(_prefsService.getLastSearchQuery());

  Future<void> updateSearchQuery(String query) async {
    if (state == query) return;
    state = query;
    await _prefsService.saveLastSearchQuery(query);
  }
}