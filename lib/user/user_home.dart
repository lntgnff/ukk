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
  final Color primaryColor = const Color(0xFF6C63FF);
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

    print("Buku loaded: ${rekomendasiBuku.length}");
  } catch (e) {
    print("ERROR LOAD DATA: $e");
  }
}

  void kembalikanBuku(int transaksiId) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'transaksi',
      {'status': 'Kembali', 'tanggal_kembali': DateTime.now().toString()},
      where: 'id = ?',
      whereArgs: [transaksiId],
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Buku berhasil dikembalikan!")),
    );
    _loadData(); 
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      _buildHomeContent(),
      const SearchBuku(),
      ProfileUser(userId: widget.userId),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F3FD),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Perpustakaan Digital"),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        selectedItemColor: primaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Cari"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Halo User #${widget.userId},", style: const TextStyle(fontSize: 16)),
          const Text("Mau baca apa hari ini?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

const Text("Buku Sedang Dipinjam", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
const SizedBox(height: 10),
bukuDipinjam.isEmpty 
  ? const Text("Tidak ada buku yang sedang dipinjam.")
  : Column(
      children: bukuDipinjam.map((buku) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: const Icon(Icons.book, color: Colors.orange),
          title: Text(buku['judul']),
          subtitle: Text("Dipinjam: ${buku['tanggal_pinjam']}"),
          trailing: TextButton(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => HistoryPeminjaman(userId: widget.userId))
              );
            },
            child: const Text("Lihat Riwayat"),
          ),
        ),
      )).toList(),
    ),
          const SizedBox(height: 25),

const Text(
  "Rekomendasi Untukmu",
  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),
const SizedBox(height: 10),

rekomendasiBuku.isEmpty
    ? const Text("Belum ada buku tersedia.")
    : SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: rekomendasiBuku.length,
          itemBuilder: (context, index) {
            final buku = rekomendasiBuku[index];

            return Container(
              width: 140,
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, size: 50, color: primaryColor),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      buku['judul']?.toString() ?? '-',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    buku['pengarang']?.toString() ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PengajuanPeminjaman(
                            userId: widget.userId,
                            selectedBook: buku['judul']?.toString() ?? '',
                          ),
                        ),
                      );
                    },
                    child: const Text("Pinjam"),
                  ),
                ],
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