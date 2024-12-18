//dibuat seprti model agar mudah diakses pada page lain (tidak perlu mendefinisikan ulang)
class AlatCamping {
  final int id;
  final String kode;
  final String nama;
  final String merk;
  final int stok;
  final int harga;
  //diberi tanda "?" karena bisa bernilai null
  final String? deskripsi;
  final String kategori;
  final String? image;

  //konstruktor untuk fetching data dari json dari API dengan banyak tipedata (dynamic)
  AlatCamping.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        kode = json['kode'],
        nama = json['nama'],
        merk = json['merk'],
        stok = json['stok'],
        harga = json['harga'],
        deskripsi = json['deskripsi'],
        kategori = json['kategori'],
        image = json['image'];
}