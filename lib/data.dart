List<Map<String, dynamic>> books = [
  {
    "id": 1,
    "judul": "Laskar Pelangi",
    "gambar": "laskar_pelangi.jpeg",
    "status": "Tersedia"
  },
  {"id": 2, 
  "judul": "Bumi", 
  "gambar": "bumi.jpg", 
  "status": "Dipinjam"
  },
  {"id": 3, 
  "judul": "Hujan", 
  "gambar": "Hujan.jpg", 
  "status": "Tersedia"
  },
  {
    "id": 4,
    "judul": "Kita Pergi Hari Ini",
    "gambar": "kita_pergi_hari_ini.jpg",
    "status": "Dipinjam"
  },
  {"id": 5, 
  "judul": "rinjani",
   "gambar": "rinjani.jpg", 
   "status": "Tersedia"
   },
];

List<Map<String, String>> users = [
  {
    "id": "1",
    "email": "user@gmail.com",
    "password": "123456",
  }
];

List<Map<String, dynamic>> transactions = [
  {
    "id": 1,
    "userId": "1",
    "userName": "user@gmail.com",
    "bookId": 1,
    "bookTitle": "Laskar Pelangi",
    "tanggalPinjam": "2024-01-15",
    "tanggalKembali": "2024-12-28",
    "status": "Dipinjam",
  }
];
