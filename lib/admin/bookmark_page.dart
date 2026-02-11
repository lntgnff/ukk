import 'package:flutter/material.dart';
import 'package:ukk_paket4/database/database.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final Color primaryBlue = const Color(0xFF1E3A8A);
  List<Map<String, dynamic>> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    final db = await DatabaseHelper.instance.database;
    final data = await db.query('buku');
    setState(() {
      _books = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
       title: const Text(
          "Status Ketersediaan Buku", 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _books.length,
              itemBuilder: (context, index) {
                final book = _books[index];
                bool isAvailable = (book['stok'] ?? 0) > 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(blurRadius: 5)],
                  ),
                  child: ListTile(
                    leading: Icon(Icons.book, color: isAvailable ? Colors.green : Colors.red),
                    title: Text(book['judul'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(book['pengarang']),
                    trailing: Text(
                      isAvailable ? "Tersedia" : "Kosong",
                      style: TextStyle(color: isAvailable ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
    );
  }
}