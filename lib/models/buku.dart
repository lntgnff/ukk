class Buku {
  final int? id;
  final String judul;
  final String pengarang;
  final int stok;

  Buku({
    this.id,
    required this.judul,
    required this.pengarang,
    required this.stok,
  });

  factory Buku.fromMap(Map<String, dynamic> map) {
    return Buku(
      id: map['id'],
      judul: map['judul'],
      pengarang: map['pengarang'],
      stok: map['stok'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'pengarang': pengarang,
      'stok': stok,
    };
  }
}