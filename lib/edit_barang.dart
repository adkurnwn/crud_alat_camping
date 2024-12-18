import 'package:flutter/material.dart';
import 'api_service.dart';
import 'alat_camping.dart';

class EditBarangPage extends StatefulWidget {
  final AlatCamping alatcamping;

  const EditBarangPage({Key? key, required this.alatcamping}) : super(key: key);

  @override
  _EditBarangPageState createState() => _EditBarangPageState();
}

class _EditBarangPageState extends State<EditBarangPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  late Map<String, dynamic> formData;

  final List<String> kategoriList = [
    'Tenda',
    'Bag',
    'Perlengkapan Tidur',
    'Lampu',
    'Alat Masak dan Makan',
    'Wears',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    formData = {
      'kode': widget.alatcamping.kode,
      'nama': widget.alatcamping.nama,
      'merk': widget.alatcamping.merk,
      'stok': widget.alatcamping.stok.toString(),
      'harga': widget.alatcamping.harga.toString(),
      'deskripsi': widget.alatcamping.deskripsi ?? '',
      'kategori': widget.alatcamping.kategori,
    };
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      try {
        setState(() => _isLoading = true);
        //mempersiapkan data yang akan diubah agar dapat dijadiin body request (json)
        final apiData = Map<String, dynamic>.from(formData);
        apiData['stok'] = int.parse(formData['stok'].toString());
        apiData['harga'] = double.parse(formData['harga'].toString());

        final response = await _apiService.updateBarang(widget.alatcamping.id, apiData);
        Navigator.pop(context, true);
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
        title: Text('Edit Barang', style: TextStyle(color: Colors.white)),
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
                      initialValue: formData['kode'],
                      decoration: InputDecoration(
                        labelText: 'Kode',
                        hintText: 'Masukkan kode barang',
                      ),
                      onSaved: (value) => formData['kode'] = value ?? '',
                    ),
                    TextFormField(
                      initialValue: formData['nama'],
                      decoration: InputDecoration(
                        labelText: 'Nama *',
                        hintText: 'Masukkan nama barang',
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Nama harus diisi' : null,
                      onSaved: (value) => formData['nama'] = value ?? '',
                    ),
                    TextFormField(
                      initialValue: formData['merk'],
                      decoration: InputDecoration(
                        labelText: 'Merk *',
                        hintText: 'Masukkan merk barang',
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Merk harus diisi' : null,
                      onSaved: (value) => formData['merk'] = value ?? '',
                    ),
                    TextFormField(
                      initialValue: formData['stok'],
                      decoration: InputDecoration(
                        labelText: 'Stok',
                        hintText: 'Masukkan jumlah stok',
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => formData['stok'] = value ?? '0',
                    ),
                    TextFormField(
                      initialValue: formData['harga'],
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
                      initialValue: formData['deskripsi'],
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
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Simpan Perubahan'),
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
