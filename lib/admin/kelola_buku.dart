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
  List<Map<String, dynamic>> _listBuku = [];
  bool _isLoading = true;
  
  final Color primaryBlue = const Color(0xFF1E3A8A);
  final Color lightBlue = const Color(0xFFDBEAFE);

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    final db = await DatabaseHelper.instance.database;
    final data = await db.query('buku', orderBy: 'id DESC');
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
      'stok': 10,
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
        elevation: 0,
        title: const Text("Daftar Buku", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahBukuDialog,
        backgroundColor: primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: primaryBlue))
        : Column(
            children: [
              Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
              ),
              Expanded(
                child: _listBuku.isEmpty 
                ? const Center(child: Text("Koleksi masih kosong"))
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _listBuku.length,
                    itemBuilder: (context, index) {
                      final buku = _listBuku[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(color: lightBlue, borderRadius: BorderRadius.circular(12)),
                            child: Icon(Icons.menu_book_rounded, color: primaryBlue),
                          ),
                          title: Text(buku['judul'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(buku['pengarang'], style: TextStyle(color: Colors.grey[600])),
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
    );
  }

  void _tambahBukuDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Tambah Buku Baru"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _judulController, decoration: const InputDecoration(labelText: "Judul Buku")),
            TextField(controller: _penulisController, decoration: const InputDecoration(labelText: "Penulis")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: _simpanBuku,
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}