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

  @override
  Widget build(BuildContext context) {
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
                  // Header Row
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

                  // Category Icons
                  Row(
                    children: [
                      _categoryIcon(Icons.calculate_rounded, active: true),
                      const SizedBox(width: 12),
                      _categoryIcon(Icons.school),
                      const SizedBox(width: 12),
                      _categoryIcon(Icons.image_search),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Product Card
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _productCard(
                          image: './assets/dual_sense.png'
                              '',
                          title: 'Dual Sense',
                          subtitle: 'Official PS5 controller',
                        ),
                        _productCard(
                          image: 'assets/dual_sense_blue.png',
                          title: 'Dual Sense',
                          subtitle: 'Blue version',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8),
        ],
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
        backgroundImage:
        avatarUrl != null ? NetworkImage(avatarUrl!) : null,
        backgroundColor: Colors.grey[300],
        child: avatarUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
      ),
    );
  }

  Widget _categoryIcon(IconData icon, {bool active = false}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: active ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Icon(icon, color: active ? Colors.white : Colors.black, size: 28),
    );
  }

  Widget _productCard({required String image, required String title, required String subtitle}) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.asset(image, fit: BoxFit.contain),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(subtitle, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
