

class PeminjamanService {
  static final PeminjamanService _instance = PeminjamanService._internal();

  factory PeminjamanService() {
    return _instance;
  }

  PeminjamanService._internal();

  final List<Map<String, dynamic>> _peminjamanList = [
    {
      'id': 1,
      'judul': 'Hujan',
      'penulis': 'Tere Liye',
      'tanggalPinjam': DateTime.now().subtract(const Duration(days: 15)),
      'tanggalKembaliSeharusnya':
          DateTime.now().subtract(const Duration(days: 8)),
      'status': 'Dipinjam',
    },
    {
      'id': 2,
      'judul': 'Bumi',
      'penulis': 'Tere Liye',
      'tanggalPinjam': DateTime.now().subtract(const Duration(days: 5)),
      'tanggalKembaliSeharusnya': DateTime.now().add(const Duration(days: 2)),
      'status': 'Dipinjam',
    },
    {
      'id': 3,
      'judul': 'Laskar Pelangi',
      'penulis': 'Andrea Hirata',
      'tanggalPinjam': DateTime.now().subtract(const Duration(days: 30)),
      'tanggalKembaliSeharusnya':
          DateTime.now().subtract(const Duration(days: 23)),
      'tanggalKembaliAktual': DateTime.now().subtract(const Duration(days: 20)),
      'status': 'Dikembalikan',
    },
    {
      'id': 4,
      'judul': 'Rinjani',
      'penulis': 'Nabila N Haris',
      'tanggalPinjam': DateTime.now().subtract(const Duration(days: 20)),
      'tanggalKembaliSeharusnya':
          DateTime.now().subtract(const Duration(days: 13)),
      'status': 'Dipinjam',
    },
  ];

  List<Map<String, dynamic>> getPeminjamanList() {
    return _peminjamanList;
  }

  void tambahPeminjaman(Map<String, dynamic> peminjaman) {
    final newId = _peminjamanList.isEmpty
        ? 1
        : (_peminjamanList
                .map((e) => e['id'] as int)
                .reduce((a, b) => a > b ? a : b) +
            1);

    peminjaman['id'] = newId;
    _peminjamanList.add(peminjaman);
  }

  void updatePeminjaman(int id, Map<String, dynamic> updatedData) {
    final index = _peminjamanList.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      _peminjamanList[index].addAll(updatedData);
    }
  }

  Map<String, dynamic>? getPeminjamanById(int id) {
    try {
      return _peminjamanList.firstWhere((item) => item['id'] == id);
    } catch (e) {
      return null;
    }
  }
}
