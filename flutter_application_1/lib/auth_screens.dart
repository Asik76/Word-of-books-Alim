import 'package:country_picker/country_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

// --- СТРАНИЦА: ПОЛИТИКА КОНФИДЕНЦИАЛЬНОСТИ ---
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Политика конфиденциальности"),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: const Text(
          "Политика конфиденциальности и обработки персональных данных\n\n"
          "1. Общие положения\nНастоящая Политика действует в отношении всей информации, которую владелец World of Books Alim может получить о Пользователе...",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ),
    );
  }
}

// --- СТРАНИЦА: ПОЛЬЗОВАТЕЛЬСКОЕ СОГЛАШЕНИЕ ---
class UserAgreementPage extends StatelessWidget {
  const UserAgreementPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Пользовательское соглашение"),
        backgroundColor: Colors.transparent,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text(
          "Настоящее Пользовательское соглашение регулирует отношения между Администрацией World of Books Alim и Пользователем...",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ),
    );
  }
}

// --- 1. ГЛАВНЫЙ ЭКРАН (WELCOME) ---
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Image.asset(
              'assets/images/alim.png',
              height: 200,
              errorBuilder: (c, e, s) => const Icon(
                Icons.menu_book_rounded,
                size: 100,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  _buildWelcomeButton(
                    context,
                    "ВХОД",
                    Colors.white,
                    Colors.blue,
                    const LoginScreen(),
                  ),
                  const SizedBox(height: 15),
                  _buildWelcomeButton(
                    context,
                    "РЕГИСТРАЦИЯ",
                    Colors.white,
                    Colors.blue,
                    const RegisterScreen(),
                  ),
                  const SizedBox(height: 30),
                  _divider(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialIcon(Icons.g_mobiledata),
                      const SizedBox(width: 20),
                      _socialIcon(Icons.apple),
                      const SizedBox(width: 20),
                      _socialIcon(Icons.facebook),
                    ],
                  ),
                  const SizedBox(height: 30),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                      children: [
                        const TextSpan(text: "Регистрируясь, Вы принимаете "),
                        TextSpan(
                          text: "пользовательское соглашение",
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => const UserAgreementPage(),
                              ),
                            ),
                        ),
                        const TextSpan(text: " и "),
                        TextSpan(
                          text: "политику конфиденциальности",
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => const PrivacyPolicyPage(),
                              ),
                            ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeButton(
    BuildContext context,
    String text,
    Color bg,
    Color textColor,
    Widget screen,
  ) {
    return ElevatedButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _divider() => Row(
    children: [
      Expanded(child: Divider(color: Colors.grey[700])),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Text("или", style: TextStyle(color: Colors.grey, fontSize: 12)),
      ),
      Expanded(child: Divider(color: Colors.grey[700])),
    ],
  );

  Widget _socialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.blue[800], size: 28),
    );
  }
}

