import 'package:ukk_paket4/database/database.dart';
import 'package:ukk_paket4/models/buku.dart';

class BukuService {
  Future<List<Buku>> getAllBuku() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('buku');

    return result.map((e) => Buku(
      id: e['id'] as int,
      judul: e['judul'].toString(),
      pengarang: e['pengarang'].toString(),
      stok: e['stok'] as int,
    )).toList();
  }

  Future<void> insertBuku(Buku buku) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('buku', buku.toMap());
  }

  Future<void> updateBuku(Buku buku) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'buku',
      buku.toMap(),
      where: 'id = ?',
      whereArgs: [buku.id],
    );
  }

  Future<void> deleteBuku(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'buku',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

 Future<List<Buku>> getBukuTerbaru() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'buku',
      orderBy: 'created_at DESC',
      limit: 5,
    );
    return result.map((e) => Buku.fromMap(e)).toList();
  }

  Future<List<Buku>> getRekomendasi() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'buku',
      where: 'is_rekomendasi = ?',
      whereArgs: [1],
    );
    return result.map((e) => Buku.fromMap(e)).toList();
  }
  
}