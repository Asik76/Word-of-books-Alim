import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/import_book_page.dart';
import 'package:flutter_application_1/screens/add_book_details_page.dart';

class AddBookFormSelectPage extends StatefulWidget {
  const AddBookFormSelectPage({super.key});

  @override
  State<AddBookFormSelectPage> createState() => _AddBookFormSelectPageState();
}

class _AddBookFormSelectPageState extends State<AddBookFormSelectPage> {
  // Переменная для хранения выбранной формы
  String? _selectedForm;

  // Данные для карточек
  final List<Map<String, String>> _forms = [
    {
      "title": "Рассказ",
      "desc": "Малая форма произведения. Состоит из одной части.",
    },
    {
      "title": "Повесть",
      "desc": "Средняя форма произведения. Состоит из одной части.",
    },
    {
      "title": "Роман",
      "desc": "Большая форма произведения. Состоит из нескольких частей.",
    },
    {
      "title": "Сборник рассказов",
      "desc": "Состоит из нескольких рассказов. Пожалуйста, придерживайтесь правила: одна часть — один рассказ.",
    },
    {
      "title": "Сборник поэзии",
      "desc": "Состоит из нескольких стихотворений или других произведений в жанре поэзия.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Выбор формы произведения", style: TextStyle(fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ИНСТРУКЦИЯ ---
              _buildInstructionBox(),
              
              const SizedBox(height: 24),

              GridView.builder(
                shrinkWrap: true, // Критически важно внутри SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(), // Отключаем внутреннюю прокрутку сетки
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: _forms.length,
                itemBuilder: (context, index) {
                  final form = _forms[index];
                  final isSelected = _selectedForm == form['title'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedForm = form['title'];
                      });
                    },
                    child: _buildFormCard(form['title']!, form['desc']!, isSelected),
                  );
                },
              ),
              const SizedBox(height: 100), // Отступ под кнопки
            ],
          ),
        ),
      ),
      // --- НИЖНЯЯ ПАНЕЛЬ С КНОПКАМИ ---
      bottomSheet: _buildBottomButtons(),
    );
  }

  Widget _buildInstructionBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
          children: [
            const TextSpan(
                text: "Шаг № 1. ",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const TextSpan(
                text: "Выберите форму произведения и нажмите «Продолжить», или загрузите произведения в формате "),
            TextSpan(
                text: "FB2",
                style: TextStyle(color: Colors.blue[300], fontWeight: FontWeight.bold)),
            const TextSpan(text: " (Рекомендуется публиковать в виде сборника рассказы, объединенные одним циклом.)."),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(String title, String desc, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.green : Colors.grey[800]!,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
          if (isSelected)
            const Positioned(
              top: 0,
              right: 0,
              child: Icon(Icons.check_circle, color: Colors.green, size: 24),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Кнопка Продолжить
          Expanded(
            flex: 2,
            child: ElevatedButton(
              // Кнопка заблокирована (null), если форма произведения не выбрана
              onPressed: _selectedForm == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddBookDetailsPage(
                            bookForm: _selectedForm!, 
                            initialFb2File: null,     
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A76A8),
                disabledBackgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text("Продолжить", style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(width: 12),
          // Кнопка Загрузить FB2
          Expanded(
            flex: 2,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ImportBookPage()),
                );
              },
              icon: const Icon(Icons.file_upload_outlined, size: 18),
              label: const Text("Загрузить FB2"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.teal),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}