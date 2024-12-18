//dibuat file terpisah agar mudah diakses pada page lain (tidak perlu mendefinisikan ulang)
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  //base url untuk alamat endpoint api
  static const String baseUrl = 'http://8.215.199.112/api';
  //apiKey untuk autentikasi (dibuat sendiri dari project backend yang sudah deploy)
  static const String apiKey = 'c2f96c6025b76266d858b997d4eadabfc3b719b769757efe005ec25f2887ec9e';
  static const String imageUrl = 'http://8.215.199.112/storage/';

  //read data barang alat camping
  Future<Map<String, dynamic>> getBarang({int page = 1}) async {
    try {
      //menggunakan header get (karena api requestnya get / read)
      final response = await http.get(
        Uri.parse('$baseUrl/barang?page=$page'),
        headers: {'X-API-Key': apiKey},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        throw Exception('Error mengambil data barang');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  //read detail barang alat camping
  Future<Map<String, dynamic>> getDetailBarang(int id) async {
    try {
      //menggunakan header get (karena api requestnya get / read)
      final response = await http.get(
        Uri.parse('$baseUrl/barang/$id'),
        headers: {'X-API-Key': apiKey},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error mengambil data barang');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  //create data barang alat camping
  Future<Map<String, dynamic>> createBarang(Map<String, dynamic> data) async {
    try {
      //menggunakan header post (karena api requestnya post / create)
      final response = await http.post(
        Uri.parse('$baseUrl/barang'),
        headers: {
          'X-API-Key': apiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error membuat data barang');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  //update data barang alat camping
  Future<Map<String, dynamic>> updateBarang(int id, Map<String, dynamic> data) async {
    try {
      //menggunakan header put (karena api requestnya put / update)
      final response = await http.put(
        Uri.parse('$baseUrl/barang/$id'),
        headers: {
          'X-API-Key': apiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error mengupdate data barang');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  //hapus data barang alat camping
  Future<void> hapusBarang(int id) async {
    try {
      //menggunakan header delete (karena api requestnya delete)
      final response = await http.delete(
        Uri.parse('$baseUrl/barang/$id'),
        headers: {'X-API-Key': apiKey},
      );

      //status 204 artinya tidak ada respon (null)
      if (response.statusCode != 204) {
        String errorMessage;
        try {
          final error = json.decode(response.body);
          errorMessage = error['message'] ?? 'Error menghapus data';
        } catch (e) {
          errorMessage = 'Error menghapus data';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  //method untuk mengambil url gambar
  static String? getImageUrl(String? imagePath) {
    if (imagePath == null) return null;
    return 'http://8.215.199.112/storage/$imagePath';
  }

  //fix apabila url image null (alat camping tidak punya gambar)
  static Map<String, String> getImageHeaders() {
    return {
      'X-API-Key': apiKey,
      'Accept': 'image/*, application/octet-stream',
    };
  }

  //method tambahan untuk mencari barang (dengan query)
  Future<Map<String, dynamic>> cariBarang(String query, {int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/barang?search=$query&page=$page'),
        headers: {'X-API-Key': apiKey},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        throw Exception('Failed to search alatcampings');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}