class Book {
  final String key;
  final String title;
  final List<String>? authorName;
  final int? coverI;
  final int? firstPublishYear;
  final List<String>? subject;

  Book({
    required this.key,
    required this.title,
    this.authorName,
    this.coverI,
    this.firstPublishYear,
    this.subject,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    List<String>? parsedAuthors;
    if (json['author_name'] != null) {
      if (json['author_name'] is List) {
        parsedAuthors = List<String>.from((json['author_name'] as List).map((e) => e.toString()));
      }
    } else if (json['authors'] != null && json['authors'] is List) {
      final List authorsList = json['authors'] as List;
      parsedAuthors = [];
      for (var authorItem in authorsList) {
        if (authorItem is Map) {
          if (authorItem['author'] is Map) {
            parsedAuthors.add(authorItem['author']['name']?.toString() ?? authorItem['author']['key']?.toString() ?? '');
          } else if (authorItem['name'] != null) {
            parsedAuthors.add(authorItem['name'].toString());
          }
        }
      }
      if (parsedAuthors.isEmpty) parsedAuthors = null;
    }

    int? parsedCoverId;
    if (json['cover_i'] is int) {
      parsedCoverId = json['cover_i'] as int;
    } else if (json['cover'] is int) {
      parsedCoverId = json['cover'] as int;
    } else if (json['covers'] is List && (json['covers'] as List).isNotEmpty) {
      final firstCover = (json['covers'] as List).first;
      if (firstCover is int) {
        parsedCoverId = firstCover;
      } else {
        parsedCoverId = int.tryParse(firstCover.toString());
      }
    }

    int? parsedYear;
    if (json['first_publish_year'] is int) {
      parsedYear = json['first_publish_year'] as int;
    } else if (json['publish_date'] != null) {
      final dateStr = json['publish_date'].toString();
      final yearMatch = RegExp(r'\d{4}').firstMatch(dateStr);
      if (yearMatch != null) {
        parsedYear = int.tryParse(yearMatch.group(0) ?? '');
      }
    }

    return Book(
      key: json['key'] as String? ?? '',
      title: json['title'] as String? ?? 'Без назви',
      authorName: parsedAuthors,
      coverI: parsedCoverId,
      firstPublishYear: parsedYear,
      subject: json['subject'] != null && json['subject'] is List
          ? (json['subject'] as List)
              .map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'title': title,
      'author_name': authorName,
      'cover_i': coverI,
      'first_publish_year': firstPublishYear,
      'subject': subject,
    };
  }
}