import 'package:flutter/material.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final Color primaryColor = const Color(0xFF6C63FF);
  final Color bgColor = const Color(0xFFF4F3FD);
  late TextEditingController _searchController;
  String _searchQuery = '';

  final List<Map<String, dynamic>> books = [
    {
      'id': 1,
      'title': 'Hujan',
      'author': 'Tere Liye',
      'status': 'Dipinjam',
      'borrowedBy': 'Ahmad Reza',
      'borrowDate': '2024-01-15',
    },
    {
      'id': 2,
      'title': 'Bumi',
      'author': 'Tere Liye',
      'status': 'Tersedia',
      'borrowedBy': null,
      'borrowDate': null,
    },
    {
      'id': 3,
      'title': 'Laskar Pelangi',
      'author': 'Andrea Hirata',
      'status': 'Dipinjam',
      'borrowedBy': 'Siti Nurhaliza',
      'borrowDate': '2024-01-20',
    },
    {
      'id': 4,
      'title': 'Rinjani',
      'author': 'Nabila N Haris',
      'status': 'Dipinjam',
      'borrowedBy': 'Heru Susanto',
      'borrowDate': '2024-03-15',
    },
    {
      'id': 5,
      'title': 'Kita Pergi Hari Ini',
      'author': 'Ziggy Zezsyazeoviennazabrizkie',
      'status': 'Tersedia',
      'borrowedBy': null,
      'borrowDate': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredBooks() {
    if (_searchQuery.isEmpty) {
      return books;
    }
    return books.where((book) {
      final title = book['title'].toString().toLowerCase();
      final author = book['author'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || author.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredBooks = _getFilteredBooks();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text(
          "Bookmark - Status Buku",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari judul atau penulis...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Books list
            Expanded(
              child: filteredBooks.isEmpty
                  ? Center(
                      child: Text(
                        'Buku tidak ditemukan',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredBooks.length,
                      itemBuilder: (context, index) {
                        final book = filteredBooks[index];
                        final isAvailable = book['status'] == 'Tersedia';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            book['title'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Penulis: ${book['author']}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isAvailable
                                            ? Colors.green[100]
                                            : Colors.orange[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        book['status'],
                                        style: TextStyle(
                                          color: isAvailable
                                              ? Colors.green[700]
                                              : Colors.orange[700],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (!isAvailable) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Dipinjam oleh: ${book['borrowedBy']}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        Text(
                                          'Tanggal Pinjam: ${book['borrowDate']}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
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
}
