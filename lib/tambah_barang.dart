import 'package:flutter/material.dart';
import 'api_service.dart';

class TambahBarangPage extends StatefulWidget {
  @override
  _TambahBarangPageState createState() => _TambahBarangPageState();
}

class _TambahBarangPageState extends State<TambahBarangPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  final Map<String, dynamic> formData = {
    'kode': '',
    'nama': '',
    'merk': '',
    'stok': '0',
    'harga': '',
    'berat': '',
    'deskripsi': '',
    'kategori': 'Lainnya',
    'kapasitas': '',
  };

  final List<String> kategoriList = [
    'Tenda',
    'Bag',
    'Perlengkapan Tidur',
    'Lampu',
    'Alat Masak dan Makan',
    'Wears',
    'Lainnya',
  ];

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      try {
        setState(() => _isLoading = true);
        
        //ubah tipedata ke numeric agar bisa dijadiin body request
        formData['stok'] = int.tryParse(formData['stok']) ?? 0;
        formData['harga'] = double.parse(formData['harga']);
        if (formData['berat'].isNotEmpty) {
          formData['berat'] = double.parse(formData['berat']);
        }
        if (formData['kapasitas'].isNotEmpty) {
          formData['kapasitas'] = int.parse(formData['kapasitas']);
        }

        final response = await _apiService.createBarang(formData);
        Navigator.pop(context, true); // Return true to indicate success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Barang', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Kode',
                        hintText: 'Masukkan kode barang',
                      ),
                      onSaved: (value) => formData['kode'] = value ?? '',
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nama *',
                        hintText: 'Masukkan nama barang',
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Nama harus diisi' : null,
                      onSaved: (value) => formData['nama'] = value ?? '',
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Merk *',
                        hintText: 'Masukkan merk barang',
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Merk harus diisi' : null,
                      onSaved: (value) => formData['merk'] = value ?? '',
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Stok',
                        hintText: 'Masukkan jumlah stok',
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => formData['stok'] = value ?? '0',
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Harga *',
                        hintText: 'Masukkan harga barang',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Harga harus diisi';
                        if (double.tryParse(value!) == null)
                          return 'Harga harus berupa angka';
                        return null;
                      },
                      onSaved: (value) => formData['harga'] = value ?? '',
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Berat (kg)',
                        hintText: 'Masukkan berat barang',
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => formData['berat'] = value ?? '',
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Deskripsi *',
                        hintText: 'Masukkan deskripsi barang',
                      ),
                      maxLines: 3,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Deskripsi harus diisi' : null,
                      onSaved: (value) => formData['deskripsi'] = value ?? '',
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Kategori *'),
                      value: formData['kategori'],
                      items: kategoriList
                          .map((String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => formData['kategori'] = value);
                      },
                      validator: (value) =>
                          value == null ? 'Pilih kategori' : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Kapasitas',
                        hintText: 'Masukkan kapasitas barang',
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => formData['kapasitas'] = value ?? '',
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Simpan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
