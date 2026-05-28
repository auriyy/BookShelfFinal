import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../library/domain/models/book.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository(Dio());
});

class BookRepository {
  final Dio _dio;

  BookRepository(this._dio);

  Future<List<Book>> searchBooks(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await _dio.get(
        'https://openlibrary.org/search.json',
        queryParameters: {
          'q': query,
          'limit': 20,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final List<dynamic> docs = data['docs'] as List<dynamic>? ?? [];

        return docs.map((doc) => Book.fromJson(doc as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Не вдалося отримати дані з сервера');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception('Помилка мережі: $errorMessage');
    } catch (e) {
      throw Exception('Щось пішло не так: $e');
    }
  }

  Future<List<Book>> searchByAuthor(String authorName) async {
    if (authorName.trim().isEmpty) return [];

    try {
      final response = await _dio.get(
        'https://openlibrary.org/search.json',
        queryParameters: {
          'author': authorName,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final List<dynamic> docs = data['docs'] as List<dynamic>? ?? [];

        return docs.map((doc) => Book.fromJson(doc as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Не вдалося знайти книги цього автора');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception('Помилка мережі: $errorMessage');
    } catch (e) {
      throw Exception('Щось пішло не так: $e');
    }
  }

  Future<Map<String, dynamic>> getWorkDetails(String workId) async {
    final cleanId = workId.replaceAll('/works/', '');
    
    try {
      final response = await _dio.get('https://openlibrary.org/works/$cleanId.json');

      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Не вдалося завантажити деталі твору');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception('Помилка мережі: $errorMessage');
    } catch (e) {
      throw Exception('Щось пішло не так: $e');
    }
  }

  Future<Map<String, dynamic>> getAuthorDetails(String authorId) async {
    final cleanId = authorId.replaceAll('/authors/', '');

    try {
      final response = await _dio.get('https://openlibrary.org/authors/$cleanId.json');

      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Не вдалося завантажити дані автора');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception('Помилка мережі: $errorMessage');
    } catch (e) {
      throw Exception('Щось пішло не так: $e');
    }
  }

  Future<List<Book>> getAuthorWorks(String authorId) async {
    final cleanId = authorId.replaceAll('/authors/', '');

    try {
      final response = await _dio.get('https://openlibrary.org/authors/$cleanId/works.json');

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final List<dynamic> entries = data['entries'] as List<dynamic>? ?? [];

        return entries.map((entry) => Book.fromJson(entry as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Не вдалося завантажити список книг автора');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception('Помилка мережі: $errorMessage');
    } catch (e) {
      throw Exception('Щось пішло не так: $e');
    }
  }

  String getCoverUrl(int? coverId) {
    if (coverId == null || coverId == 0) {
      return 'https://openlibrary.org/images/icons/avatar_book-lg.png';
    }
    return 'https://covers.openlibrary.org/b/id/$coverId-L.jpg';
  }
}