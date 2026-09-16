import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';
import 'book_details_page.dart';

class BookListPage extends StatelessWidget {
  const BookListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Библиотека"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('books').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Ошибка загрузки"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Библиотека пуста"));
          }

          List<BookModel> books = snapshot.data!.docs
              .map((doc) => BookModel.fromFirestore(doc))
              .toList();

          // РЕАЛИЗАЦИЯ СЕТКИ 20x8
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Скролл влево-вправо
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical, // Скролл вверх-вниз
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  // Задаем размер полотна: 20 колонок по 150px = 3000px
                  width: 3000, 
                  // 8 строк по ~250px высоты = 2000px
                  height: 2000, 
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(), // Отключаем внутренний скролл GridView
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 20, // 20 КНИГ В СТРОКУ
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 0.6, // Соотношение сторон для обложки и текста
                    ),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailsPage(book: book),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 33, 33, 33),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4)
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. ОБЛОЖКА
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                  child: book.coverUrl.isNotEmpty
                                      ? Image.network(book.coverUrl, fit: BoxFit.cover, width: double.infinity)
                                      : Container(color: const Color.fromARGB(255, 255, 255, 255), child: const Icon(Icons.book)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 2. НАЗВАНИЕ
                                    Text(
                                      book.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    // 3. АВТОР
                                    Text(
                                      book.author,
                                      style: const TextStyle(fontSize: 10, color: const Color.fromARGB(255, 255, 255, 255)),
                                      maxLines: 1,
                                    ),
                                    // 4. ДАТА/ГОД
                                    Text(
                                      book.publishDate,
                                      style: const TextStyle(fontSize: 9, color: const Color.fromARGB(255, 255, 255, 255)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}