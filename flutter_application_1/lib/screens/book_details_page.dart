import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book_model.dart';

class BookDetailsPage extends StatefulWidget {
  final BookModel book;
  const BookDetailsPage({super.key, required this.book});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> with TickerProviderStateMixin {
  late TabController _feedbackTabController;
  final TextEditingController _commentController = TextEditingController();
  
  String _readingStatus = "Выберите статус";
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _feedbackTabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _feedbackTabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  // --- МЕТОД ОТПРАВКИ (БЕЗ ВЫЛЕТОВ) ---
  Future<void> _submitComment() async {
    if (_commentController.text.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('comments').add({
      'bookId': widget.book.id,
      'userId': user?.uid,
      'userName': user?.displayName ?? "Аноним",
      'userAvatar': user?.photoURL ?? "",
      'text': _commentController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _commentController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Комментарий добавлен!")));
    }
  }

  // --- МЕНЮ СТАТУСОВ ---
  void _showStatusMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statusTile("Читаю"),
            _statusTile("Собираюсь прочитать"),
            _statusTile("Прочитано"),
            _statusTile("Не интересно"),
          ],
        );
      },
    );
  }

  Widget _statusTile(String status) {
    return ListTile(
      title: Text(status),
      onTap: () {
        setState(() => _readingStatus = status);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildMenuTile(String title, IconData icon, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.blueAccent),
          title: Text(title, style: const TextStyle(fontSize: 16)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap,
        ),
        const Divider(height: 1, indent: 50),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- БЛОК 1: ИНФО (ВОЗВРАЩЕНО ВСЁ) ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(book.coverUrl, height: 180, width: 120, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(book.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(book.author, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                        Text("Год: ${book.publishDate}"),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          children: book.tags.map((tag) => Chip(label: Text(tag, style: const TextStyle(fontSize: 10)))).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- БЛОК 2: ЦИКЛ И ЛАЙКИ ---
            if (book.seriesName != null)
              _buildMenuTile("Цикл: ${book.seriesName}", Icons.layers, () {}),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                    onPressed: () => setState(() => _isLiked = !_isLiked),
                  ),
                  const Text("Лайк"),
                  const Spacer(),
                  TextButton.icon(onPressed: () {}, icon: const Icon(Icons.card_giftcard), label: const Text("Подарок")),
                ],
              ),
            ),

            // --- БЛОК 3: КНОПКИ И СТАТУС ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  OutlinedButton(
                    onPressed: _showStatusMenu,
                    style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: Text(_readingStatus),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: ElevatedButton(onPressed: () {}, child: const Text("Купить"))),
                      const SizedBox(width: 8),
                      Expanded(child: ElevatedButton(onPressed: () {}, child: const Text("Читать"))),
                    ],
                  ),
                ],
              ),
            ),

            // --- БЛОК 4: ПУБЛИКАТОР ---
            ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(book.publisherAvatar)),
              title: Text(book.publisherName),
              subtitle: const Text("Опубликовал книгу"),
              trailing: ElevatedButton(onPressed: () {}, child: const Text("Подписаться")),
            ),

            const Divider(),

            // --- БЛОК 5: МЕНЮ (СТОЛБЦОМ) ---
            _buildMenuTile("Оглавление", Icons.list_alt, () {}),
            _buildMenuTile("Статистика", Icons.bar_chart, () {}),
            _buildMenuTile("Рецензии", Icons.rate_review, () {}),
            _buildMenuTile("Подарки", Icons.card_giftcard, () {}),
            _buildMenuTile("Циклы", Icons.library_books, () {}),

            const Divider(),

            // --- БЛОК 6: КОММЕНТАРИИ (СПРАВА) ---
            Align(
              alignment: Alignment.centerRight,
              child: TabBar(
                controller: _feedbackTabController,
                isScrollable: true,
                tabs: const [Tab(text: "Комментарии")],
              ),
            ),
            SizedBox(
              height: 350,
              child: TabBarView(
                controller: _feedbackTabController,
                children: [_buildCommentSection()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: "Напишите комментарий...",
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: _submitComment,
              ),
            ),
          ),
        ),
        const Expanded(child: Center(child: Text("Здесь появятся комментарии"))),
      ],
    );
  }
}