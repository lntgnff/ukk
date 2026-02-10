import 'package:flutter/material.dart';
import '../database/database.dart';

class TransaksiAdmin extends StatefulWidget {
  const TransaksiAdmin({super.key});
  @override
  State<TransaksiAdmin> createState() => _TransaksiAdminState();
}

class _TransaksiAdminState extends State<TransaksiAdmin> {
  List<Map<String, dynamic>> _listPengajuan = [];

  @override
  void initState() {
    super.initState();
    _loadPengajuan();
  }

  Future<void> _loadPengajuan() async {
    final db = await DatabaseHelper.instance.database;
    final data = await db.rawQuery('''
      SELECT t.id, b.judul, u.email, t.tanggal_pinjam, t.tanggal_kembali, t.status 
      FROM transaksi t
      JOIN buku b ON t.buku_id = b.id
      JOIN users u ON t.user_id = u.id
      WHERE t.status = 'Pending'
    ''');
    setState(() => _listPengajuan = data);
  }

  void _updateStatus(int id, String status) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('transaksi', {'status': status}, where: 'id = ?', whereArgs: [id]);
    _loadPengajuan();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pengajuan $status")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Persetujuan Pinjaman")),
      body: _listPengajuan.isEmpty 
        ? const Center(child: Text("Tidak ada pengajuan baru"))
        : ListView.builder(
            itemCount: _listPengajuan.length,
            itemBuilder: (context, index) {
              final trx = _listPengajuan[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(trx['judul']),
                  subtitle: Text("Peminjam: ${trx['email']}\nDurasi: ${trx['tanggal_pinjam']} s/d ${trx['tanggal_kembali']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => _updateStatus(trx['id'], 'Disetujui')),
                      IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => _updateStatus(trx['id'], 'Ditolak')),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}