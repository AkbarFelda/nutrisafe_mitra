import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/responsive_content.dart';
import 'widgets/food_scan_actions.dart';
import 'widgets/food_scan_intro_card.dart';
import 'widgets/menu_name_field.dart';

class FoodScanReportPage extends StatefulWidget {
  const FoodScanReportPage({super.key});

  @override
  State<FoodScanReportPage> createState() => _FoodScanReportPageState();
}

class _FoodScanReportPageState extends State<FoodScanReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _menuNameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  Uint8List? _photoBytes;
  bool _isPickingImage = false;
  bool _isAnalyzing = false;
  bool _hasAnalysis = false;
  bool _containsAllergen = false;
  bool _usesRecommendation = false;
  bool _reportSent = false;
  bool _isSubmitting = false;
  String? _detectedAllergen;
  String? _selectedRecommendation;

  @override
  void dispose() {
    _menuNameController.dispose();
    super.dispose();
  }

  void _goBack() {
    final router = GoRouter.maybeOf(context);
    if (router == null) {
      Navigator.maybePop(context);
    } else if (router.canPop()) {
      router.pop();
    } else {
      router.go('/');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isPickingImage = true);
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1600,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _photoBytes = bytes;
        _hasAnalysis = false;
        _containsAllergen = false;
        _usesRecommendation = false;
        _reportSent = false;
        _detectedAllergen = null;
        _selectedRecommendation = null;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto belum dapat dibuka. Silakan coba lagi.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Future<void> _analyze() async {
    FocusScope.of(context).unfocus();
    if (_photoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan foto menu untuk dianalisis.')),
      );
      return;
    }

    setState(() => _isAnalyzing = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
      _hasAnalysis = true;
      _containsAllergen = false;
      _detectedAllergen = null;
      _usesRecommendation = false;
      _reportSent = false;
      _selectedRecommendation = null;
    });
  }

  void _applyRecommendation(String menuName) {
    setState(() {
      _containsAllergen = false;
      _usesRecommendation = true;
      _reportSent = false;
      _selectedRecommendation = menuName;
      _menuNameController.text = menuName;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rekomendasi menu aman telah diterapkan.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_photoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambahkan foto menu makanan terlebih dahulu.'),
        ),
      );
      return;
    }
    if (!_hasAnalysis) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analisis menu sebelum mengirim laporan.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFFE2F8EA),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Color(0xFF169B50),
            size: 34,
          ),
        ),
        title: const Text('Laporan terkirim!'),
        content: const Text(
          'Menu makanan telah tercatat dan siap ditinjau oleh tim NutriSafe.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              minimumSize: const Size(180, 48),
              backgroundColor: const Color(0xFF16A34A),
            ),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
    if (mounted) setState(() => _reportSent = true);
  }

  @override
  Widget build(BuildContext context) => ResponsiveTextScope(
    child: Scaffold(
      backgroundColor: const Color(0xFFF3FAFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3FAFF),
        foregroundColor: AppColors.heading,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text(
          'Scan & Pelaporan Menu',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ResponsiveContent(
          child: Form(
            key: _formKey,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                MediaQuery.sizeOf(context).width < 360 ? 14 : 20,
                12,
                MediaQuery.sizeOf(context).width < 360 ? 14 : 20,
                32,
              ),
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _reportSent
                      ? const _SentBanner(key: ValueKey('sent-banner'))
                      : const SizedBox.shrink(key: ValueKey('no-sent-banner')),
                ),
                if (_reportSent) const SizedBox(height: 16),
                const FoodScanIntroCard(),
                const SizedBox(height: 22),
                MenuNameField(controller: _menuNameController),
                const SizedBox(height: 16),
                _PhotoCard(
                  photoBytes: _photoBytes,
                  isLoading: _isPickingImage,
                  onCamera: () => _pickImage(ImageSource.camera),
                  onGallery: () => _pickImage(ImageSource.gallery),
                  onRemove: () => setState(() {
                    _photoBytes = null;
                    _hasAnalysis = false;
                    _containsAllergen = false;
                    _usesRecommendation = false;
                    _reportSent = false;
                    _detectedAllergen = null;
                    _selectedRecommendation = null;
                  }),
                ),
                const SizedBox(height: 14),
                AnalyzeFoodButton(isLoading: _isAnalyzing, onPressed: _analyze),
                const SizedBox(height: 20),
                _NutritionSummary(hasAnalysis: _hasAnalysis),
                if (_hasAnalysis) ...[
                  const SizedBox(height: 13),
                  _AnalysisStatus(
                    containsAllergen: _containsAllergen,
                    usesRecommendation: _usesRecommendation,
                    selectedRecommendation: _selectedRecommendation,
                  ),
                ],
                const SizedBox(height: 16),
                _DetectedIngredients(
                  hasAnalysis: _hasAnalysis,
                  containsAllergen: _containsAllergen,
                  detectedAllergen: _detectedAllergen,
                ),
                if (_hasAnalysis) ...[
                  const SizedBox(height: 16),
                  _AllergyResultCard(
                    containsAllergen: _containsAllergen,
                    usesRecommendation: _usesRecommendation,
                    selectedRecommendation: _selectedRecommendation,
                  ),
                  if (_containsAllergen) ...[
                    const SizedBox(height: 16),
                    _RecommendationSection(
                      allergen: _detectedAllergen ?? 'alergen',
                      onSelect: _applyRecommendation,
                    ),
                  ],
                ],
                const SizedBox(height: 26),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _reportSent
                      ? const SizedBox.shrink(
                          key: ValueKey('report-already-sent'),
                        )
                      : SubmitFoodReportButton(
                          key: const ValueKey('submit-report-button'),
                          isLoading: _isSubmitting,
                          onPressed: _submit,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.photoBytes,
    required this.isLoading,
    required this.onCamera,
    required this.onGallery,
    required this.onRemove,
  });

  final Uint8List? photoBytes;
  final bool isLoading;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _SectionTitle(number: '1', title: 'Ambil foto menu makanan'),
      const SizedBox(height: 14),
      Container(
        height: 260,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFD6EAF8)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x100D256C),
              blurRadius: 18,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: photoBytes == null
            ? Stack(
                children: [
                  const Positioned.fill(child: _ScanCorners()),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLoading)
                          const CircularProgressIndicator()
                        else ...[
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F5FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_a_photo_outlined,
                              color: AppColors.primary,
                              size: 34,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Arahkan kamera ke menu',
                            style: TextStyle(
                              color: AppColors.heading,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Pastikan seluruh porsi terlihat jelas',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(photoBytes!, fit: BoxFit.cover),
                  const _ScanCorners(color: Colors.white),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton.filled(
                      tooltip: 'Hapus foto',
                      onPressed: onRemove,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.heading,
                      ),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                ],
              ),
      ),
      const SizedBox(height: 12),
      LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 300;
          final buttonStyle = ButtonStyle(
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: compact ? 8 : 16),
            ),
            textStyle: WidgetStatePropertyAll(
              TextStyle(fontSize: compact ? 11 : 14),
            ),
          );
          return Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  key: const Key('open-camera'),
                  onPressed: isLoading ? null : onCamera,
                  style: buttonStyle,
                  icon: Icon(
                    Icons.camera_alt_outlined,
                    size: compact ? 18 : 24,
                  ),
                  label: const Text('Buka Kamera'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('open-gallery'),
                  onPressed: isLoading ? null : onGallery,
                  style: buttonStyle,
                  icon: Icon(
                    Icons.photo_library_outlined,
                    size: compact ? 18 : 24,
                  ),
                  label: const Text('Galeri'),
                ),
              ),
            ],
          );
        },
      ),
    ],
  );
}

