import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Импорт ядра Firebase
import 'package:flutter_application_1/auth_screens.dart';
import 'firebase_options.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'alim_chat_page.dart';
import 'user_profile_page.dart';
import 'package:flutter_application_1/screens/book_list_page.dart';
import 'package:flutter_application_1/screens/add_book_form_select_page.dart';

void main() async {
  // Обязательный эти строки для инициализации
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const WorldOfBooksApp());
}

class WorldOfBooksApp extends StatelessWidget {
  const WorldOfBooksApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'World of Books Alim',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 0,
        ),
      ),
      home: const AuthWrapper(), // Сначала показывается экран Входа
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Если проверка еще идет
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Если пользователь вошел в систему
        if (snapshot.hasData) {
          User? user = snapshot.data;

          // ПРОВЕРКА ПОДТВЕРЖДЕНИЯ ПОЧТЫ
          if (user != null && user.emailVerified) {
            return const MainScreen(); // Почта подтверждена — входим
          } else {
            // Почта НЕ подтверждена
            return const WelcomeScreen(); // Или создай экран "VerifyEmailScreen"
          }
        }

        // Если пользователь не вошел — показывает экран Входа/Регистрации
        return const WelcomeScreen();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 2; // Алим по умолчанию
  void goToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Список страниц для нижней навигации
  late final List<Widget> _pages = [
    const BookListPage(), // Индекс 0
    const Center(child: Text("Общий чат")), // Индекс 1
    AlimScreen(
      onNavigate: (index) {
        // Индекс 2
        setState(() {
          _currentIndex = index;
        });
      },
    ),
    const Center(child: Text("Рейтинг")), // Индекс 3
    const UserProfilePage(), // Индекс 4
  ];

  // Виджет для элементов левого меню
  Widget _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[400], size: 22),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
      dense: true,
      visualDensity: const VisualDensity(vertical: -2),
      onTap: () => Navigator.pop(context),
    );
  }

  // Виджет для элементов правого меню
  Widget _buildProfileItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[400], size: 22),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
      dense: true,
      onTap: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- ЛЕВАЯ ШТОРКА (ГЛАВНОЕ МЕНЮ) ---
      drawer: Drawer(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9, // Стандартный размер для шапки меню
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: Color(0xFF1F1F1F)),
                child: Stack(
                  children: [
                    // Сама картинка логотипа
                    Center(
                      child: Image.asset(
                        'assets/images/alim_icon.png',
                        height: 150, 
                        fit: BoxFit.contain, 
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.menu_book,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Градиент и текст снизу
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ExpansionTile(
                    leading: const Icon(Icons.book, color: Colors.blueAccent),
                    title: const Text("Книги", style: TextStyle(fontSize: 14)),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    childrenPadding: const EdgeInsets.only(left: 10),
                    children: [
                      _buildDrawerItem(Icons.trending_up, "Популярное"),
                      _buildDrawerItem(Icons.fiber_new_outlined, "Новинки"),
                      _buildDrawerItem(Icons.percent, "Скидки"),
                      _buildDrawerItem(Icons.star_outline, "Рекомендуемые"),
                      _buildDrawerItem(
                        Icons.collections_bookmark_outlined,
                        "Подборки",
                      ),
                      _buildDrawerItem(
                        Icons.auto_awesome_motion,
                        "Подборки AT",
                      ),
                      _buildDrawerItem(Icons.grid_view, "Полный список жанров"),
                      _buildDrawerItem(
                        Icons.manage_search,
                        "Расширенный поиск",
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildDrawerItem(Icons.headset_outlined, "Аудиокниги"),
                  const Divider(),
                  ExpansionTile(
                    leading: const Icon(
                      Icons.people_outline,
                      color: Colors.blueAccent,
                    ),
                    title: const Text(
                      "Сообщество",
                      style: TextStyle(fontSize: 14),
                    ),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    childrenPadding: const EdgeInsets.only(left: 10),
                    children: [
                      _buildDrawerItem(
                        Icons.leaderboard_outlined,
                        "Топ авторов",
                      ),
                      _buildDrawerItem(
                        Icons.person_search_outlined,
                        "Топ пользователей",
                      ),
                      _buildDrawerItem(Icons.palette_outlined, "Иллюстрации"),
                    ],
                  ),
                  const Divider(),
                  _buildDrawerItem(Icons.emoji_events_outlined, "Конкурсы"),
                  const Divider(),
                  _buildDrawerItem(Icons.flash_on_outlined, "Литмобы"),
                  const Divider(),
                  _buildDrawerItem(Icons.article_outlined, "Новости"),
                  _buildDrawerItem(Icons.gavel_outlined, "Правила"),
                  _buildDrawerItem(
                    Icons.lightbulb_outline,
                    "Идеи и предложения",
                  ),
                  _buildDrawerItem(
                    Icons.help_center_outlined,
                    "Справочный центр",
                  ),
                  const Divider(),
                  _buildDrawerItem(Icons.settings_outlined, "Общие настройки"),
                  _buildDrawerItem(
                    Icons.support_agent_outlined,
                    "Служба поддержки",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // --- ПРАВАЯ ШТОРКА (ПРОФИЛЬ) ---
      endDrawer: Drawer(
        child: Container(
          color: const Color(0xFF1F1F1F),
          child: Column(
            children: [
              // --- ШАПКА ШТОРКИ (StreamBuilder) ---
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  String userName = "Загрузка...";
                  String userNick = FirebaseAuth.instance.currentUser?.uid.substring(0, 5) ?? "user";
                  String? photoUrl;
                  String? backgroundUrl;

                  if (snapshot.hasData && snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    userName = data['name'] ?? "Без имени";
                    userNick = data['nickname'] ?? data['username'] ?? userNick;
                    
                    String cacheBuster = DateTime.now().millisecondsSinceEpoch.toString();
                    if (data['photoUrl'] != null) {
                      photoUrl = data['photoUrl'].toString().contains('?') 
                          ? "${data['photoUrl']}&t=$cacheBuster" 
                          : "${data['photoUrl']}?t=$cacheBuster";
                    }
                    if (data['backgroundUrl'] != null) {
                      backgroundUrl = data['backgroundUrl'].toString().contains('?') 
                          ? "${data['backgroundUrl']}&t=$cacheBuster" 
                          : "${data['backgroundUrl']}?t=$cacheBuster";
                    }
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 4);
                    },
                    child: Stack(
                      children: [
                        Container(
                          height: 170,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: (backgroundUrl != null)
                                  ? NetworkImage(backgroundUrl)
                                  : const NetworkImage('https://img.freepik.com/free-vector/blue-geometric-background_23-2148403321.jpg') as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          bottom: 15,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundColor: const Color(0xFF121212),
                                child: CircleAvatar(
                                  radius: 33,
                                  backgroundColor: Colors.white,
                                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                                  child: photoUrl == null ? const Icon(Icons.person, size: 35, color: Colors.blueAccent) : null,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                  Text("@$userNick", style: TextStyle(fontSize: 13, color: Colors.blueAccent[100])),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // --- СПИСОК МЕНЮ ---
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildProfileItem(Icons.book_outlined, "Моя библиотека"),
                    _buildProfileItem(Icons.security, "Приватность"),
                    _buildProfileItem(Icons.volume_off_outlined, "Игнор-лист"),
                    _buildProfileItem(Icons.account_balance_wallet_outlined, "Кошелек"),
                    
                    ExpansionTile(
                      iconColor: Colors.blueAccent,
                      leading: const Icon(Icons.add, color: Colors.grey),
                      title: const Text("Добавить", style: TextStyle(fontSize: 14, color: Colors.white)),
                      children: [
                        ListTile(
                          leading: const Icon(Icons.menu_book, size: 22),
                          title: const Text("Произведение", style: TextStyle(fontSize: 14)),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddBookFormSelectPage()));
                          },
                        ),
                        _buildProfileItem(Icons.edit_note, "Запись в блоге"),
                        _buildProfileItem(Icons.image_outlined, "Иллюстрацию"),
                      ],
                    ),
                    
                    _buildProfileItem(Icons.collections_bookmark_outlined, "Мои подборки"),
                    
                    ListTile(
                      leading: const Icon(Icons.account_circle_outlined, color: Colors.grey),
                      title: const Text("Мой профиль", style: TextStyle(color: Colors.white, fontSize: 14)),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _currentIndex = 4);
                      },
                    ),
                    const Divider(color: Colors.grey),
                    ListTile(
                      leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                      title: const Text("Выйти", style: TextStyle(color: Colors.redAccent, fontSize: 14)),
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "World of Books Alim",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () =>
                showSearch(context: context, delegate: GenreSearchDelegate()),
          ),
          IconButton(
            icon: const Icon(Icons.mail_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatListScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            ),
          ),
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openEndDrawer(),
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    String? photoUrl;
                    if (snapshot.hasData && snapshot.data!.exists) {
                      var data = snapshot.data!.data() as Map<String, dynamic>?;
                      if (data != null && data['photoUrl'] != null) {
                        String originalUrl = data['photoUrl'];
                        String cb = DateTime.now().millisecondsSinceEpoch
                            .toString();
                        photoUrl = originalUrl.contains('?')
                            ? "$originalUrl&t=$cb"
                            : "$originalUrl?t=$cb";
                      }
                    }

                    return CircleAvatar(
                      radius: 14,
                      backgroundColor: photoUrl != null
                          ? const Color(0xFF1F1F1F)
                          : Colors.blueAccent,
                      backgroundImage: photoUrl != null
                          ? NetworkImage(photoUrl)
                          : null,
                      child: photoUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 18,
                              color: Colors.white,
                            )
                          : null,
                    );
                  }, // Конец builder StreamBuilder
                ), // Конец StreamBuilder
              ), // Конец Padding
            ), // Конец GestureDetector
          ), // Конец Builder
        ],
      ),

      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Книги'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Чат'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'Алим'),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Рейтинг',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}

// --- ЭКРАН ЛЕНТА НОВОСТЕЙ ---
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  void _showModeChangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text("Смена режима просмотра"),
        content: const Text(
          "Теперь вы будете видеть только непрочитанные уведомления.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ОТМЕНА"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ОК"),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(IconData icon, String title) {
    return PopupMenuItem(
      value: title,
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Лента новостей", style: TextStyle(fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () => _showModeChangeDialog(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune),
            color: const Color(0xFF2D2D2D),
            itemBuilder: (context) => [
              _buildMenuItem(Icons.rss_feed, "Все новости"),
              _buildMenuItem(Icons.info_outline, "Уведомления"),
              _buildMenuItem(Icons.book_outlined, "Произведения"),
              _buildMenuItem(Icons.done_all, "Завершенные произведения"),
              _buildMenuItem(Icons.percent, "Скидки"),
              _buildMenuItem(Icons.forum_outlined, "Обсуждения"),
              _buildMenuItem(Icons.collections_bookmark_outlined, "Подборки"),
              _buildMenuItem(Icons.image_outlined, "Иллюстрации"),
              _buildMenuItem(Icons.people_outline, "Подписчики"),
              _buildMenuItem(
                Icons.chat_bubble_outline,
                "Ответы на мои комментарии",
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: const Center(
        child: Text(
          "Отличная работа, все прочитано!",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

// --- ЭКРАН РЕДАКТИРОВАНИЯ ПРОФИЛЯ ---
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Редактировать профиль")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.camera_alt, size: 30),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: "Имя",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(
                labelText: "О себе",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "СОХРАНИТЬ",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- СПИСОК ЧАТОВ ---
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Список диалогов")),
      body: const Center(child: Text("Диалогов пока нет")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: const Color(0xFF1F1F1F),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "Поиск людей",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.blueAccent,
                      ),
                      hintText: "Поиск по имени или псевдониму",
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}

// --- ПОИСК ---
class GenreSearchDelegate extends SearchDelegate {
  final List<String> genres = [
    "Боевик",
    "Фэнтези",
    "ЛитРПГ",
    "Попаданцы",
    "Детектив",
    "Ужасы",
  ];
  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];
  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );
  @override
  Widget buildResults(BuildContext context) =>
      Center(child: Text("Поиск: $query"));
  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView.builder(
      itemCount: genres.length,
      itemBuilder: (context, index) => CheckboxListTile(
        title: Text(genres[index]),
        value: false,
        onChanged: (val) {},
      ),
    );
  }
}
