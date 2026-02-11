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
        SELECT 
          t.*, 
          b.judul as nama_buku, 
          u.email as nama_peminjam
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

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text("Laporan Riwayat Peminjaman Perpustakaan", 
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['ID', 'Peminjam', 'Buku', 'Tgl Pinjam', 'Tgl Kembali', 'Status'],
              data: _allData.map((item) {
                return [
                  item['id'].toString(),
                  item['nama_peminjam'] ?? '-',
                  item['nama_buku'] ?? '-',
                  item['tanggal_pinjam'] ?? '-',
                  item['tanggal_kembali'] ?? '-',
                  item['status'].toString().toUpperCase(),
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
              },
            ),
          ];
        },
      ),
    );

    // Menampilkan Preview PDF dan Tombol Print/Save
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_Perpustakaan_${DateTime.now().millisecondsSinceEpoch}.pdf'
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History Peminjaman"),
        backgroundColor: const Color(0xFF6C63FF),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Export PDF",
            onPressed: _allData.isEmpty ? null : _generatePdf,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Aktif"),
            Tab(text: "Selesai"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_allData.where((i) => i['status'] != 'Kembali').toList()),
                _buildList(_allData.where((i) => i['status'] == 'Kembali').toList()),
              ],
            ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return const Center(child: Text("Tidak ada data."));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: ListTile(
            title: Text(item['nama_buku'] ?? "Buku Terhapus"),
            subtitle: Text("Peminjam: ${item['nama_peminjam']}\nStatus: ${item['status']}"),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}