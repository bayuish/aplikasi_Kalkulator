import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/custom_bottom_navbar.dart';
import 'homepage_screen.dart'; // tambahkan ini jika belum

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool _isAllowed = false;
  bool _isFreeUser = false;
  bool _checkedRole = false;
  bool _loading = false;
  String currentPath = '/';
  List<Map<String, dynamic>> uploadedItems = [];
  final TextEditingController _folderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkUserRoleAndFetch();
  }

  Future<void> _checkUserRoleAndFetch() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final profile = await Supabase.instance.client
        .from('profiles')
        .select('user_type')
        .eq('id', user.id)
        .maybeSingle();

    final role = profile?['user_type'];

    if (role == 'Admin' || role == 'Premium User') {
      setState(() {
        _isAllowed = true;
      });
      await _fetchItems(user.id);
    } else {
      setState(() {
        _isFreeUser = true;
      });
    }

    setState(() {
      _checkedRole = true;
    });
  }

  Future<void> _fetchItems(String userId) async {
    final items = await Supabase.instance.client
        .from('file_metadata')
        .select()
        .eq('user_id', userId)
        .eq('path', currentPath)
        .order('is_folder', ascending: false)
        .order('uploaded_at', ascending: false);

    setState(() {
      uploadedItems = List<Map<String, dynamic>>.from(items);
    });
  }

  void _uploadFileWeb() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final input = html.FileUploadInputElement()..accept = '*/*';
    input.click();

    input.onChange.listen((event) async {
      final file = input.files?.first;
      if (file == null) return;

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      reader.onLoadEnd.listen((event) async {
        final bytes = reader.result as Uint8List;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filename = '$currentPath$timestamp-${file.name}';

        try {
          setState(() => _loading = true);

          await Supabase.instance.client.storage
              .from('uploads')
              .uploadBinary(filename, bytes);

          final publicUrl = Supabase.instance.client.storage
              .from('uploads')
              .getPublicUrl(filename);

          await Supabase.instance.client.from('file_metadata').insert({
            'user_id': user.id,
            'file_name': file.name,
            'file_path': filename,
            'uploaded_at': DateTime.now().toIso8601String(),
            'is_folder': false,
            'path': currentPath,
          });

          await _fetchItems(user.id);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload berhasil: $publicUrl')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal upload: $e')),
          );
        } finally {
          setState(() => _loading = false);
        }
      });
    });
  }

  Future<void> _createFolder() async {
    final folderName = _folderController.text.trim();
    if (folderName.isEmpty) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await Supabase.instance.client.from('file_metadata').insert({
      'user_id': user.id,
      'file_name': folderName,
      'is_folder': true,
      'path': currentPath,
      'uploaded_at': DateTime.now().toIso8601String(),
    });

    _folderController.clear();
    await _fetchItems(user.id);
  }

  Future<void> _confirmDelete(BuildContext context, Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus "${item['file_name']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteItem(item);
    }
  }

  Future<void> _deleteItem(Map<String, dynamic> item) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final isFolder = item['is_folder'] == true;
    final filePath = item['file_path'];

    if (!isFolder && filePath != null) {
      await Supabase.instance.client.storage.from('uploads').remove([filePath]);
    }

    await Supabase.instance.client
        .from('file_metadata')
        .delete()
        .eq('id', item['id']);

    await _fetchItems(user.id);
  }

  void _goBackToParent() {
    if (currentPath == '/') return;
    final parent = currentPath.endsWith('/') ? currentPath.substring(0, currentPath.length - 1) : currentPath;
    final parts = parent.split('/')..removeLast();
    setState(() {
      currentPath = parts.join('/') + (parts.length > 1 ? '/' : '/');
    });
    _checkUserRoleAndFetch();
  }

  @override
  Widget build(BuildContext context) {
    if (!_checkedRole) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isFreeUser) {
      // Tampilkan pesan sesaat sebelum redirect
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Fitur Upload hanya tersedia untuk Premium User Silahkan Upgrade Plane"),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomepageScreen()),
        );
      });

      // Sementara tampilkan loading kecil
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final folders = uploadedItems.where((e) => e['is_folder'] == true).toList();
    final files = uploadedItems.where((e) => e['is_folder'] != true).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Upload File - Folder View')),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _folderController,
                    decoration: const InputDecoration(labelText: 'Buat Folder Baru'),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _createFolder,
                  icon: const Icon(Icons.folder),
                  label: const Text('Tambah Folder'),
                ),
                const SizedBox(width: 10),
                if (currentPath != '/')
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Kembali ke folder utama',
                    onPressed: _goBackToParent,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Path saat ini: $currentPath'),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _uploadFileWeb,
                icon: const Icon(Icons.upload_file),
                label: const Text('Pilih & Upload File'),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  if (folders.isNotEmpty) ...[
                    const Text("\n📁 Folder:", style: TextStyle(fontWeight: FontWeight.bold)),
                    ...folders.map((folder) => ListTile(
                      leading: const Icon(Icons.folder, color: Colors.amber),
                      title: Text(folder['file_name']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, folder),
                      ),
                      onTap: () {
                        setState(() {
                          currentPath = '$currentPath${folder['file_name']}/';
                        });
                        _checkUserRoleAndFetch();
                      },
                    )),
                  ],
                  const Text("\n📄 File yang telah diupload:", style: TextStyle(fontWeight: FontWeight.bold)),
                  ...files.map((file) {
                    final url = Supabase.instance.client.storage
                        .from('uploads')
                        .getPublicUrl(file['file_path']);
                    return ListTile(
                      leading: const Icon(Icons.insert_drive_file),
                      title: Text(file['file_name']),
                      subtitle: Text("Uploaded at: ${file['uploaded_at']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.open_in_new),
                            onPressed: () => html.window.open(url, '_blank'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(context, file),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}