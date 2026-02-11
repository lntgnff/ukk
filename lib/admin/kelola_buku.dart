import 'package:flutter/material.dart';
import 'package:ukk_paket4/database/database.dart'; 

class KelolaBuku extends StatefulWidget {
  const KelolaBuku({super.key});

  @override
  State<KelolaBuku> createState() => _KelolaBukuState();
}

class _KelolaBukuState extends State<KelolaBuku> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _penulisController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _listBuku = [];
  bool _isLoading = true;
  
  final Color primaryBlue = const Color(0xFF1E3A8A);
  final Color lightBlue = const Color(0xFFDBEAFE);

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  // SEARCH LANGSUNG KE DATABASE
  Future<void> _loadBooks({String query = ""}) async {
    setState(() => _isLoading = true);
    final db = await DatabaseHelper.instance.database;
    
    List<Map<String, dynamic>> data;
    if (query.isEmpty) {
      data = await db.query('buku', orderBy: 'id DESC');
    } else {
      data = await db.query(
        'buku',
        where: 'judul LIKE ? OR pengarang LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'id DESC',
      );
    }

    setState(() {
      _listBuku = data;
      _isLoading = false;
    });
  }

  void _simpanBuku() async {
    if (_judulController.text.isEmpty || _penulisController.text.isEmpty) return;
    final db = await DatabaseHelper.instance.database;
    await db.insert('buku', {
      'judul': _judulController.text,
      'pengarang': _penulisController.text,
      'stok': 1 // Default stok
    });
    _judulController.clear();
    _penulisController.clear();
    Navigator.pop(context);
    _loadBooks();
  }

  void _hapusBuku(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('buku', where: 'id = ?', whereArgs: [id]);
    _loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Kelola Koleksi Buku", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Container(
            padding: const EdgeInsets.all(16),
            color: primaryBlue,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _loadBooks(query: value),
              decoration: InputDecoration(
                hintText: "Cari judul atau penulis...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryBlue))
                : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: _listBuku.length,
                    itemBuilder: (context, index) {
                      final buku = _listBuku[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: lightBlue, child: Icon(Icons.book, color: primaryBlue)),
                          title: Text(buku['judul'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(buku['pengarang']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                            onPressed: () => _hapusBuku(buku['id']),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        onPressed: _tambahBukuDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _tambahBukuDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Buku"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _judulController, decoration: const InputDecoration(labelText: "Judul Buku")),
            TextField(controller: _penulisController, decoration: const InputDecoration(labelText: "Penulis")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(onPressed: _simpanBuku, child: const Text("Simpan")),
        ],
      ),
    );
  }
}