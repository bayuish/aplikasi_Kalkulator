import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dummy_payment_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Tidak ada pengguna yang login.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: const Color(0xFF256DFF),
      ),
      body: FutureBuilder(
        future: Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = snapshot.data as Map<String, dynamic>;
          final userType = profile['user_type'] ?? 'Unknown';
          final upgradeStatus = profile['upgrade_status'] ?? 'none';

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profile['avatar_url'] != null
                      ? NetworkImage(profile['avatar_url'])
                      : null,
                  backgroundColor: Colors.grey[300],
                  child: profile['avatar_url'] == null
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 12),

                // Role User
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    userType,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF256DFF),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Status Upgrade
                Text(
                  "Status Upgrade: $upgradeStatus",
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                // Tombol Upgrade jika belum bayar & masih free user
                if (userType == 'Free User' && upgradeStatus == 'none')
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DummyPaymentScreen(userId: user.id),
                        ),
                      );
                    },
                    child: const Text("Upgrade ke Premium (Rp25.000)"),
                  ),

                const SizedBox(height: 20),

                // Last Login
                Text(
                  "Last login:\n${user.lastSignInAt?.toLocal().toString().split('.')[0] ?? "-"}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                // Name & Email
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(profile['name'] ?? '-'),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text(profile['email'] ?? '-'),
                ),

                const Spacer(),

                // Sign Out Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                              (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Sign Out"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

extension on String? {
  toLocal() {}
}