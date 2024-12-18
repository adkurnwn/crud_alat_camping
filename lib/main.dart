import 'package:crud_alat_camping/detail.dart';
import 'package:crud_alat_camping/tambah_barang.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'alat_camping.dart';
import 'edit_barang.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NavigationExample(),
    );
  }
}

class NavigationExample extends StatefulWidget {
  NavigationExample({super.key});
  @override
  State<StatefulWidget> createState() {
    return NavigationExampleState();
  }
}

class NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;
  final ApiService _apiService = ApiService();
  List<AlatCamping> alatcampings = [];
  bool isLoading = true;
  int currentPage = 1;
  int lastPage = 1;

  List<AlatCamping> searchResults = [];
  bool isSearching = false;
  int searchPage = 1;
  int searchLastPage = 1;

  @override
  void initState() {
    super.initState();
    _loadBarang();
  }

  Future<void> _loadBarang([int? page]) async {
    try {
      setState(() => isLoading = true);
      final response = await _apiService.getBarang(page: page ?? currentPage);
      setState(() {
        alatcampings = (response['data'] as List)
            .map((item) => AlatCamping.fromJson(item))
            .toList();
        currentPage = response['current_page'];
        lastPage = response['last_page'];
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }


  Future<void> _performSearch(String query) async {
    try {
      setState(() => isSearching = true);
      final response = await _apiService.cariBarang(query);
      setState(() {
        searchResults = (response['data'] as List)
            .map((item) => AlatCamping.fromJson(item))
            .toList();
        searchPage = response['current_page'];
        searchLastPage = response['last_page'];
        isSearching = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => isSearching = false);
    }
  }


  Future<void> _hapusBarang(int id) async {
    try {
      setState(() => isLoading = true);
      await _apiService.hapusBarang(id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Barang berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
      
      _loadBarang();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildPaginationControls() {
    //untuk next dan previous page (response api ada pagination nya)
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: currentPage > 1
              ? () => _loadBarang(currentPage - 1)
              : null,
        ),
        Text('Page $currentPage of $lastPage'),
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed: currentPage < lastPage
              ? () => _loadBarang(currentPage + 1)
              : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Campigo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 2,
      ),

      //navigation bar 3 buah
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          if (currentPageIndex == index) {
            if (index == 0) {
              _loadBarang();
            } else if (index == 1) {
              setState(() {
                searchResults = [];
                isSearching = false;
              });
            } else if (index == 2) {
              _loadBarang();
            }
          }
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        indicatorColor: Colors.teal,
        destinations: <Widget>[
          NavigationDestination(
            icon: Icon(Icons.hiking_outlined),
            label: 'Barang',
            selectedIcon: Icon(Icons.hiking),
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            label: 'Cari',
            selectedIcon: Icon(Icons.search),
          ),
          NavigationDestination(
            icon: Icon(Icons.create),
            label: 'CRUD',
            selectedIcon: Icon(Icons.create_outlined),
          ),
        ],
      ),


      body: <Widget>[
        //page 1 barang
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.65,
                      ),
                      delegate: SliverChildListDelegate(
                        alatcampings.map((alatcamping) {
                          return GestureDetector(
                            //arahkan ke detail barang ketika card ditekan (ngambil id barang)
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPage(itemId: alatcamping.id),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(4)),
                                      child: Container(
                                        width: double.infinity,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                        ),
                                        child: Image.network(
                                          //ambil gambar pakai imageurl (dari apiservice) dan atribut "image"
                                          '${ApiService.imageUrl}${alatcamping.image}',
                                          fit: BoxFit.cover,
                                          //header agar hanya mengambil file gambar (mencegah error)
                                          headers: {
                                            'X-API-Key': ApiService.apiKey,
                                            'Accept':
                                                'image/*, application/octet-stream',
                                          },
                                          cacheWidth: 300,
                                          loadingBuilder:
                                              (context, child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                                color: Colors.teal,
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            print('Error memuat gambar: $error');
                                            return Container(
                                              color: Colors.grey[200],
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.image_not_supported,
                                                      size: 40,
                                                      color: Colors.grey[400]),
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
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          alatcamping.nama,
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Rp ${alatcamping.harga}',
                                          style: TextStyle(color: Colors.teal),
                                        ),
                                        Text(alatcamping.merk),
                                        Text(
                                          alatcamping.kategori,
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: _buildPaginationControls(),
                      ),
                    ),
                  ],
                ),
        ),

        //page 2 cari
        Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari alat camping...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(color: Colors.teal),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(color: Colors.teal, width: 2.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    if (value.length >= 3) {
                      _performSearch(value);
                    }
                  },
                ),
              ),
              Expanded(
                child: isSearching
                    ? Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        padding: EdgeInsets.all(8.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.65,
                        ),
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final alatcamping = searchResults[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPage(itemId: alatcamping.id),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(4)),
                                      child: Image.network(
                                        '${ApiService.imageUrl}${alatcamping.image}',
                                        fit: BoxFit.cover,
                                        headers: {
                                          'X-API-Key': ApiService.apiKey,
                                          'Accept': 'image/*, application/octet-stream',
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          alatcamping.nama,
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Rp ${alatcamping.harga}',
                                          style: TextStyle(color: Colors.teal),
                                        ),
                                        Text(alatcamping.merk),
                                        Text(
                                          alatcamping.kategori,
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),

        //page 3 crud
        Container(
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: EdgeInsets.all(8.0),
                        children: [
                          ...alatcampings.map((alatcamping) {
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(8),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: alatcamping.image != null
                                      ? Image.network(
                                          ApiService.getImageUrl(alatcamping.image)!,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          headers: ApiService.getImageHeaders(),
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.grey[200],
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey[400],
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[200],
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                ),
                                title: Text(
                                  alatcamping.nama,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ID: ${alatcamping.id}'),
                                    Text('Merk: ${alatcamping.merk}'),
                                    Text('Stok: ${alatcamping.stok}'),
                                    Text(
                                      'Rp ${alatcamping.harga}',
                                      style: TextStyle(
                                        color: Colors.teal,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  icon: Icon(Icons.more_vert),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: ListTile(
                                        leading: Icon(Icons.edit),
                                        title: Text('Edit'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      value: 'edit',
                                    ),
                                    PopupMenuItem(
                                      child: ListTile(
                                        leading: Icon(Icons.delete),
                                        title: Text('Delete'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      value: 'delete',
                                    ),
                                  ],
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditBarangPage(
                                            alatcamping: alatcamping,
                                          ),
                                        ),
                                      ).then((value) {
                                        if (value == true) {
                                          _loadBarang();
                                        }
                                      });
                                    } else if (value == 'delete') {
                                      // Show confirmation dialog
                                      final shouldDelete = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Konfirmasi Hapus'),
                                          content: Text('Apakah Anda yakin ingin menghapus ${alatcamping.nama}?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: Text('Hapus', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (shouldDelete == true) {
                                        await _hapusBarang(alatcamping.id);
                                      }
                                    }
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.chevron_left),
                                  onPressed: currentPage > 1
                                      ? () => _loadBarang(currentPage - 1)
                                      : null,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'Halaman $currentPage dari $lastPage',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.chevron_right),
                                  onPressed: currentPage < lastPage
                                      ? () => _loadBarang(currentPage + 1)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TambahBarangPage()),
                    ).then((value) {
                      if (value == true) {
                        _loadBarang(); //reload halaman setelah nambah barang
                      }
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Tambah Barang', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ][currentPageIndex],
    );
  }
}
