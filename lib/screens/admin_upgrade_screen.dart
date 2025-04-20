import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUpgradeScreen extends StatefulWidget {
  const AdminUpgradeScreen({super.key});

  @override
  State<AdminUpgradeScreen> createState() => _AdminUpgradeScreenState();
}

class _AdminUpgradeScreenState extends State<AdminUpgradeScreen> {
  List<dynamic> _allUsers = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _checkIfAdmin();
  }

  Future<void> _checkIfAdmin() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final profile = await Supabase.instance.client
        .from('profiles')
        .select('user_type')
        .eq('id', user.id)
        .single();

    final role = profile['user_type'];
    if (role == 'Admin') {
      setState(() {
        _isAdmin = true;
      });
      await _fetchAllUsers();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchAllUsers() async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('id, name, email, user_type, upgrade_status');

      setState(() {
        _allUsers = data;
      });
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  Future<void> _approveUser(String userId) async {
    try {
      await Supabase.instance.client.from('profiles').update({
        'user_type': 'Premium User',
        'upgrade_status': 'approved',
      }).eq('id', userId);
      await _fetchAllUsers();
    } catch (e) {
      print("Error approving user: $e");
    }
  }

  Future<void> _rejectUser(String userId) async {
    try {
      await Supabase.instance.client.from('profiles').update({
        'upgrade_status': 'rejected',
      }).eq('id', userId);
      await _fetchAllUsers();
    } catch (e) {
      print("Error rejecting user: $e");
    }
  }

  Future<void> _updateUserType(String userId, String newType) async {
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'user_type': newType}).eq('id', userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User type updated to $newType')),
      );
      await _fetchAllUsers();
    } catch (e) {
      print("Error updating user type: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return const Scaffold(
        body: Center(child: Text("Akses ditolak. Halaman ini hanya untuk Admin.")),
      );
    }

    final filteredUsers = _selectedFilter == 'Semua'
        ? _allUsers
        : _allUsers.where((user) {
      if (_selectedFilter == 'Pending Approval') {
        return user['upgrade_status'] == 'pending';
      }
      return user['user_type'] == _selectedFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manajemen Pengguna"),
        backgroundColor: const Color(0xFF256DFF),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Filter Pengguna',
                border: OutlineInputBorder(),
              ),
              value: _selectedFilter,
              items: [
                'Semua',
                'Free User',
                'Premium User',
                'Admin',
                'Pending Approval'
              ].map((filter) {
                return DropdownMenuItem(
                  value: filter,
                  child: Text(filter),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFilter = value;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(child: Text("Tidak ada pengguna."))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                String selectedRole = user['user_type'];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(user['email'] ?? '', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text("Tipe Akun: "),
                            DropdownButton<String>(
                              value: selectedRole,
                              items: ['Free User', 'Premium User', 'Admin']
                                  .map((role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedRole = value;
                                    user['user_type'] = value;
                                  });
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.save, color: Colors.blue),
                              onPressed: () => _updateUserType(user['id'], selectedRole),
                            ),
                          ],
                        ),
                        if (user['upgrade_status'] == 'pending') ...[
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () => _approveUser(user['id']),
                                icon: const Icon(Icons.check_circle, color: Colors.green),
                              ),
                              IconButton(
                                onPressed: () => _rejectUser(user['id']),
                                icon: const Icon(Icons.cancel, color: Colors.red),
                              ),
                            ],
                          )
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}