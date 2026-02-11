import 'package:flutter/material.dart';
import 'package:ukk_paket4/database/database.dart';
import 'search_buku.dart';
import 'pengajuan_peminjaman.dart';
import 'history_peminjaman.dart';
import 'profile_user.dart';
import '../login_page.dart';

class UserHome extends StatefulWidget {
  final int userId;
  const UserHome({super.key, required this.userId});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  int currentIndex = 0;
  final Color primaryBlue = const Color(0xFF1E3A8A);
  final Color lightBlue = const Color(0xFFDBEAFE);

  List<Map<String, dynamic>> _daftarBuku = [];

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    final db = await DatabaseHelper.instance.database;
    final data = await db.query('buku', limit: 8);
    setState(() => _daftarBuku = data);
  }

  // Menampilkan halaman berdasarkan index navbar
  Widget _getMainContent() {
    switch (currentIndex) {
      case 1:
        return HistoryPeminjaman(userId: widget.userId);
      case 2:
        return ProfileUser(userId: widget.userId);
      default:
        return _buildHomeDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text("Smecha Book", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
          )
        ],
      ),
      body: _getMainContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: "Riwayat"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profil"),
        ],
      ),
    );
  }

  Widget _buildHomeDashboard() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Search Box
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Halo, Selamat Datang!", style: TextStyle(color: Colors.white70, fontSize: 14)),
                const Text("Mau baca apa hari ini?", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SearchBuku(userId: widget.userId))),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: primaryBlue),
                        const SizedBox(width: 10),
                        const Text("Cari buku di perpustakaan...", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 25, 20, 10),
            child: Text("Koleksi Terbaru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
          _daftarBuku.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Belum ada koleksi buku.")))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: _daftarBuku.length,
                  itemBuilder: (context, index) {
                    final buku = _daftarBuku[index];
                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade100)),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: lightBlue, borderRadius: BorderRadius.circular(10)),
                          child: Icon(Icons.book_rounded, color: primaryBlue),
                        ),
                        title: Text(buku['judul'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(buku['pengarang']),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PengajuanPeminjaman(userId: widget.userId, selectedBook: buku['judul']))),
                          child: const Text("Pinjam", style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}