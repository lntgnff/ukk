import 'package:ukk_paket4/database/database.dart';
import 'package:ukk_paket4/models/user.dart';

class AuthService {
  Future<void> register({
    required String nis,
    required String nama,
    required String username,
    required String password,
  }) async {
    final db = await DatabaseHelper.instance.database;

    await db.insert('users', {
      'email': username,
      'password': password,
      'is_admin': 0, 
    });
  }

  Future<User?> login(String username, String password) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }
}