import 'package:flutter/material.dart';
import 'package:ukk_paket4/database/database.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AdminHistoryPeminjaman extends StatefulWidget {
  const AdminHistoryPeminjaman({super.key});

  @override
  State<AdminHistoryPeminjaman> createState() => _AdminHistoryPeminjamanState();
}

class _AdminHistoryPeminjamanState extends State<AdminHistoryPeminjaman> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _allData = [];
  bool _isLoading = true;

  // TEMA WARNA BIRU SELARAS
  final Color primaryBlue = const Color(0xFF1E3A8A); 
  final Color lightBlue = const Color(0xFFDBEAFE);   
  final Color scaffoldBg = const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> data = await db.rawQuery('''
        SELECT t.*, b.judul as nama_buku, u.email as nama_peminjam
        FROM transaksi t
        LEFT JOIN buku b ON t.buku_id = b.id
        LEFT JOIN users u ON t.user_id = u.id
        ORDER BY t.id DESC
      ''');
      setState(() {
        _allData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryBlue,
        // MEMBUAT ICON BACK JADI PUTIH
        iconTheme: const IconThemeData(color: Colors.white), 
        title: const Text(
          "HISTORY PEMINJAMAN", 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            letterSpacing: 1.2,
            color: Colors.white // TULISAN HISTORY JADI PUTIH
          )
        ),
        centerTitle: true,
        actions: [
          IconButton(
            // ICON PDF JADI PUTIH
            icon: const Icon(Icons.print_rounded, color: Colors.white), 
            onPressed: _allData.isEmpty ? null : _generatePdf,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white, // GARIS BAWAH TAB JADI PUTIH
          indicatorWeight: 3,
          // WARNA TEKS TAB (AKTIF & SELESAI) JADI PUTIH
          labelColor: Colors.white, 
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "AKTIF"),
            Tab(text: "SELESAI"),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryBlue))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildListView(_allData.where((i) => i['status'] != 'Kembali').toList()),
                _buildListView(_allData.where((i) => i['status'] == 'Kembali').toList()),
              ],
            ),
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 10),
            const Text("Belum ada data transaksi", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        bool isSelesai = item['status'] == 'Kembali';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelesai ? Colors.green.withOpacity(0.1) : lightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelesai ? Icons.check_circle_outline : Icons.pending_actions,
                color: isSelesai ? Colors.green : primaryBlue,
              ),
            ),
            title: Text(item['nama_buku'] ?? "Buku Terhapus", 
              style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("👤 ${item['nama_peminjam'] ?? 'User tidak dikenal'}"),
                  const SizedBox(height: 2),
                  Text("📅 ${item['tanggal_pinjam']} - ${item['tanggal_kembali']}"),
                ],
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(item['status']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item['status'].toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(item['status']),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui': return Colors.blue;
      case 'kembali': return Colors.green;
      case 'ditolak': return Colors.red;
      default: return Colors.orange;
    }
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      build: (context) => [
        pw.Header(level: 0, child: pw.Text("Laporan Transaksi Perpustakaan")),
        pw.SizedBox(height: 20),
        pw.TableHelper.fromTextArray(
          headers: ['Buku', 'Peminjam', 'Pinjam', 'Kembali', 'Status'],
          data: _allData.map((e) => [
            e['nama_buku'], e['nama_peminjam'], e['tanggal_pinjam'], e['tanggal_kembali'], e['status']
          ]).toList(),
        ),
      ],
    ));
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}