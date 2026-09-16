import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_tabs_management_page.dart'; 

class AddBookDetailsPage extends StatefulWidget {
  final String bookForm; 
  final File? initialFb2File; 

  const AddBookDetailsPage({
    super.key,
    required this.bookForm,
    this.initialFb2File,
  });

  @override
  State<AddBookDetailsPage> createState() => _AddBookDetailsPageState();
}

class _AddBookDetailsPageState extends State<AddBookDetailsPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _annotationController = TextEditingController();
  final TextEditingController _authorNotesController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  File? _coverImage;

  bool _isSearchingCoAuthor1 = false;
  bool _isSearchingCoAuthor2 = false;
  
  String? _selectedCoAuthor1;
  String? _selectedCoAuthor2;

  final TextEditingController _coAuthor1SearchController = TextEditingController();
  final TextEditingController _coAuthor2SearchController = TextEditingController();

  List<Map<String, dynamic>> _coAuthor1Results = [];
  List<Map<String, dynamic>> _coAuthor2Results = [];

  String _selectedGenre = "Выберите жанр";
  String _selectedSeries = "Без цикла";
  String _selectedSubGenre1 = "Не выбран";
  String _selectedSubGenre2 = "Не выбран";
  String _visibilityStatus = "Все";
  String _downloadStatus = "Никто";
  String _commentStatus = "Все";

  bool _isFragment = false;
  bool _isAdult = false;
  bool _hasDrugs = false;
  bool _isAiGenerated = false;

  bool _indentFirstLine = true;
  bool _enableTts = true;
  bool _antiCopy = true;
  bool _disableReviews = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialFb2File != null) {
      _parseAndPopulateFb2Data();
    }
  }

  void _parseAndPopulateFb2Data() {
    setState(() {
      _titleController.text = "Импортированное название книги";
      _annotationController.text = "Автоматически извлеченная аннотация из метаданных вашего файла FB2.";
      _tagsController.text = "фэнтези, попаданцы, боевик";
      _selectedGenre = "Фэнтези";
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Данные из FB2 успешно импортированы!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _pickCoverImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _coverImage = File(image.path);
      });
    }
  }

  Future<void> _searchAuthorsInFirestore(String query, int authorFieldNo) async {
    if (query.length < 3) {
      setState(() {
        if (authorFieldNo == 1) _coAuthor1Results = [];
        if (authorFieldNo == 2) _coAuthor2Results = [];
      });
      return;
    }

    String formattedQuery = query.trim();
    if (formattedQuery.isNotEmpty) {
      formattedQuery = formattedQuery[0].toUpperCase() + formattedQuery.substring(1);
    }

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users') 
          .where('name', isGreaterThanOrEqualTo: formattedQuery)
          .where('name', isLessThanOrEqualTo: '$formattedQuery\uf8ff')
          .limit(5)
          .get();

      setState(() {
        final List<Map<String, dynamic>> results = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'name': doc.get('name') as String,
                })
            .toList();

        if (authorFieldNo == 1) {
          _coAuthor1Results = results;
        } else {
          _coAuthor2Results = results;
        }
      });
    } catch (e) {
      print("Ошибка поиска в Firestore: $e");
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _annotationController.dispose();
    _authorNotesController.dispose();
    _tagsController.dispose();
    _coAuthor1SearchController.dispose();
    _coAuthor2SearchController.dispose();
    super.dispose();
  }

  Widget _buildDropdownField(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E1E1E),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(color: Colors.white, fontSize: 14)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxTile(String title, bool value, Color activeColor, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          activeColor: activeColor,
          checkColor: Colors.black,
          onChanged: onChanged,
        ),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildCoAuthorSearchSelector({
    required String label,
    required String? selectedValue,
    required bool isSearching,
    required TextEditingController controller,
    required List<Map<String, dynamic>> searchResults,
    required VoidCallback onBoxTap,
    required Function(String) onSearchChanged,
    required Function(String) onAuthorSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
            const SizedBox(width: 4),
            Icon(Icons.info_outline, size: 15, color: Colors.blue[400]),
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onBoxTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedValue ?? "Нет соавтора",
                  style: TextStyle(
                    color: selectedValue != null ? Colors.white : Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
                Icon(
                  isSearching ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        if (isSearching) ...[
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  onChanged: onSearchChanged,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF121212),
                    hintText: "Введите имя автора...",
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[800]!),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (controller.text.length < 3)
                  const Text(
                    "Пожалуйста, введите еще хотя бы 3 символа",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  )
                else if (searchResults.isEmpty)
                  const Text(
                    "Ничего не найдено в базе данных",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final author = searchResults[index];
                      return ListTile(
                        title: Text(author['name'], style: const TextStyle(color: Colors.white, fontSize: 14)),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        onTap: () => onAuthorSelected(author['name']),
                      );
                    },
                  ),
              ],
            ),
          ),
        ]
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Добавление произведения", style: TextStyle(fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
                  children: [
                    TextSpan(
                      text: "Вы выбрали форму «${widget.bookForm}». ",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: "Если вы ошиблись в выборе, "),
                    TextSpan(
                      text: "вернитесь назад.\n\n",
                      style: TextStyle(color: Colors.blue[300]),
                    ),
                    const TextSpan(
                      text: "Шаг № 2. ",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: "Пожалуйста, укажите название, жанр, аннотацию и прочие настройки произведения.\nЗатем нажмите кнопку «Продолжить», чтобы перейти к загрузке содержания."),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Center(
              child: Column(
                children: [
                  Container(
                    width: 130,
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFF262626),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey[800]!),
                      image: _coverImage != null
                          ? DecorationImage(
                              image: FileImage(_coverImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _coverImage == null
                        ? const Center(
                            child: Text(
                              "Обложка",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _pickCoverImage,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Text(_coverImage == null ? "Добавить обложку" : "Изменить обложку"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text("Название", style: TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              maxLength: 150,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFF1E1E1E),
                border: OutlineInputBorder(),
                hintText: "Название",
              ),
            ),
            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildCoAuthorSearchSelector(
                    label: "Соавтор",
                    selectedValue: _selectedCoAuthor1,
                    isSearching: _isSearchingCoAuthor1,
                    controller: _coAuthor1SearchController,
                    searchResults: _coAuthor1Results,
                    onBoxTap: () => setState(() => _isSearchingCoAuthor1 = !_isSearchingCoAuthor1),
                    onSearchChanged: (v) => _searchAuthorsInFirestore(v, 1),
                    onAuthorSelected: (name) {
                      setState(() {
                        _selectedCoAuthor1 = name;
                        _isSearchingCoAuthor1 = false;
                        _coAuthor1SearchController.clear();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCoAuthorSearchSelector(
                    label: "Второй соавтор",
                    selectedValue: _selectedCoAuthor2,
                    isSearching: _isSearchingCoAuthor2,
                    controller: _coAuthor2SearchController,
                    searchResults: _coAuthor2Results,
                    onBoxTap: () => setState(() => _isSearchingCoAuthor2 = !_isSearchingCoAuthor2),
                    onSearchChanged: (v) => _searchAuthorsInFirestore(v, 2),
                    onAuthorSelected: (name) {
                      setState(() {
                        _selectedCoAuthor2 = name;
                        _isSearchingCoAuthor2 = false;
                        _coAuthor2SearchController.clear();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildDropdownField("Жанр", _selectedGenre, ["Выберите жанр", "Фэнтези", "Роман", "Фантастика"], (v) => setState(() => _selectedGenre = v!))),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdownField("Цикл", _selectedSeries, ["Без цикла", "Цикл Император"], (v) => setState(() => _selectedSeries = v!))),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildDropdownField("Доп. жанр #1 (не обязательно)", _selectedSubGenre1, ["Не выбран", "Детектив", "Ужасы"], (v) => setState(() => _selectedSubGenre1 = v!))),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdownField("Доп. жанр #2 (не обязательно)", _selectedSubGenre2, ["Не выбран", "ЛитРПГ", "Киберпанк"], (v) => setState(() => _selectedSubGenre2 = v!))),
              ],
            ),
            const SizedBox(height: 16),

            const Text("Аннотация", style: TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _annotationController,
              maxLength: 1000,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFF1E1E1E),
                border: OutlineInputBorder(),
                hintText: "Пожалуйста, напишите, о чем ваше произведение...",
              ),
            ),
            const SizedBox(height: 12),

            const Text("Примечания автора (не обязательно)", style: TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _authorNotesController,
              maxLength: 1000,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFF1E1E1E),
                border: OutlineInputBorder(),
                hintText: "Ваш комментарий по поводу этой работы...",
              ),
            ),
            const SizedBox(height: 12),

            const Text("Тэги", style: TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _tagsController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFF1E1E1E),
                border: OutlineInputBorder(),
                hintText: "До 12 тэгов через запятую, разрешены пробелы",
              ),
            ),
            const SizedBox(height: 20),

            _buildCheckboxTile("Ознакомительный фрагмент", _isFragment, Colors.orange, (v) => setState(() => _isFragment = v!)),
            _buildCheckboxTile("Для взрослых (18+)", _isAdult, Colors.orange, (v) => setState(() => _isAdult = v!)),
            _buildCheckboxTile("Упоминание наркотических, психотропных средств...", _hasDrugs, Colors.orange, (v) => setState(() => _hasDrugs = v!)),
            _buildCheckboxTile("Создано с помощью нейросети", _isAiGenerated, Colors.orange, (v) => setState(() => _isAiGenerated = v!)),
            const SizedBox(height: 16),

            _buildCheckboxTile("Отображать все абзацы с красной строки", _indentFirstLine, Colors.blueAccent, (v) => setState(() => _indentFirstLine = v!)),
            _buildCheckboxTile("Включить озвучивание текста (TTS)", _enableTts, Colors.blueAccent, (v) => setState(() => _enableTts = v!)),
            _buildCheckboxTile("Защита текста от копирования", _antiCopy, Colors.blueAccent, (v) => setState(() => _antiCopy = v!)),
            _buildCheckboxTile("Отключить добавление рецензий", _disableReviews, Colors.blueAccent, (v) => setState(() => _disableReviews = v!)),
            const SizedBox(height: 20),

            _buildDropdownField("Кто может видеть произведение", _visibilityStatus, ["Все", "Друзья", "Только я"], (v) => setState(() => _visibilityStatus = v!)),
            const SizedBox(height: 16),
            _buildDropdownField("Кто может скачивать произведение", _downloadStatus, ["Никто", "Все", "Подписчики"], (v) => setState(() => _downloadStatus = v!)),
            const SizedBox(height: 16),
            _buildDropdownField("Кто может комментировать произведение", _commentStatus, ["Все", "Никто"], (v) => setState(() => _commentStatus = v!)),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                final Map<String, dynamic> collectedBookData = {
                  'title': _titleController.text,
                  'annotation': _annotationController.text,
                  'authorNotes': _authorNotesController.text,
                  'tags': _tagsController.text,
                  'genre': _selectedGenre,
                  'series': _selectedSeries,
                  'subGenre1': _selectedSubGenre1,
                  'subGenre2': _selectedSubGenre2,
                  'coAuthor1': _selectedCoAuthor1,
                  'coAuthor2': _selectedCoAuthor2,
                  'isFragment': _isFragment,
                  'isAdult': _isAdult,
                  'hasDrugs': _hasDrugs,
                  'isAiGenerated': _isAiGenerated,
                  'indentFirstLine': _indentFirstLine,
                  'enableTts': _enableTts,
                  'antiCopy': _antiCopy,
                  'disableReviews': _disableReviews,
                  'visibilityStatus': _visibilityStatus,
                  'downloadStatus': _downloadStatus,
                  'commentStatus': _commentStatus,
                  'form': widget.bookForm,
                };

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookTabsManagementPage(
                      bookData: collectedBookData,
                      coverImage: _coverImage,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A76A8),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text("Продолжить", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}