import 'package:flutter/material.dart';
import 'package:ukk_paket4/user/history_peminjaman.dart';
import '../login_page.dart';
import 'search_buku.dart';
import 'profile_user.dart';
import 'pengajuan_peminjaman.dart';
import 'package:ukk_paket4/database/database.dart';

class UserHome extends StatefulWidget {
  final int userId;
  const UserHome({super.key, required this.userId});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  int currentIndex = 0;
  
  // PALET WARNA BIRU ADMIN (NUANSA ELEGAN)
  final Color primaryBlue = const Color(0xFF1E3A8A); // Royal Blue
  final Color accentBlue = const Color(0xFF3B82F6);  // Biru Terang
  final Color softBlue = const Color(0xFFEFF6FF);    // Background Biru Sangat Muda

  List<Map<String, dynamic>> rekomendasiBuku = [];
  List<Map<String, dynamic>> bukuDipinjam = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = await DatabaseHelper.instance.database;
    final listBuku = await db.query('buku', limit: 10);
    final listPinjam = await db.rawQuery('''
      SELECT t.id, b.judul, t.tanggal_pinjam 
      FROM transaksi t 
      JOIN buku b ON t.buku_id = b.id 
      WHERE t.user_id = ? AND t.status = 'Disetujui'
    ''', [widget.userId]);

    setState(() {
      rekomendasiBuku = listBuku;
      bukuDipinjam = listPinjam;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      _buildHomeContent(),
      const SearchBuku(),
      ProfileUser(userId: widget.userId),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryBlue,
        title: const Text("DIGI-LIB", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
          )
        ],
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Cari"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER BANNER BIRU
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Temukan Pengetahuan,", style: TextStyle(color: Colors.white70, fontSize: 16)),
                const Text("Ayo Membaca Hari Ini!", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                // SEARCH BAR SIMULASI
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                  child: TextField(
                    readOnly: true,
                    onTap: () => setState(() => currentIndex = 1),
                    decoration: const InputDecoration(hintText: "Cari judul buku...", border: InputBorder.none, icon: Icon(Icons.search)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // SEKSI BUKU DIPINJAM (HORIZONTAL)
          _sectionTitle("Pinjaman Aktif"),
          const SizedBox(height: 10),
          bukuDipinjam.isEmpty
              ? _buildEmptyState("Kamu tidak memiliki pinjaman aktif")
              : SizedBox(
                  height: 100,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: bukuDipinjam.length,
                    itemBuilder: (context, index) => _buildCardPinjam(bukuDipinjam[index]),
                  ),
                ),

          const SizedBox(height: 25),

          // SEKSI DAFTAR BUKU
          _sectionTitle("Rekomendasi Buku"),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            itemCount: rekomendasiBuku.length,
            itemBuilder: (context, index) => _buildBookItem(rekomendasiBuku[index]),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCardPinjam(Map<String, dynamic> data) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: softBlue, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_stories, color: accentBlue),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(data['judul'], style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text("Pinjam: ${data['tanggal_pinjam']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookItem(Map<String, dynamic> buku) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.book, color: primaryBlue),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(buku['judul'], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(buku['pengarang'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PengajuanPeminjaman(userId: widget.userId, selectedBook: buku['judul']))),
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text("Pinjam"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(child: Text(msg, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)));
  }
}