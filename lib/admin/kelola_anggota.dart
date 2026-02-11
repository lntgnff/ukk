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
  final searchController = TextEditingController();
  
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  
  final Color primaryBlue = const Color(0xFF1E3A8A);
  final Color lightBlue = const Color(0xFFDBEAFE);

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // SEARCH USER DARI DATABASE
  void _loadUsers({String query = ""}) async {
    setState(() => _isLoading = true);
    final db = await DatabaseHelper.instance.database;
    
    List<Map<String, dynamic>> data;
    if (query.isEmpty) {
      data = await db.query('users', where: 'is_admin = ?', whereArgs: [0]);
    } else {
      data = await db.query(
        'users',
        where: 'is_admin = ? AND email LIKE ?',
        whereArgs: [0, '%$query%'],
      );
    }
    
    setState(() {
      _users = data;
      _isLoading = false;
    });
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Kelola Anggota", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // SEARCH USER BAR
          Container(
            padding: const EdgeInsets.all(16),
            color: primaryBlue,
            child: TextField(
              controller: searchController,
              onChanged: (value) => _loadUsers(query: value),
              decoration: InputDecoration(
                hintText: "Cari email anggota...",
                prefixIcon: const Icon(Icons.person_search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),

          // INPUT TAMBAH USER (Design Baru)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email Baru", prefixIcon: Icon(Icons.email_outlined))),
                    TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock_outline))),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        onPressed: _tambahUser, 
                        child: const Text("Daftarkan Anggota Baru", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading 
            ? Center(child: CircularProgressIndicator(color: primaryBlue))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _users.length,
                itemBuilder: (context, i) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: lightBlue, child: Icon(Icons.person, color: primaryBlue)),
                    title: Text(_users[i]['email'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _hapusUser(_users[i]['id'])),
                  ),
                ),
              ),
          )
        ],
      ),
    );
  }
}