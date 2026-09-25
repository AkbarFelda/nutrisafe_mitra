# Status pengembangan — 23 September 2026

## Pemeriksaan

- `flutter analyze`: tidak ada masalah.
- `flutter test`: 37 tes lulus.
- Tes responsif mencakup login, register, status kemitraan, dan form SPPG:
  layar 320×568, teks 200%, landscape 844×390 dengan simulasi keyboard,
  serta tablet 1200×900 dengan teks 150%.
- Tes lampiran menggunakan picker simulasi: pilihan PDF/foto, pembatalan,
  izin ditolak, batas ukuran/jumlah file, penghapusan, dan pemulihan foto.
- Tampilan responsif diuji melalui layout widget; bukan pemeriksaan visual
  menyeluruh pada seluruh perangkat.

## Belum lengkap

- `main.dart` masih membuka preview status kemitraan. Alur aplikasi normal
  melalui `MitraApp` harus diaktifkan kembali sebelum distribusi.
- Tombol login belum memanggil API autentikasi; lupa password belum tersedia.
- Register akun dan pendaftaran SPPG baru memvalidasi form, belum mengirim
  data atau lampiran ke server.
- Lampiran dan isian form belum disimpan sebagai draft permanen.
- Status aktif, jumlah sekolah/SPPG, dan informasi SPPG masih data contoh.
- Tombol Detail SPPG belum membuka halaman detail.
- Validasi server, ketentuan dokumen wajib, dan aturan NIK/NPWP/password
  perlu disesuaikan dengan kontrak backend sebelum produksi.
- Kamera, izin perangkat, dan file picker native perlu diuji pada perangkat
  Android/iOS nyata. Tes widget tidak menggantikan pengujian tersebut.

## Layout

- Konten auth dibatasi hingga 600 px; status kemitraan hingga 720 px;
  form SPPG hingga 640 px.
- Header register tetap di atas; banner diperkecil ketika tinggi area layar
  terbatas agar form tetap dapat di-scroll saat keyboard terbuka.
- Tombol memakai tinggi minimum dan label/dropdown menyesuaikan lebar.
- Ringkasan kemitraan ditumpuk pada layar sempit atau ukuran teks besar.
