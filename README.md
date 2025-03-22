# 🎓 Aplikasi Flutter: EduTool - All in One Student Companion

## 👋 Perkenalan

Halo! 👋  
Saya **Bayu Lesmana**, pengembang aplikasi **EduTool**, sebuah aplikasi mobile berbasis Flutter yang dirancang khusus untuk membantu mahasiswa dan pelajar dalam aktivitas sehari-hari. Aplikasi ini dibuat sebagai bagian dari pembelajaran saya dalam pengembangan aplikasi mobile dengan Flutter dan integrasi backend menggunakan **Supabase**.

---

## 📱 Fitur Utama

Berikut beberapa fitur utama dalam aplikasi EduTool:

### 🔐 Auth (Authentication)
- **Login & Register** menggunakan email dan password
- **Supabase Auth** sebagai backend otentikasi

### 🧮 Kalkulator
- Kalkulator **Standar** dan **Ilmiah**
- Mendukung operasi matematika seperti `+`, `-`, `×`, `÷`, `√`, `log`, `sin`, `cos`, `tan`, `π`, `e`, dan lainnya
- Menggunakan **TabBar** untuk berpindah antar mode kalkulator

### 🧑‍🎓 Data Mahasiswa
- Input data mahasiswa seperti `Nama`, `NIM`, `Kelas`, `Mata Kuliah`, dan `Nilai`
- Simpan data ke **Supabase Database**
- Fitur tambahan:
  - **Filter** berdasarkan kelas dan mata kuliah
  - **Edit** nilai mahasiswa
  - **Hapus** data
  - Validasi NIM tidak boleh duplikat
  - Animasi sukses saat submit data

### 🖼️ Image Builder
- Input link gambar untuk menampilkan gambar secara **horizontal scrolling**
- Fitur tambahan:
  - Simpan banyak link gambar
  - Hapus link gambar
  - Gambar otomatis bergulir secara perlahan
- Ideal untuk showcase foto atau materi pembelajaran berbasis gambar

### 📱 Desain Modern
- UI dengan nuansa biru `Color(0xFF256DFF)` dan putih `Color(0xFFE8F0FA)`
- **Custom Bottom Navigation** untuk navigasi antar halaman

---

## 🛠️ Teknologi yang Digunakan

- **Flutter** (Framework)
- **Dart** (Programming Language)
- **Supabase**
  - Supabase Auth
  - Supabase Storage
  - Supabase Database
- **Provider** untuk state management kalkulator
- **Animated Widgets** untuk animasi ringan

---

## 🚀 Cara Menjalankan Proyek Ini

1. Clone repository:
   ```bash
   git clone https://github.com/bayuish/aplikasi_Kalkulator.git
   cd aplikasi_Kalkulator

🙏 Terima Kasih

Terima kasih telah mengunjungi repository ini!
Jangan lupa untuk ⭐ star jika kamu suka dengan project ini atau ingin belajar bareng.
Saran, kritik, atau kontribusi sangat diterima!

🧑‍💻 Developer

Bayu Lesmana
Email: bayul769@gmail.com
GitHub: @bayuish

---

```markdown
## 📸 Screenshot

| Login Page        | Kalkulator Ilmiah        | Data Mahasiswa         |
|------------------|--------------------------|------------------------|
| ![Login](screenshots/login.png) | ![Calc](screenshots/scientific_calc.png) | ![Student](screenshots/students.png) |

