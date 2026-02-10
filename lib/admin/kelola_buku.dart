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
    if (_judulController.text.isEmpty || _penulisController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul dan Penulis tidak boleh kosong!")),
      );
      return;
    }

    final db = await DatabaseHelper.instance.database;
    await db.insert('buku', {
      'judul': _judulController.text,
      'pengarang': _penulisController.text,
      'stok': 10, // Nilai default
    });

    _judulController.clear();
    _penulisController.clear();
    if (mounted) Navigator.pop(context);
    
    _loadBooks();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Buku berhasil disimpan!")),
    );
  }

  void _hapusBuku(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('buku', where: 'id = ?', whereArgs: [id]);
    _loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Buku")),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahBukuDialog,
        child: const Icon(Icons.add),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _listBuku.isEmpty 
          ? const Center(child: Text("Belum ada buku. Klik + untuk menambah."))
          : ListView.builder(
              itemCount: _listBuku.length,
              itemBuilder: (context, index) {
                final buku = _listBuku[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.book, color: Color(0xFF6C63FF)),
                    title: Text(buku['judul']),
                    subtitle: Text("Penulis: ${buku['pengarang']}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _hapusBuku(buku['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _tambahBukuDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
          ElevatedButton(onPressed: _simpanBuku, child: const Text("Simpan")),
        ],
      ),
    );
  }
}