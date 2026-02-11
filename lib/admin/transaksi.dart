import 'package:flutter/material.dart';
import '../database/database.dart';

class TransaksiAdmin extends StatefulWidget {
  const TransaksiAdmin({super.key});
  @override
  State<TransaksiAdmin> createState() => _TransaksiAdminState();
}

class _TransaksiAdminState extends State<TransaksiAdmin> {
  List<Map<String, dynamic>> _listPengajuan = [];
  final Color primaryBlue = const Color(0xFF1E3A8A);

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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pengajuan $status", style: const TextStyle(fontWeight: FontWeight.bold))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text("Konfirmasi Pinjaman", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Column(
        children: [
          Container(
            height: 30,
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
          ),
          Expanded(
            child: _listPengajuan.isEmpty 
            ? Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text("Semua pengajuan sudah diproses", style: TextStyle(color: Colors.grey)),
                ],
              ))
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _listPengajuan.length,
                itemBuilder: (context, index) {
                  final trx = _listPengajuan[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(trx['judul'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                              const Icon(Icons.pending, color: Colors.orange, size: 20),
                            ],
                          ),
                          const Divider(height: 20),
                          Text("Peminjam: ${trx['email']}", style: const TextStyle(color: Colors.blueGrey)),
                          const SizedBox(height: 4),
                          Text("Tenggat: ${trx['tanggal_pinjam']} s/d ${trx['tanggal_kembali']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _updateStatus(trx['id'], 'Ditolak'),
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  label: const Text("Tolak", style: TextStyle(color: Colors.red)),
                                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _updateStatus(trx['id'], 'Disetujui'),
                                  icon: const Icon(Icons.check),
                                  label: const Text("Setujui"),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
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