import 'dart:io' as io;
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/custom_bottom_navbar.dart';

class StudentDataEntryScreen extends StatefulWidget {
  const StudentDataEntryScreen({super.key});

  @override
  State<StudentDataEntryScreen> createState() => _StudentDataEntryScreenState();
}

class _StudentDataEntryScreenState extends State<StudentDataEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nimController = TextEditingController();
  final _nilaiController = TextEditingController();

  String? _selectedKelas;
  String? _selectedMatkul;
  final List<String> _kelasOptions = ['TT-45-01', 'TT-45-02', 'TT-45-03', 'TT-45-04', 'TT-45-05'];
  final List<String> _matkulOptions = ['Mobile App', 'Python'];

  bool _showSuccess = false;
  bool _isPremium = false;
  List<Map<String, dynamic>> _studentList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final profile = await Supabase.instance.client
        .from('profiles')
        .select('user_type')
        .eq('id', user.id)
        .maybeSingle();

    final role = profile?['user_type'];
    if (role == 'Premium User' || role == 'Admin') {
      setState(() => _isPremium = true);
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate() || _selectedKelas == null || _selectedMatkul == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data termasuk kelas dan mata kuliah!')),
      );
      return;
    }

    final nim = int.tryParse(_nimController.text.trim());
    if (nim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NIM tidak valid!')),
      );
      return;
    }

    final existing = await Supabase.instance.client
        .from('students')
        .select()
        .eq('nim', nim)
        .maybeSingle();

    if (existing != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data dengan NIM tersebut sudah ada!')),
      );
      return;
    }

    try {
      await Supabase.instance.client.from('students').insert({
        'nama': _namaController.text.trim(),
        'nim': nim,
        'kelas': _selectedKelas,
        'mata_kuliah': _selectedMatkul,
        'nilai': int.parse(_nilaiController.text.trim()),
      });

      setState(() => _showSuccess = true);
      await Future.delayed(const Duration(seconds: 2));

      _formKey.currentState!.reset();
      _namaController.clear();
      _nimController.clear();
      _nilaiController.clear();
      setState(() {
        _selectedMatkul = null;
        _selectedKelas = null;
        _showSuccess = false;
      });

      _fetchData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan data: ${e.toString()}')),
      );
    }
  }

  Future<void> _fetchData() async {
    final data = await Supabase.instance.client.from('students').select();
    setState(() {
      _studentList = List<Map<String, dynamic>>.from(data);
    });
  }

  Future<void> _deleteStudent(int nim) async {
    try {
      await Supabase.instance.client.from('students').delete().eq('nim', nim);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil dihapus!')),
      );
      _fetchData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus data: ${e.toString()}')),
      );
    }
  }

  void _editStudent(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (_) {
        final editNilaiController = TextEditingController(text: student['nilai'].toString());
        return AlertDialog(
          title: const Text("Edit / Hapus Data"),
          content: TextFormField(
            controller: editNilaiController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Nilai Baru"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            if (_isPremium)
              TextButton(
                onPressed: () async {
                  await Supabase.instance.client
                      .from('students')
                      .delete()
                      .eq('nim', student['nim']);
                  Navigator.pop(context);
                  await _fetchData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Data berhasil dihapus!")),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Hapus"),
              ),
            ElevatedButton(
              onPressed: () async {
                final updatedNilai = int.tryParse(editNilaiController.text);
                if (updatedNilai != null) {
                  await Supabase.instance.client
                      .from('students')
                      .update({'nilai': updatedNilai})
                      .eq('nim', student['nim']);
                  Navigator.pop(context);
                  await _fetchData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Data diperbarui.")),
                  );
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportCSV() async {
    List<List<dynamic>> rows = [
      ['Nama', 'NIM', 'Kelas', 'Mata Kuliah', 'Nilai'],
      ..._studentList.map((s) => [s['nama'], s['nim'], s['kelas'], s['mata_kuliah'], s['nilai']]),
    ];

    String csvData = const ListToCsvConverter().convert(rows);

    if (kIsWeb) {
      final bytes = html.Blob([csvData]);
      final url = html.Url.createObjectUrlFromBlob(bytes);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'data_mahasiswa.csv')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/data_mahasiswa.csv';
      final file = io.File(path);
      await file.writeAsString(csvData);
      await Share.shareXFiles([XFile(path)], text: 'Export Data Mahasiswa');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F0FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF256DFF),
        title: const Text("Entry Data Mahasiswa"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: "Export CSV",
            onPressed: _studentList.isEmpty ? null : _exportCSV,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_showSuccess)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: AnimatedOpacity(
                  opacity: 1,
                  duration: Duration(milliseconds: 500),
                  child: Icon(Icons.check_circle, color: Colors.green, size: 48),
                ),
              ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_namaController, 'Nama'),
                  _buildTextField(_nimController, 'NIM', keyboardType: TextInputType.number),
                  _buildDropdown(_kelasOptions, _selectedKelas, 'Kelas', (value) {
                    setState(() {
                      _selectedKelas = value;
                    });
                  }),
                  _buildDropdown(_matkulOptions, _selectedMatkul, 'Mata Kuliah', (value) {
                    setState(() {
                      _selectedMatkul = value;
                    });
                  }),
                  _buildTextField(_nilaiController, 'Nilai', keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF256DFF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Simpan", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(thickness: 1),
            const Text("Daftar Mahasiswa", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _studentList.isEmpty
                ? const Text("Belum ada data ditemukan.")
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _studentList.length,
              itemBuilder: (context, index) {
                final student = _studentList[index];
                return Card(
                  color: Colors.white,
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.school, color: Colors.blueAccent),
                    title: Text("${student['nama']} (${student['nim']})"),
                    subtitle: Text("Kelas: ${student['kelas']} • ${student['mata_kuliah']}"),
                    trailing: Text("Nilai: ${student['nilai']}"),
                    onTap: () => _editStudent(student),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> options, String? selectedValue, String label, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        items: options.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) => value == null ? 'Wajib dipilih' : null,
      ),
    );
  }
}