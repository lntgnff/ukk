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
  
  final Color primaryBlue = const Color(0xFF1E3A8A);
  final Color lightBlue = const Color(0xFFDBEAFE); 
  final Color accentBlue = const Color(0xFF3B82F6);  

  List<Map<String, dynamic>> rekomendasiBuku = [];
  List<Map<String, dynamic>> bukuDipinjam = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final listBuku = await db.query('buku', limit: 10);
      final listPinjam = await db.rawQuery('''
        SELECT t.id as transaksi_id, b.judul, t.tanggal_pinjam 
        FROM transaksi t 
        JOIN buku b ON t.buku_id = b.id 
        WHERE t.user_id = ? AND t.status = 'Disetujui'
      ''', [widget.userId]);

      if (!mounted) return;
      setState(() {
        rekomendasiBuku = List<Map<String, dynamic>>.from(listBuku);
        bukuDipinjam = List<Map<String, dynamic>>.from(listPinjam);
      });
    } catch (e) {
      print("ERROR: $e");
    }
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
        title: const Text("Perpustakaan Digital", 
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const LoginPage())),
            icon: const Icon(Icons.logout_rounded),
          )
        ],
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: "Cari"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profil"),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Sedang Dipinjam",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                if (bukuDipinjam.isNotEmpty)
                  Text("${bukuDipinjam.length} Buku", style: TextStyle(color: accentBlue, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          bukuDipinjam.isEmpty
              ? _buildEmptyState("Tidak ada pinjaman aktif")
              : SizedBox(
                  height: 100,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: bukuDipinjam.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 280,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: lightBlue),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: lightBlue,
                            child: Icon(Icons.bookmark, color: primaryBlue),
                          ),
                          title: Text(bukuDipinjam[index]['judul'], 
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Pinjam: ${bukuDipinjam[index]['tanggal_pinjam']}", style: const TextStyle(fontSize: 12)),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryPeminjaman(userId: widget.userId))),
                        ),
                      );
                    },
                  ),
                ),

          const SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text("Katalog Buku",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          ),
          const SizedBox(height: 15),
          rekomendasiBuku.isEmpty
              ? _buildEmptyState("Buku tidak tersedia")
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: rekomendasiBuku.length,
                  itemBuilder: (context, index) {
                    final buku = rekomendasiBuku[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          width: 50, height: 70,
                          decoration: BoxDecoration(
                            color: lightBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.menu_book_rounded, color: primaryBlue),
                        ),
                        title: Text(buku['judul'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(buku['pengarang'] ?? '-', style: TextStyle(color: Colors.grey[600])),
                        trailing: ElevatedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PengajuanPeminjaman(userId: widget.userId, selectedBook: buku['judul']))),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text("Pinjam"),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 40, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Text(msg, style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      ),
    );
  }
}