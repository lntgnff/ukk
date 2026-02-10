import 'package:flutter/material.dart';
import 'package:ukk_paket4/database/database.dart';

class KelolaAnggota extends StatefulWidget {
  const KelolaAnggota({super.key});

  @override
  State<KelolaAnggota> createState() => _KelolaAnggotaState();
}

class _KelolaAnggotaState extends State<KelolaAnggota> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    final db = await DatabaseHelper.instance.database;
    final data = await db.query('users', where: 'is_admin = ?', whereArgs: [0]);
    setState(() => _users = data);
  }

  void _tambahUser() async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('users', {
      'email': emailController.text,
      'password': passwordController.text,
      'is_admin': 0,
    });
    emailController.clear();
    passwordController.clear();
    _loadUsers();
  }

  void _hapusUser(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftarkan User")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
                TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Password")),
                ElevatedButton(onPressed: _tambahUser, child: const Text("Simpan User")),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(_users[i]['email']),
                trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _hapusUser(_users[i]['id'])),
              ),
            ),
          )
        ],
      ),
    );
  }
}