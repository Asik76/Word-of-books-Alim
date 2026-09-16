import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsersRelationshipPage extends StatefulWidget {
  final int initialIndex;
  const UsersRelationshipPage({super.key, required this.initialIndex});

  @override
  State<UsersRelationshipPage> createState() => _UsersRelationshipPageState();
}

class _UsersRelationshipPageState extends State<UsersRelationshipPage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String displayName = "Загрузка...";
        if (snapshot.hasData && snapshot.data!.exists) {
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String name = userData['name'] ?? "Имя";
          String nickname =
              userData['nickname'] ??
              "Никнейм"; 
          displayName = "$name ($nickname)";
        }

        return DefaultTabController(
          length: 4,
          initialIndex: widget.initialIndex,
          child: Scaffold(
            backgroundColor: const Color(0xFF121212),
            appBar: AppBar(
              backgroundColor: const Color(0xFF121212),
              elevation: 0,
              centerTitle: true, 
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.person_add_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // Глобальный поиск
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    isScrollable: true,
                    tabAlignment:
                        TabAlignment.start, 
                    indicatorColor: Colors.white,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    labelPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    tabs: const [
                      Tab(text: "Подписки"),
                      Tab(text: "Подписчики"),
                      Tab(text: "Друзья"),
                      Tab(text: "Рекомендации"),
                    ],
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                // Поиск
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF262626),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Поиск",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: 20,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: TabBarView(
                    children: [
                      UserListWidget(),
                      UserListWidget(),
                      UserListWidget(),
                      UserListWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class UserListWidget extends StatelessWidget {
  const UserListWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => ListTile(
        leading: const CircleAvatar(backgroundColor: Colors.blueAccent),
        title: Text(
          "Пользователь $index",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
