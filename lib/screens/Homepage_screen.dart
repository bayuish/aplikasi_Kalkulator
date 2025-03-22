import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/custom_bottom_navbar.dart';

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({super.key});

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  String? avatarUrl;
  String? userName;
  int selectedIndex = 0;

  final List<Map<String, String>> products = [
    {
      'image': 'assets/dual_sense.png',
      'title': 'Smart Kalkulator',
      'subtitle': 'Kalkulator Standar & Ilmiah modern',
    },
    {
      'image': 'assets/compu.png',
      'title': 'Data Entry',
      'subtitle': 'Input & kelola data mahasiswa',
    },
    {
      'image': 'assets/searchim.png',
      'title': 'Image View',
      'subtitle': 'Tampilkan gambar dari URL dinamis',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('avatar_url, name')
          .eq('id', user.id)
          .single();

      setState(() {
        avatarUrl = response['avatar_url'] as String?;
        userName = response['name'] as String?;
      });
    }
  }

  void _onIconTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = products[selectedIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFE8F0FA),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: FractionallySizedBox(
              widthFactor: 0.4,
              heightFactor: 0.8,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF256DFF),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _iconButton(Icons.menu),
                      Column(
                        children: [
                          _profileAvatar(),
                          if (userName != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                userName!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text("Featured", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const Text("Products", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w300)),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      _categoryIcon(Icons.calculate_rounded, 0),
                      const SizedBox(width: 12),
                      _categoryIcon(Icons.school, 1),
                      const SizedBox(width: 12),
                      _categoryIcon(Icons.image_search, 2),
                    ],
                  ),
                  const SizedBox(height: 30),

                  Center(child: _productCard(selected)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      padding: const EdgeInsets.all(12),
      child: Icon(icon, size: 24),
    );
  }

  Widget _profileAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      padding: const EdgeInsets.all(2),
      child: CircleAvatar(
        radius: 20,
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
        backgroundColor: Colors.grey[300],
        child: avatarUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
      ),
    );
  }

  Widget _categoryIcon(IconData icon, int index) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => _onIconTap(index),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Icon(icon, color: isSelected ? Colors.white : Colors.black, size: 28),
      ),
    );
  }

  Widget _productCard(Map<String, String> data) {
    return Container(
      width: 220,
      height: 340,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(data['image']!, fit: BoxFit.contain),
          ),
          const SizedBox(height: 12),
          Text(data['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(data['subtitle']!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
