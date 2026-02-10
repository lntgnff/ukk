import 'package:flutter/material.dart';
import '../login_page.dart';
import '../config/colors.dart';
import '../config/theme.dart';
import 'admin_history_peminjaman.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color primaryColor = const Color(0xFF6C63FF);
  final Color bgColor = const Color(0xFFF4F3FD);

  final Map<String, dynamic> adminData = {
    'name': 'Admin Perpustakaan',
    'role': 'Administrator',
    'profileImage': '👤',
  };

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          "Profil Admin",
          style: TextStyle(color: AppColors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Center(
                child: Text(
                  adminData['profileImage'],
                  style: const TextStyle(fontSize: 60),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              adminData['name'],
              style: AppTheme.headingMedium,
            ),
            const SizedBox(height: 8),
            Text(
              adminData['role'],
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 40),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.history_rounded,
                        color: AppColors.primary),
                    title: const Text("History Peminjaman"),
                    subtitle: const Text("Lihat semua peminjaman user"),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminHistoryPeminjaman(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: logout,
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
