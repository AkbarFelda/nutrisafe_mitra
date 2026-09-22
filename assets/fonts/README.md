# Font Poppins

Font statis yang dipakai di folder ini:

- Poppins-Regular.ttf (400)
- Poppins-Medium.ttf (500)
- Poppins-SemiBold.ttf (600)
- Poppins-Bold.ttf (700)

Unduh dari https://fonts.google.com/specimen/Poppins dan simpan juga file
lisensinya (OFL.txt) bersama font.

Keempat file telah didaftarkan dalam blok `fonts` di `pubspec.yaml`
dan diaktifkan melalui `fontFamily: 'Poppins'` di `lib/app/theme/app_theme.dart`.
Jalankan `flutter pub get`, lalu hentikan dan jalankan ulang aplikasi.
Font tidak perlu didaftarkan lagi di bagian `assets`.

Warna aplikasi dapat diubah di `lib/app/theme/app_colors.dart`.
Contoh: `primary = Color(0xFF33698D)`; `FF` adalah alpha penuh,
sedangkan `33698D` adalah kode hex warna. Warna `primary` dipakai tombol,
tautan, dan garis input saat fokus. Warna ilustrasi PNG tidak ikut berubah.
