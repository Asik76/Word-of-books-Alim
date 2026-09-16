import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_application_1/screens/add_book_details_page.dart';

class ImportBookPage extends StatefulWidget {
  const ImportBookPage({super.key});

  @override
  State<ImportBookPage> createState() => _ImportBookPageState();
}

class _ImportBookPageState extends State<ImportBookPage> {
  // Переменная для хранения текста ошибки валидации форматов
  String? _errorMessage;

  Future<void> _pickFile(BuildContext context) async {
    // Сброс прошлую ошибку перед новым выбором файла
    setState(() {
      _errorMessage = null;
    });

    // Запуск системный выборщик файлов
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      // Указываю разрешенные расширения на уровне операционной системы
      allowedExtensions: ['fb2', 'zip'],
    );

    if (result != null) {
      PlatformFile pickedFile = result.files.single;
      String fileExtension = pickedFile.extension?.toLowerCase() ?? '';

      // Строгая проверка расширения внутри приложения
      if (fileExtension == 'fb2' || fileExtension == 'zip') {
        File fileObject = File(pickedFile.path!);

        // Показываю уведомление об успешном выборе
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Файл успешно выбран: ${pickedFile.name}'),
            backgroundColor: Colors.green,
          ),
        );

        // Открываю экран метаданных (AddBookDetailsPage),
        // передаю форму книги (например, Роман) и сам файл для автозаполнения
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddBookDetailsPage(
                bookForm: 'Роман',
                initialFb2File: fileObject, // Этот файл запустит автозаполнение полей
              ),
            ),
          );
        }
      } else {
        // Если пользователь выбрал файл другого формата (например, .pdf или .txt)
        setState(() {
          _errorMessage = 'Ошибка: Выбран неверный формат файла (.$fileExtension). Допускаются только файлы с расширением .fb2 и .zip';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Импорт произведения'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'В данный момент поддерживается импорт из файлов с расширением .fb2 и .zip.',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              'Важно! В zip-архиве должен быть всего один файл с расширением .fb2',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Загружая текст произведения, я подтверждаю, что у меня есть необходимые для его обработки права.',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 30),
            
            // Зона выбора файла
            GestureDetector(
              onTap: () => _pickFile(context),
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      color: const Color(0xFF00838F), // Теал-цвет кнопки из ТЗ
                      child: const Text(
                        'Выберите файл',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --- Блок вывода ошибки красного цвета ---
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.redAccent, // Красный цвет текста ошибки
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}