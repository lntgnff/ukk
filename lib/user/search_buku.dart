import 'package:flutter/material.dart';
import 'package:ukk_paket4/database/database.dart';
import 'pengajuan_peminjaman.dart';

class SearchBuku extends StatefulWidget {
  final int userId;
  const SearchBuku({super.key, required this.userId});

  @override
  State<SearchBuku> createState() => _SearchBukuState();
}

class _SearchBukuState extends State<SearchBuku> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  final Color primaryBlue = const Color(0xFF1E3A8A);

  void _onSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);
    final db = await DatabaseHelper.instance.database;
    
    // Mencari berdasarkan judul buku di database Admin
    final data = await db.query(
      'buku',
      where: 'judul LIKE ?',
      whereArgs: ['%$query%'],
    );

    setState(() {
      _searchResults = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Cari Buku", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: primaryBlue,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Masukkan judul buku...",
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryBlue))
                : _searchResults.isEmpty && _searchController.text.isNotEmpty
                    ? const Center(child: Text("Buku tidak ditemukan."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(15),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final buku = _searchResults[index];
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: ListTile(
                              leading: Icon(Icons.menu_book_rounded, color: primaryBlue),
                              title: Text(buku['judul'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(buku['pengarang']),
                              trailing: IconButton(
                                icon: Icon(Icons.add_circle_outline, color: primaryBlue),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (_) => PengajuanPeminjaman(
                                      userId: widget.userId, 
                                      selectedBook: buku['judul']
                                    )
                                  ));
                                },
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
}