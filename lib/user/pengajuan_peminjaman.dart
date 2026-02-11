import 'package:flutter/material.dart';
import 'package:ukk_paket4/database/database.dart'; 

class PengajuanPeminjaman extends StatefulWidget {
  final int userId;
  final String? selectedBook;

  const PengajuanPeminjaman({super.key, required this.userId, this.selectedBook});

  @override
  State<PengajuanPeminjaman> createState() => _PengajuanPeminjamanState();
}

class _PengajuanPeminjamanState extends State<PengajuanPeminjaman> {
  final Color primaryColor = const Color(0xFF6C63FF);
  
  List<Map<String, dynamic>> _daftarBuku = [];
  int? _selectedBookId;
  bool _isLoading = true;

  final TextEditingController _durasiController = TextEditingController(text: "7"); // Default 7 hari
  DateTime _tanggalPinjam = DateTime.now();
  DateTime _tanggalKembali = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _ambilDataBuku();
    
    _durasiController.addListener(_updateTanggalKembali);
  }

  @override
  void dispose() {
    _durasiController.dispose();
    super.dispose();
  }

  void _updateTanggalKembali() {
    int hari = int.tryParse(_durasiController.text) ?? 0;
    setState(() {
      _tanggalKembali = _tanggalPinjam.add(Duration(days: hari));
    });
  }

  Future<void> _ambilDataBuku() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> data = await db.query('buku');
    
    setState(() {
      _daftarBuku = data;
      _isLoading = false;

      if (widget.selectedBook != null && _daftarBuku.isNotEmpty) {
        try {
          final found = _daftarBuku.firstWhere(
            (b) => b['judul'].toString().toLowerCase() == widget.selectedBook!.toLowerCase()
          );
          _selectedBookId = found['id'];
        } catch (e) {
          _selectedBookId = null;
        }
      }
    });
  }

  void _kirimPengajuan() async {
    if (_selectedBookId == null) {
      _showSnackBar("Pilih buku terlebih dahulu!", Colors.red);
      return;
    }

    int durasi = int.tryParse(_durasiController.text) ?? 0;
    if (durasi <= 0) {
      _showSnackBar("Durasi pinjam minimal 1 hari!", Colors.red);
      return;
    }

    final db = await DatabaseHelper.instance.database;
    await db.insert('transaksi', {
      'user_id': widget.userId,
      'buku_id': _selectedBookId,
      'tanggal_pinjam': _tanggalPinjam.toString().split(' ')[0],
      'tanggal_kembali': _tanggalKembali.toString().split(' ')[0],
      'status': 'Pending',
    });

    if (mounted) {
      _showSnackBar("Pengajuan berhasil dikirim!", Colors.green);
      Navigator.pop(context);
    }
  }

  void _showSnackBar(String pesan, Color warna) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan), backgroundColor: warna),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Form Peminjaman")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Buku yang dipilih", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _selectedBookId,
                  hint: const Text("--- Pilih Buku ---"),
                  isExpanded: true,
                  items: _daftarBuku.map((buku) {
                    return DropdownMenuItem<int>(
                      value: buku['id'],
                      child: Text(buku['judul']),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedBookId = val),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),

                const SizedBox(height: 20),

                const Text("Durasi Pinjam (Hari)", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _durasiController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Contoh: 7",
                    prefixIcon: Icon(Icons.timer),
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      _rowInfo("Tanggal Pinjam", _tanggalPinjam.toString().split(' ')[0]),
                      const Divider(),
                      _rowInfo("Tanggal Kembali", _tanggalKembali.toString().split(' ')[0]),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _kirimPengajuan,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text("AJUKAN SEKARANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
    );
  }

  Widget _rowInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
      ],
    );
  }
}