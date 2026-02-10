import 'package:flutter/material.dart';
import 'package:ukk_paket4/database/database.dart';

class HistoryPeminjaman extends StatefulWidget {
  final int userId;
  const HistoryPeminjaman({super.key, required this.userId});
  @override
  State<HistoryPeminjaman> createState() => _HistoryPeminjamanState();
}

class _HistoryPeminjamanState extends State<HistoryPeminjaman> {
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final db = await DatabaseHelper.instance.database;
    final data = await db.rawQuery('''
      SELECT t.id, b.judul, t.tanggal_pinjam, t.tanggal_kembali, t.status 
      FROM transaksi t
      JOIN buku b ON t.buku_id = b.id
      WHERE t.user_id = ? ORDER BY t.id DESC
    ''', [widget.userId]);
    setState(() => _history = data);
  }

  void _kembalikanBuku(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('transaksi', {'status': 'Kembali'}, where: 'id = ?', whereArgs: [id]);
    _loadHistory();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Buku berhasil dikembalikan!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Pinjaman Saya")),
      body: _history.isEmpty 
        ? const Center(child: Text("Belum ada riwayat transaksi."))
        : ListView.builder(
            itemCount: _history.length,
            itemBuilder: (context, index) {
              final item = _history[index];
              bool isDisetujui = item['status'] == 'Disetujui';
              
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(item['judul']),
                  subtitle: Text("Status: ${item['status']}\nKembali: ${item['tanggal_kembali']}"),
                  trailing: isDisetujui 
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () => _kembalikanBuku(item['id']),
                        child: const Text("Kembalikan"),
                      )
                    : Text(item['status'], style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: item['status'] == 'Kembali' ? Colors.green : Colors.grey
                      )),
                ),
              );
            },
          ),
    );
  }
}