// --- 2. ЭКРАН ВХОДА ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signIn() async {
    String input = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String emailToSignIn = input;

    // Если поле пустое, ничего не делаем
    if (input.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Заполните все поля")));
      return;
    }

    try {
      // 1. Логика входа по никнейму
      if (!input.contains('@')) {
        var userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('nickname', isEqualTo: input)
            .limit(1)
            .get();

        if (userQuery.docs.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Никнейм не найден")));
          return;
        }
        emailToSignIn = userQuery.docs.first.get('email');
      }

      // 2. Вход в Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailToSignIn,
        password: password,
      );

      if (!mounted) return; // Проверка, что экран еще существует

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
        (route) =>
            false, 
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Успешный вход!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Неверный логин или пароль")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/alim.png',
                height: 200,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.menu_book, color: Colors.white, size: 70),
              ),
              const SizedBox(height: 20),
              _input(_emailController, "Email", Icons.person_outline),
              const SizedBox(height: 15),
              _input(
                _passwordController,
                "Пароль",
                Icons.lock_outline,
                isPass: true,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  ),
                  child: const Text(
                    "Забыли пароль?",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B4B5A),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "ВХОД",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController c,
    String h,
    IconData i, {
    bool isPass = false,
  }) {
    return TextField(
      controller: c,
      obscureText: isPass,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: h,
        prefixIcon: Icon(i, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF334455)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// --- 3. ЭКРАН РЕГИСТРАЦИИ ---
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _countryController = TextEditingController();
  final _dobController = TextEditingController();
  String? _selectedGender;

  bool _isPrivacyAgreed = false;
  bool _isTermsAgreed = false;

  Future<void> _register() async {
    // 1. Проверка паролей
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Пароли не совпадают!")));
      return;
    }

    try {
      // 2. Создание пользователя в Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // 3. Отправка письма для подтверждения 
      User? user = userCredential.user;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }

      // 4. Сохранение данных в Firestore
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'name': _nameController.text.trim(),
        'nickname': _nicknameController.text.trim(),
        'country': _countryController.text.trim(),
        'email': _emailController.text.trim(),
        'dob': _dobController.text,
        'gender': _selectedGender,
        'createdAt': DateTime.now(), // Полезно добавить дату регистрации
      });

      // 5. Сообщаем об успешной регистрации
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Регистрация успешна! Проверьте почту для подтверждения.",
          ),
        ),
      );

      Navigator.pop(context); // Возвращаеть на экран входа
    } catch (e) {
      // Обработка ошибок (например, если email уже занят)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Ошибка: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool canRegister = _isPrivacyAgreed && _isTermsAgreed;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Регистрация"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.asset(
              'assets/images/alim.png',
              height: 200,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.person_add, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 20),
            _regField(_nameController, "Имя", Icons.person_outline),
            _regField(_nicknameController, "Никнейм", Icons.alternate_email),
            _regField(
              _dobController,
              "Дата рождения",
              Icons.calendar_today,
              readOnly: true,
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2005),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (picked != null)
                  setState(
                    () => _dobController.text =
                        "${picked.day}.${picked.month}.${picked.year}",
                  );
              },
            ),

            // ВСПЛЫВАЮЩИЙ ВЫБОР СТРАНЫ
            _regField(
              _countryController,
              "Страна",
              Icons.public,
              readOnly: true,
              onTap: () => showCountryPicker(
                context: context,
                onSelect: (c) => setState(
                  () => _countryController.text = "${c.flagEmoji} ${c.name}",
                ),
                countryListTheme: CountryListThemeData(
                  backgroundColor: const Color(0xFF1E1E1E),
                  textStyle: const TextStyle(color: Colors.white),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  inputDecoration: InputDecoration(
                    labelText: 'Поиск страны',
                    prefixIcon: const Icon(Icons.search, color: Colors.blue),
                    filled: true,
                    fillColor: const Color(0xFF121212),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),

            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF1E1E1E),
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Пол", Icons.wc),
              items: [
                'Мужской',
                'Женский',
                'Не указывать',
              ].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (v) => setState(() => _selectedGender = v),
            ),
            const SizedBox(height: 12),
            _regField(_emailController, "Email", Icons.mail_outline),
            _regField(
              _passwordController,
              "Пароль",
              Icons.lock_outline,
              isPass: true,
            ),
            _regField(
              _confirmPasswordController,
              "Подтвердите пароль",
              Icons.lock_reset,
              isPass: true,
            ),

            const SizedBox(height: 10),

            // ДВЕ ГАЛОЧКИ
            _checkboxRow(
              "Я согласен с политикой конфиденциальности",
              _isPrivacyAgreed,
              (v) => setState(() => _isPrivacyAgreed = v!),
              const PrivacyPolicyPage(),
            ),
            _checkboxRow(
              "Я принимаю пользовательское соглашение",
              _isTermsAgreed,
              (v) => setState(() => _isTermsAgreed = v!),
              const UserAgreementPage(),
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: canRegister ? _register : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canRegister
                    ? const Color(0xFF3B4B5A)
                    : Colors.grey[800],
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "ЗАРЕГИСТРИРОВАТЬСЯ",
                style: TextStyle(
                  color: canRegister ? Colors.white : Colors.white38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkboxRow(
    String label,
    bool val,
    Function(bool?) onChange,
    Widget page,
  ) {
    return Row(
      children: [
        Checkbox(value: val, onChanged: onChange, activeColor: Colors.blue),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                fontSize: 12,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => page),
                ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _regField(
    TextEditingController c,
    String h,
    IconData i, {
    bool isPass = false,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        obscureText: isPass,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(h, i),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.blueAccent),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF334455)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

// --- 4. ЭКРАН СБРОСА ПАРОЛЯ ---
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _resetController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/alim.png',
                height: 200,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.lock_reset, color: Colors.white, size: 70),
              ),
              const SizedBox(height: 20),
              const Text(
                "Сброс пароля",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _resetController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Ваш Email",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: _resetController.text.trim(),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Инструкция отправлена на Email"),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: const Text("ОТПРАВИТЬ"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Этот виджет "слушает" Firebase в реальном времени
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Если данные еще грузятся (проверка идет)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF121212),
            body: Center(child: CircularProgressIndicator(color: Colors.blue)),
          );
        }

        // Если пользователь уже вошел в систему раньше
        if (snapshot.hasData) {
          return const MainScreen(); 
        }

        // Если пользователя нет (новый или вышел из системы)
        return const WelcomeScreen();
      },
    );
  }
}
