import 'package:flutter_test/flutter_test.dart';
import '../lib/features/library/domain/models/book.dart';
import '../lib/features/library/domain/models/user_book.dart';

Map<String, dynamic> calculateStats(List<UserBook> books) {
  if (books.isEmpty) {
    return {'avgRating': 0.0, 'readingCount': 0, 'completedCount': 0, 'backlogCount': 0};
  }

  int reading = 0;
  int completed = 0;
  int backlog = 0;
  int totalRating = 0;
  int ratedBooksCount = 0;

  for (var b in books) {
    switch (b.status) {
      case ReadingStatus.reading:
        reading++;
        break;
      case ReadingStatus.completed:
        completed++;
        break;
      case ReadingStatus.backlog:
        backlog++;
        break;
    }
    if (b.rating != null) {
      totalRating += b.rating!;
      ratedBooksCount++;
    }
  }

  double avg = ratedBooksCount > 0 ? totalRating / ratedBooksCount : 0.0;

  return {
    'avgRating': avg,
    'readingCount': reading,
    'completedCount': completed,
    'backlogCount': backlog,
  };
}

bool isValidEmail(String email) {
  return email.contains('@') && email.length > 5;
}

void main() {
  group('Unit Tests - BookShelf', () {
    
    test('Парсинг JSON-відповіді від Open Library API у модель Book', () {
      final mockJson = {
        'key': '/works/OL123W',
        'title': 'Test Book',
        'author_name': ['John Doe'],
        'cover_i': 12345,
      };

      final book = Book.fromJson(mockJson);

      expect(book.key, '/works/OL123W');
      expect(book.title, 'Test Book');
    });

    test('Парсинг із Firestore Document Map у модель UserBook з null-значеннями', () {
      final mockFirestoreMap = {
        'book': {'key': '/works/OL123W', 'title': 'Test Book'},
        'status': 'reading',
        'rating': null,
        'review': null,
        'currentPage': 10,
        'totalPages': 200,
      };

      final userBook = UserBook.fromMap(mockFirestoreMap);

      expect(userBook.status, ReadingStatus.reading);
      expect(userBook.rating, isNull);
      expect(userBook.currentPage, 10);
    });

    test('Розрахунок середньої оцінки книг (пропускаючи null значення)', () {
      final books = [
        UserBook(book: Book(key: '1', title: 'B1'), status: ReadingStatus.completed, rating: 8),
        UserBook(book: Book(key: '2', title: 'B2'), status: ReadingStatus.completed, rating: 10),
        UserBook(book: Book(key: '3', title: 'B3'), status: ReadingStatus.backlog, rating: null),
      ];

      final stats = calculateStats(books);

      expect(stats['avgRating'], 9.0);
    });

    test('Правильний підрахунок кількості книг за статусами читання', () {
      final books = [
        UserBook(book: Book(key: '1', title: 'B1'), status: ReadingStatus.reading),
        UserBook(book: Book(key: '2', title: 'B2'), status: ReadingStatus.completed),
        UserBook(book: Book(key: '3', title: 'B3'), status: ReadingStatus.backlog),
        UserBook(book: Book(key: '4', title: 'B4'), status: ReadingStatus.backlog),
      ];

      final stats = calculateStats(books);

      expect(stats['readingCount'], 1);
      expect(stats['completedCount'], 1);
      expect(stats['backlogCount'], 2);
    });

    test('Валідація коректності введення Email адреси', () {
      expect(isValidEmail('test@gmail.com'), isTrue);
      expect(isValidEmail('invalid-email'), isFalse);
    });
  });
}