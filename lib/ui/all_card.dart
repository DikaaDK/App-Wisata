import 'package:flutter/material.dart';
import 'package:appwisata/helpers/api.dart';
import 'package:appwisata/ui/detail_card.dart';
import 'package:appwisata/ui/wisata_form_edit.dart';
import 'package:appwisata/ui/home_page.dart';

class AllCardPage extends StatefulWidget {
  const AllCardPage({super.key});

  @override
  State<AllCardPage> createState() => _AllCardPageState();
}

class _AllCardPageState extends State<AllCardPage> {
  List<dynamic> destinations = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchDestinations();
  }

  Future<void> fetchDestinations() async {
    try {
      final api = Api();
      final result = await api.get(Uri.parse('${Api.baseUrl}/wisata'));

      if (!mounted) return;

      final List<dynamic> items;
      if (result is List) {
        items = result;
      } else if (result is Map<String, dynamic>) {
        final candidate = result['data'] ?? result['wisata'];
        if (candidate is List) {
          items = candidate;
        } else {
          throw Exception('Format respons tidak sesuai');
        }
      } else {
        throw Exception('Format respons tidak dikenal');
      }

      setState(() {
        destinations = items;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Gagal memuat data: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _deleteDestination(Map dest) async {
    // Konfirmasi sebelum menghapus
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus "${dest['nama_wisata'] ?? dest['nama'] ?? 'destinasi ini'}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final api = Api();
      final id = dest['id'] ?? dest['id_wisata'];
      if (id == null) {
        throw Exception('ID destinasi tidak ditemukan');
      }

      await api.delete(Uri.parse('${Api.baseUrl}/wisata/$id'));
      
      if (!mounted) return;
      
      // Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Destinasi berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh data
      fetchDestinations();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus destinasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Destinasi'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : destinations.isEmpty
          ? const Center(child: Text('Belum ada destinasi wisata'))
          : RefreshIndicator(
              onRefresh: fetchDestinations,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  final dest = destinations[index] as Map? ?? {};
                  final String name =
                      (dest['nama_wisata'] ?? dest['nama'] ?? 'Tanpa Nama')
                          .toString();
                  final String desc =
                      (dest['deskripsi'] ?? dest['deskripsi_wisata'] ?? '')
                          .toString();
                  final String imageUrl =
                      (dest['gambar'] ?? dest['image'] ?? '').toString();

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 180,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(Icons.broken_image, size: 40),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                height: 180,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                  ),
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                desc,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailCard(
                                            name: name,
                                            image: imageUrl,
                                            desc: desc,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Lihat Detail',
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => WisataFormEdit(
                                                data: Map<String, dynamic>.from(
                                                  dest,
                                                ),
                                              ),
                                            ),
                                          );

                                          if (result == true) {
                                            fetchDestinations();
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.orange,
                                        ),
                                        label: const Text(
                                          'Edit',
                                          style: TextStyle(color: Colors.orange),
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () => _deleteDestination(dest),
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        label: const Text(
                                          'Hapus',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
