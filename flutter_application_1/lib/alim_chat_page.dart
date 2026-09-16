import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'ai_service.dart';

class AlimScreen extends StatefulWidget {
  final Function(int)? onNavigate;
  const AlimScreen({super.key, this.onNavigate});

  @override
  State<AlimScreen> createState() => _AlimScreenState();
}

class _AlimScreenState extends State<AlimScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final AIService _aiService = AIService();

  // Функция поиска книги в Firebase
  Future<void> _searchAndOpenBook(String title) async {
    try {
      var result = await FirebaseFirestore.instance
          .collection('books')
          .where('title', isEqualTo: title)
          .get();

      if (result.docs.isNotEmpty) {
        var bookData = result.docs.first.data();
        String author = bookData['author'] ?? 'Автор не указан';
        setState(() {
          _messages.insert(0, {
            "text": "Я нашел книгу «$title». Автор: $author. Открываю информацию...",
            "isUser": false
          });
        });
        // Здесь можно добавить переход на экран самой книги, если он готов
      } else {
        setState(() {
          _messages.insert(0, {
            "text": "К сожалению, книги «$title» нет в нашей базе.",
            "isUser": false
          });
        });
      }
    } catch (e) {
      print("Ошибка поиска: $e");
    }
  }

  void _sendMessage() async {
    String userText = _controller.text.trim();
    if (userText.isEmpty) return;

    // 1. Отображаем сообщение пользователя
    setState(() {
      _messages.insert(0, {"text": userText, "isUser": true});
      _controller.clear();
    });

    String lowerText = userText.toLowerCase();

    // 2. Логика навигации по вкладкам
    if (lowerText.contains("открой профиль")) {
      widget.onNavigate?.call(4);
      return;
    } else if (lowerText.contains("открой книги") || lowerText.contains("библиотеку")) {
      widget.onNavigate?.call(0);
      return;
    }
    if (lowerText.contains("открой чат")) {
       widget.onNavigate?.call(1);
      return;
    } else if (lowerText.contains("открой рейтинг")) {
       widget.onNavigate?.call(3);
      return;
    } else if (lowerText.contains("открой алима") || lowerText.contains("на главную")) {
       widget.onNavigate?.call(2);
      return;
    }

    // 3. Логика поиска книги
    if (lowerText.contains("найди книгу")) {
      String bookName = userText.split("найди книгу").last.trim();
      await _searchAndOpenBook(bookName);
      return;
    }

    // 4. Обычный ответ от ИИ
    try {
      String aiResponse = await _aiService.askAI(userText);
      setState(() {
        _messages.insert(0, {"text": aiResponse, "isUser": false});
      });
    } catch (e) {
      setState(() {
        _messages.insert(0, {
          "text": "Ошибка: $e", 
          "isUser": false
        });
      });
    }
  }

  void _showAttachmentMenu() {
  showDialog(
    context: context,
    barrierColor: Colors.transparent, // Делаю фон прозрачным, чтобы видеть чат
    builder: (BuildContext context) {
      return Stack(
        children: [
          Positioned(
            left: 20,
            bottom: 90, // Высота над панелью ввода
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 220,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1F1F), 
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPopupItem(Icons.camera_alt, "Камера", () {
                      Navigator.pop(context);
                      // Твоя логика камеры
                    }),
                    _buildPopupItem(Icons.image, "Галерея", () {
                      Navigator.pop(context);
                      // Логика галереи
                    }),
                    _buildPopupItem(Icons.insert_drive_file, "Файлы", () {
                      Navigator.pop(context);
                      // Логика файлов
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

// Вспомогательный виджет для пунктов меню
Widget _buildPopupItem(IconData icon, String title, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 22),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'];
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: isUser ? const Radius.circular(15) : const Radius.circular(0),
                        bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      msg['text'],
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildInputPanel(),
        ],
      ),
    );
  }

  Widget _buildInputPanel() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.blueAccent),
            onPressed: _showAttachmentMenu,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Спроси Алима...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1F1F1F),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic, color: Colors.blueAccent),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}