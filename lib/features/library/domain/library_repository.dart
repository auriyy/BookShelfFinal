import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/user_book.dart';

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final userBooksStreamProvider = StreamProvider<List<UserBook>>((ref) {
  // Активно стежимо за станом авторизації користувача
  final authState = ref.watch(authStateChangesProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value(<UserBook>[]);
      }
      final repo = ref.watch(libraryRepositoryProvider);
      return repo.getUserBooksStream(user.uid);
    },
    loading: () => Stream.value(<UserBook>[]),
    error: (err, stack) => Stream.error(err, stack),
  );
});

class LibraryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  LibraryRepository(this._firestore, this._auth);

  String get _userId => _auth.currentUser?.uid ?? '';

  Stream<List<UserBook>> getUserBooksStream(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('books')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserBook.fromMap(doc.data()))
              .toList();
        });
  }

  Future<void> saveBook(UserBook userBook) async {
    if (_userId.isEmpty) return;
    final docId = userBook.book.key.replaceAll('/works/', '');
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('books')
        .doc(docId)
        .set(userBook.toMap(), SetOptions(merge: true));
  }

  Future<void> removeBook(String bookKey) async {
    if (_userId.isEmpty) return;
    final docId = bookKey.replaceAll('/works/', '');
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('books')
        .doc(docId)
        .delete();
  }
}