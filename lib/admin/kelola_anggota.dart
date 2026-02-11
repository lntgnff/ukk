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
  
  final Color primaryBlue = const Color(0xFF1E3A8A);
  final Color lightBlue = const Color(0xFFDBEAFE);

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
    if (emailController.text.isEmpty || passwordController.text.isEmpty) return;
    final db = await DatabaseHelper.instance.database;
    await db.insert('users', {
      'email': emailController.text,
      'password': passwordController.text,
      'is_admin': 0,
    });
    emailController.clear();
    passwordController.clear();
    _loadUsers();
    FocusScope.of(context).unfocus();
  }

  void _hapusUser(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text("Kelola Anggota", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Column(
        children: [
          // Form Input Area
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Email Anggota",
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.email, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _tambahUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("Daftarkan Anggota Baru", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(alignment: Alignment.centerLeft, child: Text("Daftar Anggota Aktif", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ),
          
          Expanded(
            child: _users.isEmpty 
            ? Center(child: Text("Belum ada anggota", style: TextStyle(color: Colors.grey[400])))
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _users.length,
                itemBuilder: (context, i) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: lightBlue, child: Icon(Icons.person, color: primaryBlue)),
                    title: Text(_users[i]['email'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("Status: Anggota Aktif", style: TextStyle(fontSize: 12)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _hapusUser(_users[i]['id']),
                    ),
                  ),
                ),
              ),
          )
        ],
      ),
    );
  }
}