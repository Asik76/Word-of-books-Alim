import 'package:cloud_firestore/cloud_firestore.dart';

class BookModel {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String description;
  final String publishDate; // Дата или год публикации
  final List<String> tags;   // Теги (жанры)
  
  // Раздел "Цикл"
  final String? seriesName;  // Название цикла (может быть null, если нет цикла)
  final int? bookNumberInSeries; // Номер книги в цикле

  // Информация о публикаторе (кто выложил книгу)
  final String publisherId;
  final String publisherName;
  final String publisherAvatar;

  // Ссылки на файлы или статус
  final String? fileUrl; // Для скачивания и офлайн-чтения
  final bool isPaid;    // Платная книга или нет (для кнопки "Купить")

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.description,
    required this.publishDate,
    required this.tags,
    this.seriesName,
    this.bookNumberInSeries,
    required this.publisherId,
    required this.publisherName,
    required this.publisherAvatar,
    this.fileUrl,
    this.isPaid = false,
  });

  // Преобразование данных из Firebase в объект модели
  factory BookModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return BookModel(
      id: doc.id,
      title: data['title'] ?? 'Без названия',
      author: data['author'] ?? 'Неизвестный автор',
      coverUrl: data['coverUrl'] ?? '',
      description: data['description'] ?? '',
      publishDate: data['publishDate'] ?? '',
      // Безопасное приведение списка тегов
      tags: List<String>.from(data['tags'] ?? []),
      seriesName: data['seriesName'],
      bookNumberInSeries: data['bookNumberInSeries'],
      publisherId: data['publisherId'] ?? '',
      publisherName: data['publisherName'] ?? 'Пользователь',
      publisherAvatar: data['publisherAvatar'] ?? '',
      fileUrl: data['fileUrl'],
      isPaid: data['isPaid'] ?? false,
    );
  }

  // Метод для превращения обратно в Map (если захочешь добавлять книги через приложение)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'description': description,
      'publishDate': publishDate,
      'tags': tags,
      'seriesName': seriesName,
      'bookNumberInSeries': bookNumberInSeries,
      'publisherId': publisherId,
      'publisherName': publisherName,
      'publisherAvatar': publisherAvatar,
      'fileUrl': fileUrl,
      'isPaid': isPaid,
    };
  }
}