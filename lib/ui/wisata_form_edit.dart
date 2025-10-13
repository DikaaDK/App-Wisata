import 'package:flutter/material.dart';
import 'package:appwisata/helpers/api.dart';

class WisataFormEdit extends StatefulWidget {
  final Map<String, dynamic> data;
  
  const WisataFormEdit({super.key, required this.data});

  @override
  State<WisataFormEdit> createState() => _WisataFormEditState();
}

class _WisataFormEditState extends State<WisataFormEdit> {
  final _formKey = GlobalKey<FormState>();
  final api = Api();
  
  late TextEditingController _namaWisataController;
  late TextEditingController _lokasiController;
  late TextEditingController _deskripsiController;
  late TextEditingController _gambarController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaWisataController = TextEditingController(
      text: widget.data['nama_wisata']?.toString() ?? widget.data['nama']?.toString() ?? ''
    );
    _lokasiController = TextEditingController(
      text: widget.data['lokasi']?.toString() ?? ''
    );
    _deskripsiController = TextEditingController(
      text: widget.data['deskripsi']?.toString() ?? widget.data['deskripsi_wisata']?.toString() ?? ''
    );
    _gambarController = TextEditingController(
      text: widget.data['gambar']?.toString() ?? widget.data['image']?.toString() ?? ''
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Destinasi Wisata'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nama Wisata',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _namaWisataController,
                decoration: InputDecoration(
                  hintText: 'Nama Wisata',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama wisata wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const Text(
                'Lokasi Wisata',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _lokasiController,
                decoration: InputDecoration(
                  hintText: 'Lokasi Wisata',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lokasi wisata wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const Text(
                'URL Gambar Wisata',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _gambarController,
                decoration: InputDecoration(
                  hintText: 'URL gambar',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'URL gambar wajib diisi';
                  }
                  if (!value.startsWith('http')) {
                    return 'URL tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const Text(
                'Deskripsi Wisata',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tulis deskripsi menarik destinasi ini...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateDestination,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Update',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateDestination() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final updatedData = {
        'nama_wisata': _namaWisataController.text,
        'lokasi': _lokasiController.text,
        'gambar': _gambarController.text,
        'deskripsi': _deskripsiController.text,
      };

      try {
        final id = widget.data['id']?.toString() ?? '';
        if (id.isNotEmpty) {
          await api.put('wisata/$id', updatedData);
        } else {
          throw Exception('ID destinasi tidak ditemukan');
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil diupdate'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengupdate data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _namaWisataController.dispose();
    _lokasiController.dispose();
    _deskripsiController.dispose();
    _gambarController.dispose();
    super.dispose();
  }
}