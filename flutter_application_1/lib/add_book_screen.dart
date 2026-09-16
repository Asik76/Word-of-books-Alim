import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // Функция отправки в Firebase
  Future<void> _saveBook() async {
    if (_titleController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('books').add({
      'title': _titleController.text,
      'description': _descController.text,
      'authorName': 'Avtor', 
      'coverUrl': 'https://picsum.photos/200/300', // Случайная картинка для теста
      'likes': 0,
      'year': '2026',
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Книга успешно добавлена!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Новое произведение")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Название книги"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Краткое описание"),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: _saveBook,
              child: const Text("ОПУБЛИКОВАТЬ"),
            ),
          ],
        ),
      ),
    );
  }
}