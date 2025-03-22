import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/custom_bottom_navbar.dart';

class ImageBuilderScreen extends StatefulWidget {
  const ImageBuilderScreen({super.key});

  @override
  State<ImageBuilderScreen> createState() => _ImageBuilderScreenState();
}

class _ImageBuilderScreenState extends State<ImageBuilderScreen> {
  final TextEditingController _linkController = TextEditingController();
  final List<String> _imageLinks = [];
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        if (currentScroll < maxScroll) {
          _scrollController.animateTo(
            currentScroll + 200,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _addImageLink() {
    final link = _linkController.text.trim();
    if (link.isNotEmpty) {
      setState(() {
        _imageLinks.add(link);
        _linkController.clear();
      });
    }
  }

  void _removeImageLink(int index) {
    setState(() {
      _imageLinks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F0FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF256DFF),
        title: const Text("Image Builder"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _linkController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Link Gambar',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addImageLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF256DFF),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Gambar Tersimpan:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: _imageLinks.length,
                itemBuilder: (context, index) {
                  final link = _imageLinks[index];
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(link, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
                            return const Center(child: Text("Link tidak valid"));
                          }),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: CircleAvatar(
                          backgroundColor: Colors.redAccent,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 16),
                            onPressed: () => _removeImageLink(index),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3), // ganti sesuai posisi nav
    );
  }
}