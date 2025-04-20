import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DummyPaymentScreen extends StatelessWidget {
  final String userId;
  const DummyPaymentScreen({super.key, required this.userId});

  Future<void> _confirmPayment(BuildContext context) async {
    try {
      final result = await Supabase.instance.client
          .from('profiles')
          .update({'upgrade_status': 'pending'})
          .eq('id', userId)
          .select(); // tambahkan ini agar query benar-benar dijalankan

      print("Update result: $result");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pembayaran berhasil! Menunggu persetujuan admin.")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dummy Pembayaran")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Total Bayar: Rp25.000"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _confirmPayment(context),
              child: const Text("Bayar Sekarang (Simulasi)"),
            ),
          ],
        ),
      ),
    );
  }
}