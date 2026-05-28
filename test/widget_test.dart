import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/features/library/domain/models/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(book.title),
        subtitle: Text(book.authorName?.first ?? 'Невідомий автор'),
      ),
    );
  }
}

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearch;
  const SearchBarWidget({super.key, required this.onSearch});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Пошук книг...')),
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => widget.onSearch(_controller.text),
        ),
      ],
    );
  }
}

class ReviewFormWidget extends StatefulWidget {
  final Function(String) onSave;
  const ReviewFormWidget({super.key, required this.onSave});

  @override
  State<ReviewFormWidget> createState() => _ReviewFormWidgetState();
}

class _ReviewFormWidgetState extends State<ReviewFormWidget> {
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(controller: _controller, decoration: const InputDecoration(labelText: 'Текст рецензії')),
        ElevatedButton(onPressed: () => widget.onSave(_controller.text), child: const Text('Зберегти')),
      ],
    );
  }
}

void main() {
  group('Widget Tests - BookShelf Components', () {
    testWidgets('Відображення назви книги та автора у BookCard', (WidgetTester tester) async {
      final sampleBook = Book(key: '1', title: 'Кобзар', authorName: ['Тарас Шевченко']);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: BookCard(book: sampleBook)),
      ));

      expect(find.text('Кобзар'), findsOneWidget);
      expect(find.text('Тарас Шевченко'), findsOneWidget);
    });
    testWidgets('Введення тексту в пошук та тригер події пошуку', (WidgetTester tester) async {
      String searchQuery = '';

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SearchBarWidget(onSearch: (query) => searchQuery = query),
        ),
      ));

      await tester.enterText(find.byType(TextField), 'Гаррі Поттер');
      // Натискаємо на кнопку пошуку
      await tester.tap(find.byType(IconButton));
      // Оновлюємо стан віджета
      await tester.pump();

      expect(searchQuery, 'Гаррі Поттер');
    });

    testWidgets('Введення та збереження тексту відгуку у формі рецензії', (WidgetTester tester) async {
      String savedReview = '';

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ReviewFormWidget(onSave: (text) => savedReview = text),
        ),
      ));

      await tester.enterText(find.byType(TextField), 'Чудова книга, рекомендую!');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(savedReview, 'Чудова книга, рекомендую!');
    });
  });
}