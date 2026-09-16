import 'dart:io';
import 'package:flutter/material.dart';

class BookTabsManagementPage extends StatefulWidget {
  final Map<String, dynamic> bookData; 
  final File? coverImage;

  const BookTabsManagementPage({
    super.key, 
    required this.bookData, 
    this.coverImage,
  });

  @override
  State<BookTabsManagementPage> createState() => _BookTabsManagementPageState();
}

class _BookTabsManagementPageState extends State<BookTabsManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- Данные из add_book_details_page.dart (для вкладки Настройки) ---
  late TextEditingController _titleController;
  late bool _isAdult;
  late bool _enableTts;
  late bool _protectedText;
  late String _downloadAccess; // "Запрещено", "Разрешено всем", "Только друзьям"

  // --- Состояние для вкладки ТЕКСТ (По макету) ---
  String _bookStatus = "Черновик"; // Может меняться на "Завершено"
  List<Map<String, String>> _chaptersList = []; // Список глав: [{'title': '...', 'text': '...'}]

  @override
  void initState() {
    super.initState();
    // Создание 2 вкладки: Настройка и Текст. 
    // изначально открывается вкладка "Текст" (индекс 1)
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);

    // Принимаем сохраненные данные из первой страницы
    _titleController = TextEditingController(text: widget.bookData['title'] ?? "Без названия");
    _isAdult = widget.bookData['isAdult'] ?? false;
    _enableTts = widget.bookData['enableTts'] ?? true;
    _protectedText = widget.bookData['protectedText'] ?? true;
    _downloadAccess = widget.bookData['downloadAccess'] ?? "Запрещено";
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // --- Вспомогательный расчет знаков и авторских листов (1 а.л. = 40000 знаков) ---
  int get _totalCharacters {
    int count = 0;
    for (var chapter in _chaptersList) {
      count += (chapter['text'] ?? '').length;
    }
    return count;
  }

  double get _totalAuthorSheets {
    return _totalCharacters / 40000;
  }

  // --- Окно добавления новой части/главы ---
  void _showAddChapterBottomSheet() {
    final TextEditingController titleCtrl = TextEditingController();
    final TextEditingController textCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20, left: 16, right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Добавление новой части", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Название части",
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textCtrl,
                maxLines: 8,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Текст произведения",
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty && textCtrl.text.isNotEmpty) {
                    setState(() {
                      _chaptersList.add({
                        'title': titleCtrl.text,
                        'text': textCtrl.text,
                      });
                    });
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF337AB7), minimumSize: const Size(double.infinity, 45)),
                child: const Text("Сохранить и добавить", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // --- Диалог подтверждения смены статуса на завершено ---
  void _showConfirmStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Изменить статус?", style: TextStyle(color: Colors.white)),
        content: const Text("Вы уверены, что хотите перевести произведение в статус 'Завершено'?", style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Отмена", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _bookStatus = "Завершено";
              });
              Navigator.pop(context);
            },
            child: const Text("Да, завершить", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        // В самом верху: Название книги и серый статус "Не опубликовано"
        title: Row(
          children: [
            Expanded(
              child: Text(
                _titleController.text, 
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text("не опубликовано", style: TextStyle(color: Colors.white70, fontSize: 11)),
            ),
          ],
        ),
        // Вкладки: Настройка и Текст
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Настройка"),
            Tab(text: "Текст"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSettingsTabView(), // Вкладка 1: Настройки
          _buildChaptersTabView(), // Вкладка 2: Страница текста 
        ],
      ),
    );
  }

  // --- ВКЛАДКА 1: НАСТРОЙКИ (КОД ИЗ ADD_BOOK_DETAILS_PAGE) ---
  Widget _buildSettingsTabView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 120,
              height: 170,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: widget.coverImage != null
                  ? ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.file(widget.coverImage!, fit: BoxFit.cover))
                  : const Center(child: Icon(Icons.book, color: Colors.grey, size: 45)),
            ),
          ),
          const SizedBox(height: 16),
          const Text("Название произведения", style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              fillColor: const Color(0xFF1E1E1E),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            ),
            onChanged: (val) => setState(() {}),
          ),
          const SizedBox(height: 12),
          // Выбор уровня скачивания внутри настроек
          const Text("Доступ к скачиванию", style: TextStyle(color: Colors.grey, fontSize: 13)),
          DropdownButton<String>(
            value: _downloadAccess,
            dropdownColor: const Color(0xFF1E1E1E),
            style: const TextStyle(color: Colors.white),
            isExpanded: true,
            items: ["Запрещено", "Разрешено всем", "Только друзьям"].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (val) => setState(() => _downloadAccess = val!),
          ),
          CheckboxListTile(
            title: const Text("Для взрослых (18+)", style: TextStyle(color: Colors.white, fontSize: 14)),
            value: _isAdult,
            onChanged: (val) => setState(() => _isAdult = val!),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            title: const Text("Включить TTS озвучку", style: TextStyle(color: Colors.white, fontSize: 14)),
            value: _enableTts,
            onChanged: (val) => setState(() => _enableTts = val!),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            title: const Text("Защита от копирования", style: TextStyle(color: Colors.white, fontSize: 14)),
            value: _protectedText,
            onChanged: (val) => setState(() => _protectedText = val!),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  // --- ВКЛАДКА 2: ТЕКСТ ---
  Widget _buildChaptersTabView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Надпись "Страница произведения"
          const Text(
            "Страница произведения",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // 2. Оранжевая плашка предупреждения в черновиках
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3A2E1A), 
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF664D24)),
            ),
            child: const Text(
              "Данное произведение находится в черновиках и его никто, кроме вас, не видит. Чтобы иметь возможность опубликовать произведение, необходимо опубликовать хотя бы одну его часть.",
              style: TextStyle(color: Color(0xFFE4A853), fontSize: 13, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Автоматический расчет размера книги (знаки и а.л.)
          Text(
            "Размер: $_totalCharacters зн., ${_totalAuthorSheets.toStringAsFixed(2)} а.л.",
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          
          // 4. Статус произведения (Черновик / Опубликовано / Завершено)
          Row(
            children: [
              const Text("Статус: ", style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text(
                _bookStatus == "Черновик" ? "черновик" : "завершено",
                style: TextStyle(
                  color: _bookStatus == "Черновик" ? Colors.orange : Colors.green, 
                  fontSize: 14, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 5. Скачивание (Запрещено / Разрешено)
          Row(
            children: [
              const Text("Скачивание: ", style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text(
                _downloadAccess == "Запрещено" ? "запрещено" : "разрешено ($_downloadAccess)",
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 6. СИНЯЯ КНОПКА: + Добавить часть
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              onPressed: _showAddChapterBottomSheet,
              icon: const Icon(Icons.add, color: Colors.white, size: 16),
              label: const Text("Добавить часть", style: TextStyle(color: Colors.white, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF337AB7), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 7. ЗЕЛЕНАЯ КНОПКА: Изменить статус на завершено
          if (_bookStatus == "Черновик")
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton.icon(
                onPressed: _showConfirmStatusDialog,
                icon: const Icon(Icons.check, color: Colors.white, size: 16),
                label: const Text("Изменить статус на 'завершено'", style: TextStyle(color: Colors.white, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5CB85C), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
          const SizedBox(height: 12),

          // 8. Строка кнопок: Ознакомительный фрагмент и Удалить
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text("Ознакомительный фрагмент", style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _chaptersList.clear();
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                child: const Text("Удалить", style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.grey, thickness: 0.5),
          const SizedBox(height: 12),

          // 9. Блок Содержание + Кнопка Экспорт + Перезагрузка FB2
          Row(
            children: [
              const Text("Содержание", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 14, color: Colors.blue),
                label: const Text("Скачать экспорт в", style: TextStyle(color: Colors.blue, fontSize: 12)),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh, size: 14, color: Colors.grey),
              label: const Text("перезагрузка текста из FB2", style: TextStyle(color: Colors.grey, fontSize: 11)),
            ),
          ),
          const SizedBox(height: 12),

          // 10. Проверка содержимого (Заглушка или Список добавленных частей)
          _chaptersList.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Text(
                      "Содержание отсутствует. Воспользуйтесь кнопкой \"Добавить часть\".",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _chaptersList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: const Color(0xFF1E1E1E),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.menu, color: Colors.grey),
                        title: Text(_chaptersList[index]['title'] ?? "", style: const TextStyle(color: Colors.white)),
                        subtitle: Text("Знаков: ${(_chaptersList[index]['text'] ?? '').length}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                          onPressed: () {
                            setState(() {
                              _chaptersList.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}