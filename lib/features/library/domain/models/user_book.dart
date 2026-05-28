import 'book.dart';

enum ReadingStatus {
  reading,  
  completed, 
  backlog   
}

class UserBook {
  final Book book;
  final ReadingStatus status;
  final int? rating;  
  final String? review;   
  final int currentPage;   
  final int totalPages;   

  UserBook({
    required this.book,
    required this.status,
    this.rating,         
    this.review,          
    this.currentPage = 0,
    this.totalPages = 0,
  });

  static ReadingStatus _parseStatus(String status) {
    switch (status) {
      case 'reading': return ReadingStatus.reading;
      case 'completed': return ReadingStatus.completed;
      default: return ReadingStatus.backlog;
    }
  }

  factory UserBook.fromMap(Map<String, dynamic> map) {
    return UserBook(
      book: map['book'] != null
          ? Book.fromJson(Map<String, dynamic>.from(map['book'] as Map))
          : Book(key: '', title: 'Без назви'),
          
      status: _parseStatus(map['status'] as String? ?? 'backlog'),
      rating: map['rating'] as int?, 
      review: map['review'] as String?, 
      currentPage: map['currentPage'] as int? ?? 0,
      totalPages: map['totalPages'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'book': book.toJson(),
      'status': status.name,
      'rating': rating, 
      'review': review, 
      'currentPage': currentPage,
      'totalPages': totalPages,
    };
  }

  UserBook copyWith({
    Book? book,
    ReadingStatus? status,
    int? rating,  
    String? review,  
    int? currentPage,
    int? totalPages,
    bool removeRating = false, 
    bool removeReview = false, 
  }) {
    return UserBook(
      book: book ?? this.book,
      status: status ?? this.status,
      rating: removeRating ? null : (rating ?? this.rating),
      review: removeReview ? null : (review ?? this.review),
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}