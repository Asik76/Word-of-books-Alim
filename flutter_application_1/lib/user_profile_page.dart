import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'users_relationship_page.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();

  bool _isPickerActive = false;
  bool _isUploading = false;
  String? _localAvatarPath;
  String? _localBackgroundPath;

  Future<void> _pickImage(bool isBackground) async {
    if (_isPickerActive) return; 

    setState(() => _isPickerActive = true);

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (image == null) {
        setState(() => _isPickerActive = false);
        return;
      }

      setState(() {
        _isUploading = true;
        if (isBackground)
          _localBackgroundPath = image.path;
        else
          _localAvatarPath = image.path;
      });

      // 1. Путь в Storage
      String folder = isBackground ? "backgrounds" : "avatars";
      String fileName = "${currentUser!.uid}.jpg";
      Reference ref = FirebaseStorage.instance
          .ref()
          .child(folder)
          .child(fileName);

      // 2. Загрузка файла
      UploadTask uploadTask = ref.putFile(File(image.path));
      TaskSnapshot snapshot = await uploadTask;

      // 3. Получаеть ссылку
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // 4. Записываю в Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({isBackground ? 'backgroundUrl' : 'photoUrl': downloadUrl});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Фото сохранено в облаке!")),
        );
      }
    } catch (e) {
      print("Ошибка: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _isPickerActive = false;
          // Очищаю локальные пути, теперь всё берется из базы по ссылке
          _localAvatarPath = null;
          _localBackgroundPath = null;
        });
      }
    }
  }

  Widget _buildTopSection(Map<String, dynamic>? userData) {
    String? firestoreAvatar = userData?['photoUrl'];
    String? firestoreBackground = userData?['backgroundUrl'];

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // ФОН
        GestureDetector(
          onTap: () => _pickImage(true),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: (_isUploading && _localBackgroundPath != null)
                    ? FileImage(File(_localBackgroundPath!)) as ImageProvider
                    : (firestoreBackground != null &&
                                  firestoreBackground.isNotEmpty
                              ? NetworkImage(firestoreBackground)
                              : const NetworkImage(
                                  "https://img.freepik.com/free-vector/blue-background-with-geometric-shapes_23-2148255271.jpg",
                                ))
                          as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        // АВАТАР
        Positioned(
          bottom: -50,
          child: GestureDetector(
            onTap: () => _pickImage(false),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF121212),
              child: CircleAvatar(
                radius: 55,
                backgroundImage: (_isUploading && _localAvatarPath != null)
                    ? FileImage(File(_localAvatarPath!)) as ImageProvider
                    : (firestoreAvatar != null && firestoreAvatar.isNotEmpty
                              ? NetworkImage(firestoreAvatar)
                              : const NetworkImage(
                                  "https://www.w3schools.com/howto/img_avatar.png",
                                ))
                          as ImageProvider,
              ),
            ),
          ),
        ),

        if (_isUploading)
          const Positioned(
            top: 80,
            child: CircularProgressIndicator(color: Colors.white),
          ),
      ],
    );
  }

  // --- Вкладка "Мой профиль" ---
  Widget _buildProfileInfoTab(String bio, String regDate, String birthDate) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Основная информация",
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildInfoBlock([
            _buildInfoRow(Icons.calendar_today, "Регистрация", regDate),
            _buildInfoRow(Icons.cake, "Дата рождения", birthDate),
          ]),
          const SizedBox(height: 25),
          const Text(
            "О себе",
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildInfoBlock([
            Text(
              bio,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ]),
          const SizedBox(height: 25),
          _buildActionTile(
            Icons.settings,
            "Настройки профиля",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    backgroundColor: const Color(0xFF121212),
                    appBar: AppBar(
                      title: const Text("Настройки"),
                      backgroundColor: const Color(0xFF1E1E1E),
                    ),
                    body: _buildSettingsTab(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        _buildActionTile(Icons.edit, "Редактировать профиль"),
        _buildActionTile(Icons.notifications, "Уведомления"),
        _buildActionTile(Icons.lock, "Приватность"),
        _buildActionTile(Icons.logout, "Выйти из аккаунта", isLast: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: 1,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            var userData = snapshot.data?.data() as Map<String, dynamic>?;
            String name = userData?['name'] ?? "Name";
            String userNick =
                userData?['nickname'] ??
                "id_${currentUser?.uid.substring(0, 5)}";
            String bio = userData?['bio'] ?? "Студент 4 курса КПО-9-22-2.";
            String regDate = userData?['registrationDate'] ?? "29 октября 2025";
            String birthDate = userData?['birthDate'] ?? "Не указана";

            return Column(
              children: [
                _buildTopSection(userData),
                const SizedBox(height: 60),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // ЗАМЕНЯЮ СТАТИКУ НА ПЕРЕМЕННУЮ
                Text(
                  "@$userNick",
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),

                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.circle, color: Colors.green, size: 10),
                    SizedBox(width: 5),
                    Text("Онлайн", style: TextStyle(color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const UsersRelationshipPage(initialIndex: 0),
                        ),
                      ),
                      child: _buildCounter("Подписки", "176"),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const UsersRelationshipPage(initialIndex: 1),
                        ),
                      ),
                      child: _buildCounter("Подписчики", "119"),
                    ),
                    _buildCounter("Лайки", "1.2k"),
                  ],
                ),
                const Divider(color: Colors.white10),
                const TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: Colors.blueAccent,
                  labelColor: Colors.blueAccent,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(text: "Лента новостей"),
                    Tab(text: "Мой профиль"),
                    Tab(text: "Книги"),
                    Tab(text: "Достижения"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      const Center(
                        child: Text(
                          "Лента",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      _buildProfileInfoTab(bio, regDate, birthDate),
                      _buildBooksNestedTab(),
                      const Center(
                        child: Text(
                          "Достижения",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Вспомогательные методы
  Widget _buildBooksNestedTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.white,
            tabs: [
              Tab(text: "Сохраненные книги"),
              Tab(text: "Опубликованные книги"),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                Center(
                  child: Text(
                    "Список ваших книг",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                Center(
                  child: Text(
                    "Ваши публикации",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBlock(List<Widget> children) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
  Widget _buildInfoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Icon(icon, size: 16, color: Colors.blueAccent),
        const SizedBox(width: 10),
        Text("$label: ", style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(color: Colors.white)),
      ],
    ),
  );
  Widget _buildCounter(String label, String count) => Column(
    children: [
      Text(
        count,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ],
  );
  Widget _buildActionTile(
    IconData icon,
    String title, {
    VoidCallback? onTap,
    bool isLast = false,
  }) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: isLast ? Colors.redAccent : Colors.blueAccent),
    title: Text(
      title,
      style: TextStyle(color: isLast ? Colors.redAccent : Colors.white),
    ),
    trailing: const Icon(
      Icons.arrow_forward_ios,
      color: Colors.white24,
      size: 16,
    ),
    onTap: onTap,
  );
}
