import 'package:flutter/material.dart';
import 'alat_camping.dart';
import 'api_service.dart';

//menggunakan stateful widget karena data yang ditampilkan berubah ubah
class DetailPage extends StatefulWidget {
  final int itemId;

  //konstruktor untuk mengaitkan "id" dari alat camping yang dipilih
  //key digunakan untuk mengidentifikasi widget
  const DetailPage({Key? key, required this.itemId}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  //menggunakan apiservice untuk mengambil data dari API
  final ApiService _apiService = ApiService();
  bool isLoading = true;
  AlatCamping? alatcamping;

  @override
  void initState() {
    super.initState();
    _loadDetailBarang();
  }

  Future<void> _loadDetailBarang() async {
    try {
      final data = await _apiService.getDetailBarang(widget.itemId);
      setState(() {
        alatcamping = AlatCamping.fromJson(data);
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Barang',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : alatcamping == null
              ? Center(child: Text('Data tidak ditemukan'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 300,
                        child: Image.network(
                          'http://8.215.199.112/storage/${alatcamping!.image}',
                          fit: BoxFit.cover,
                          headers: {
                            'X-API-Key': ApiService.apiKey,
                            'Accept': 'image/*, application/octet-stream',
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.teal,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading image: $error');
                            return Container(
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_not_supported,
                                      size: 40, color: Colors.grey[400]),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Gambar tidak tersedia',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alatcamping!.nama,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Rp ${alatcamping!.harga}',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            _buildInfoRow('Kode', alatcamping!.kode),
                            _buildInfoRow('Merk', alatcamping!.merk),
                            _buildInfoRow('Stok', alatcamping!.stok.toString()),
                            _buildInfoRow('Kategori', alatcamping!.kategori),
                            if (alatcamping!.deskripsi != null) ...[
                              SizedBox(height: 16),
                              Text(
                                'Deskripsi:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                alatcamping!.deskripsi!,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
