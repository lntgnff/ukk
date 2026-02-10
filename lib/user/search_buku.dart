import 'package:flutter/material.dart';
import '../data.dart';
import 'pengajuan_peminjaman.dart';

class SearchBuku extends StatefulWidget {
  const SearchBuku({super.key});

  @override
  State<SearchBuku> createState() => _SearchBukuState();
}

class _SearchBukuState extends State<SearchBuku> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  final Color primaryColor = const Color(0xFF6C63FF);
  final Color bgColor = const Color(0xFFF4F3FD);

  void searchBooks(String query) {
    setState(() {
      if (query.isEmpty) {
        searchResults = [];
      } else {
        searchResults = books
            .where((book) =>
                book['judul'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void pinjamBuku(String judul) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PengajuanPeminjaman(
        userId: 1, 
        selectedBook: judul,
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text("Cari Buku"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: searchBooks,
              decoration: InputDecoration(
                hintText: "Cari judul buku...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: searchResults.isEmpty
                  ? Center(
                      child: Text(
                        searchController.text.isEmpty
                            ? "Mulai mengetik untuk mencari buku"
                            : "Tidak ada hasil pencarian",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                searchResults[index]['gambar'],
                                width: 50,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 50,
                                    height: 70,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.book),
                                  );
                                },
                              ),
                            ),
                            title: Text(
                              searchResults[index]['judul'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                                "Status: ${searchResults[index]['status']}"),
                            trailing: ElevatedButton.icon(
                              onPressed: () =>
                                  pinjamBuku(searchResults[index]['judul']),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text("Pinjam"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
