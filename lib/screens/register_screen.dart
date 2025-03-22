import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Uint8List? _imageBytes;
  String? _imageName;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = picked.name;
      });
    }
  }

  Future<void> _register(BuildContext context) async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua data wajib diisi, termasuk foto!")),
      );
      return;
    }

    if (password != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password tidak cocok!")),
      );
      return;
    }

    try {
      // 1. Register ke Supabase Auth
      final authRes = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final userId = authRes.user?.id;
      if (userId == null) throw Exception("Gagal registrasi.");

      // 2. Upload gambar ke Supabase Storage
      final fileExt = extension(_imageName ?? 'image.png');
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExt';

      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary('public/$fileName', _imageBytes!);

      final imageUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl('public/$fileName');

      // 3. Simpan data user ke tabel profiles
      await Supabase.instance.client.from('profiles').insert({
        'id': userId,
        'name': name,
        'email': email,
        'avatar_url': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi berhasil!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarPreview = _imageBytes != null
        ? CircleAvatar(
      radius: 50,
      backgroundImage: MemoryImage(_imageBytes!),
    )
        : const CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey,
      child: Icon(Icons.camera_alt, size: 40),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(onTap: _pickImage, child: avatarPreview),
            const SizedBox(height: 20),
            _buildTextField(_nameController, "Full Name"),
            _buildTextField(_emailController, "Email"),
            _buildTextField(_passwordController, "Password", obscure: true),
            _buildTextField(_confirmPasswordController, "Confirmation Password", obscure: true),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _register(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Register", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.green[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),
          labelText: label,
        ),
      ),
    );
  }
}