class _ScanCorners extends StatelessWidget {
  const _ScanCorners({this.color = AppColors.primary});

  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(34),
    child: CustomPaint(painter: _ScanCornersPainter(color)),
  );
}

class _ScanCornersPainter extends CustomPainter {
  const _ScanCornersPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const length = 34.0;
    final path = Path()
      ..moveTo(0, length)
      ..lineTo(0, 0)
      ..lineTo(length, 0)
      ..moveTo(size.width - length, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, length)
      ..moveTo(size.width, size.height - length)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - length, size.height)
      ..moveTo(length, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height - length);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ScanCornersPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _NutritionSummary extends StatelessWidget {
  const _NutritionSummary({required this.hasAnalysis});

  final bool hasAnalysis;

  @override
  Widget build(BuildContext context) {
    final values = hasAnalysis
        ? const [
            ('4', 'Total Porsi'),
            ('486', 'Kalori / Porsi'),
            ('Seimbang', 'Status Gizi'),
          ]
        : const [
            ('-', 'Total Porsi'),
            ('-', 'Kalori / Porsi'),
            ('-', 'Status Gizi'),
          ];
    return Row(
      children: [
        for (var index = 0; index < values.length; index++) ...[
          if (index > 0) const SizedBox(width: 9),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x100D256C),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    values[index].$1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: hasAnalysis && index == 2
                          ? const Color(0xFF169B50)
                          : AppColors.heading,
                      fontSize: index == 2 ? 13 : 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    values[index].$2,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SentBanner extends StatelessWidget {
  const _SentBanner({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: const Color(0xFFE2F8EA),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF9DE0B5)),
    ),
    child: const Row(
      children: [
        Icon(Icons.task_alt_rounded, color: Color(0xFF168C49)),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Laporan hari ini telah dikirim',
            style: TextStyle(
              color: Color(0xFF116B3A),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class _AnalysisStatus extends StatelessWidget {
  const _AnalysisStatus({
    required this.containsAllergen,
    required this.usesRecommendation,
    required this.selectedRecommendation,
  });

  final bool containsAllergen;
  final bool usesRecommendation;
  final String? selectedRecommendation;

  @override
  Widget build(BuildContext context) {
    final isSafe = !containsAllergen;
    final message = usesRecommendation
        ? '${selectedRecommendation ?? 'Menu rekomendasi'} siap digunakan!'
        : isSafe
        ? 'Menu makanan bebas alergen!'
        : 'Menu makanan mengandung alergen!';
    final color = isSafe ? const Color(0xFF169B50) : const Color(0xFFE53935);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isSafe ? Icons.verified_rounded : Icons.warning_amber_rounded,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetectedIngredients extends StatelessWidget {
  const _DetectedIngredients({
    required this.hasAnalysis,
    required this.containsAllergen,
    required this.detectedAllergen,
  });

  final bool hasAnalysis;
  final bool containsAllergen;
  final String? detectedAllergen;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE2EDF5)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.fact_check_outlined, color: AppColors.primary, size: 21),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                'Bahan terdeteksi',
                style: TextStyle(
                  color: AppColors.heading,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        if (!hasAnalysis)
          const Text(
            'Hasil bahan makanan akan muncul setelah foto dianalisis.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          )
        else
          Column(
            children: [
              const _IngredientChip(label: 'Nasi'),
              const SizedBox(height: 8),
              _IngredientChip(
                label: containsAllergen
                    ? 'Mengandung ${detectedAllergen ?? 'alergen'}'
                    : 'Ayam',
                isAllergen: containsAllergen,
              ),
              const SizedBox(height: 8),
              const _IngredientChip(label: 'Wortel'),
              const SizedBox(height: 8),
              const _IngredientChip(label: 'Buncis'),
            ],
          ),
      ],
    ),
  );
}

class _IngredientChip extends StatelessWidget {
  const _IngredientChip({required this.label, this.isAllergen = false});

  final String label;
  final bool isAllergen;

  @override
  Widget build(BuildContext context) {
    final color = isAllergen
        ? const Color(0xFFE53935)
        : const Color(0xFF169B50);
    final background = isAllergen
        ? const Color(0xFFFFECEB)
        : const Color(0xFFE8F8ED);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, color: color, size: 9),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.heading,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              isAllergen ? 'Perlu perhatian' : 'Bebas alergen',
              style: TextStyle(
                color: color,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllergyResultCard extends StatelessWidget {
  const _AllergyResultCard({
    required this.containsAllergen,
    required this.usesRecommendation,
    required this.selectedRecommendation,
  });

  final bool containsAllergen;
  final bool usesRecommendation;
  final String? selectedRecommendation;

  @override
  Widget build(BuildContext context) {
    final isSafe = !containsAllergen;
    final accent = isSafe ? const Color(0xFF169B50) : const Color(0xFFE53935);
    final softColor = isSafe
        ? const Color(0xFFE8F8ED)
        : const Color(0xFFFFECEB);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EDF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
            color: softColor,
            child: Row(
              children: [
                Icon(
                  isSafe
                      ? Icons.health_and_safety_outlined
                      : Icons.emergency_outlined,
                  color: accent,
                ),
                const SizedBox(width: 10),
                Text(
                  isSafe ? 'Status keamanan menu' : 'Peringatan alergi',
                  style: TextStyle(
                    color: accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: softColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSafe ? Icons.check_rounded : Icons.warning_amber_rounded,
                    color: accent,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 11),
                Text(
                  isSafe ? 'Menu makanan aman' : 'Alergen terdeteksi',
                  style: TextStyle(
                    color: AppColors.heading,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  usesRecommendation
                      ? '${selectedRecommendation ?? 'Menu rekomendasi'} telah diterapkan dan aman untuk siswa dengan alergi.'
                      : isSafe
                      ? 'Bahan pada menu ini aman untuk dikonsumsi siswa dengan alergi terdaftar.'
                      : 'Menu berpotensi mengandung susu, telur, kacang, udang, atau bahan pemicu lainnya.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationSection extends StatelessWidget {
  const _RecommendationSection({
    required this.allergen,
    required this.onSelect,
  });

  final String allergen;
  final ValueChanged<String> onSelect;

  static const _menus = [
    (
      name: 'Nasi Ayam Teriyaki',
      description: 'Nasi, ayam panggang, brokoli, wortel, dan saus teriyaki bebas alergen.',
      calories: '472 kkal',
    ),
    (
      name: 'Nasi Ikan Kuah Kuning',
      description:
          'Nasi, ikan kukus, tahu, buncis, dan kuah kunyit tanpa santan.',
      calories: '445 kkal',
    ),
    (
      name: 'Nasi Tempe Sayur',
      description:
          'Nasi, tempe panggang, tumis sayur, sup bening, dan buah pisang.',
      calories: '428 kkal',
    ),
  ];

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F9FF),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFB9DDF5)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.lightbulb_rounded, color: Color(0xFFF59E0B)),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                'Rekomendasi menu siswa alergi',
                style: TextStyle(
                  color: AppColors.heading,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          'Alternatif berikut tidak menggunakan $allergen dan dapat disesuaikan kembali oleh petugas gizi.',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.5,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        for (var index = 0; index < _menus.length; index++) ...[
          _RecommendationCard(
            name: _menus[index].name,
            description: _menus[index].description,
            calories: _menus[index].calories,
            allergen: allergen,
            onSelect: () => onSelect(_menus[index].name),
          ),
          if (index < _menus.length - 1) const SizedBox(height: 10),
        ],
      ],
    ),
  );
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.name,
    required this.description,
    required this.calories,
    required this.allergen,
    required this.onSelect,
  });

  final String name;
  final String description;
  final String calories;
  final String allergen;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFD9E8F2)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D0D256C),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F8ED),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                color: Color(0xFF169B50),
                size: 19,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: AppColors.heading,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              calories,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Text(
          description,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8ED),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Tanpa $allergen',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF168C49),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 9),
            FilledButton(
              onPressed: onSelect,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 38),
                padding: const EdgeInsets.symmetric(horizontal: 13),
                backgroundColor: AppColors.primary,
                textStyle: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Gunakan menu'),
            ),
          ],
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.number, required this.title});

  final String number;
  final String title;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(
        radius: 14,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: Text(
          number,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.heading,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}
