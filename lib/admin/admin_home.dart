import 'package:flutter/material.dart';
import '../login_page.dart';
import 'kelola_buku.dart';
import 'kelola_anggota.dart';
import 'transaksi.dart';
import 'bookmark_page.dart';
import 'profile_page.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int currentIndex = 0;

  final Color primaryColor = const Color(0xFF6C63FF);
  final Color bgColor = const Color(0xFFF4F3FD);

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void navigateTo(String page) {
    Widget destination;
    switch (page) {
      case "Kelola Buku":
        destination = const KelolaBuku();
        break;
      case "Kelola Anggota":
        destination = const KelolaAnggota();
        break;
      case "Transaksi":
        destination = const TransaksiAdmin();
        break;
      default:
        return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  void onBottomNavTap(int index) {
    setState(() {
      currentIndex = index;
    });

    Widget destination;
    switch (index) {
      case 0:
        return;
      case 1:
        destination = const BookmarkPage();
        break;
      case 2:
        destination = const ProfilePage();
        break;
      default:
        return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => destination),
    ).then((_) {
      setState(() {
        currentIndex = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            menuCard("📚", "Kelola Buku", () => navigateTo("Kelola Buku")),
            menuCard(
                "👥", "Kelola Anggota", () => navigateTo("Kelola Anggota")),
            menuCard("🔁", "Transaksi", () => navigateTo("Transaksi")),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: primaryColor,
        onTap: onBottomNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark), label: "Bookmark"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget menuCard(String icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
