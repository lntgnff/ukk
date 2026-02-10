import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('perpustakaan.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

 Future<void> _createDB(Database db, int version) async {
  await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT, -- Tambahkan username agar sinkron dengan query admin
      email TEXT UNIQUE,
      password TEXT,
      is_admin INTEGER DEFAULT 0
    )
  ''');

    await db.execute('''
      CREATE TABLE buku (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        judul TEXT,
        pengarang TEXT,
        stok INTEGER
      )
    ''');

   await db.execute('''
  CREATE TABLE transaksi (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    buku_id INTEGER,
    tanggal_pinjam TEXT,
    tanggal_kembali TEXT,
    status TEXT DEFAULT 'Pending' 
  )
''');

    await db.insert('users', {
      'email': 'admin@gmail.com',
      'password': 'admin123',
      'is_admin': 1,
    });

    print("Database Berhasil Dibuat dan Data Admin Berhasil Ditambahkan");
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}