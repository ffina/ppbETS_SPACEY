# spacey

A new Flutter project.

## Link Demo Video 
[link](https://youtu.be/R9M-peUCBvA)

## Get to Know
Spacey adalah aplikasi jurnal perjalanan  yang dirancang untuk mendokumentasikan memori berharga. Aplikasi ini memungkinkan pengguna untuk menangkap momen, mencatat perasaan, dan menyimpannya secara aman di Cloud.

<img width="20%" alt="Screenshot_1777305739" src="https://github.com/user-attachments/assets/4cc8db45-7632-48f3-a911-f06ee0374cab" />

<img width="20%" alt="Screenshot_1777305743" src="https://github.com/user-attachments/assets/a39b7532-b5b3-4003-98db-a8964d600e44" />

<img width="20%" alt="Screenshot_1777305747" src="https://github.com/user-attachments/assets/72993ee8-ef2f-471c-9d5c-b427bee6e7ad" />

<img width="20%" alt="Screenshot_1777305752" src="https://github.com/user-attachments/assets/84b3adfa-9547-4134-80a8-579829e8af8c" />

## Technical Implementation
Berikut adalah detail implementasi teknis aplikasi Spacey berdasarkan kriteria penilaian:

1. **CRUD with Relational Database**
 
   Implementasi sistem manajemen data menggunakan SQLite untuk operasional lokal. Pengguna dapat menambahkan memori baru (Create), melihat daftar memori pada halaman Home dan Explore (Read), memperbarui detail konten (Update), serta menghapus memori yang diinginkan (Delete).

2. **Firebase Authentication**
 
   Sistem keamanan akses menggunakan Firebase Auth untuk mengelola registrasi dan login pengguna. Setiap pengguna yang berhasil terautentikasi akan mendapatkan Unique Identifier (UID) yang memastikan privasi dan keamanan sinkronisasi data antar perangkat.

3. **Cloud Data Storage**
 
   Integrasi dengan Cloud Firestore untuk penyimpanan data jarak jauh secara real-time. Setiap postingan yang dibuat akan otomatis tersinkronisasi ke koleksi Firestore berdasarkan UID pengguna.

4. **Automated Notifications**

   Menggunakan Awesome Notifications dimana aplikasi akan memicu notifikasi secara otomatis setiap kali pengguna berhasil menyimpan atau membuat postingan baru.

5. **Smartphone Resource Integration**
 
   Pemanfaatan perangkat keras smartphone melalui fitur Kamera menggunakan Image Picker. Selain itu, splikasi juga dapat mengelola berkas menggunakan File Manager untuk menyimpan dan menampilkan gambar langsung dari memori lokal perangkat.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
