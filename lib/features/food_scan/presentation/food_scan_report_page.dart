import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../../core/error/app_failure.dart';
import '../../partnership/data/sppg_dashboard_repository.dart';
import 'widgets/food_scan_actions.dart';
import 'widgets/food_scan_intro_card.dart';
import 'widgets/menu_name_field.dart';

class FoodScanReportPage extends StatefulWidget {
  const FoodScanReportPage({super.key, this.repository});

  final SppgDashboardRepository? repository;

  @override
  State<FoodScanReportPage> createState() => _FoodScanReportPageState();
}

class _FoodScanReportPageState extends State<FoodScanReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _menuNameController = TextEditingController();
  final _portionsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
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
  ScanResult? _scanResult;
  List<Map<String, dynamic>> _recommendations = const [];

  @override
  void initState() {
    super.initState();
    _loadTodayReport();
  }

  Future<void> _loadTodayReport() async {
    final repository = widget.repository;
    if (repository == null) return;
    try {
      final today = await repository.getTodayMenuReport();
      if (mounted) setState(() => _reportSent = today.submitted);
    } catch (_) {
      // The scan form remains usable when the status check is unavailable.
    }
  }

  @override
  void dispose() {
    _menuNameController.dispose();
    _portionsController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
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
        _scanResult = null;
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
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi seluruh informasi menu terlebih dahulu.'),
        ),
      );
      return;
    }
    if (_photoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan foto menu untuk dianalisis.')),
      );
      return;
    }

    setState(() => _isAnalyzing = true);
    try {
      final result = await widget.repository?.scanFood(
        imageBytes: _photoBytes!,
        totalPortions: int.parse(_portionsController.text.trim()),
        menuName: _menuNameController.text,
      );
      if (!mounted) return;
      final allergens = <String>{
        ...?result?.allergyWarnings,
        ...?result?.ingredients
            .where((item) => item.isAllergen)
            .map((item) => item.name),
      }.toList(growable: false);
      setState(() {
        _scanResult = result;
        _hasAnalysis = result != null && !result.geminiFailed;
        _containsAllergen = allergens.isNotEmpty;
        _detectedAllergen = allergens.isEmpty ? null : allergens.join(', ');
        _usesRecommendation = false;
        _reportSent = false;
        _selectedRecommendation = null;
        _recommendations = const [];
      });
      if (allergens.isNotEmpty && result != null && widget.repository != null) {
        final recommendation = await widget.repository!.recommendMenu(
          menuName: _menuNameController.text.trim(),
          ingredients: result.ingredients.map((item) => item.name).toList(),
        );
        if (mounted) {
          setState(() => _recommendations = recommendation.items);
          if (!recommendation.active) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rekomendasi menu belum diaktifkan oleh server.'),
              ),
            );
          }
        }
      }
      if (result?.geminiFailed == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'AI belum berhasil menganalisis foto. Silakan coba foto lain.',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppFailure.from(error).message)));
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
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
    if (_menuNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama menu wajib diisi sebelum mengirim laporan.'),
        ),
      );
      _formKey.currentState?.validate();
      return;
    }
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
    try {
      num number(TextEditingController controller) =>
          num.parse(controller.text.trim().replaceAll(',', '.'));
      await widget.repository?.submitMenuReport(
        menuName: _menuNameController.text.trim(),
        calories:
            _scanResult?.nutrientTotal('kalori') ?? number(_caloriesController),
        caloriesPerPortion:
            _scanResult?.caloriesPerPortion ?? number(_caloriesController),
        protein:
            _scanResult?.nutrientTotal('protein') ?? number(_proteinController),
        carbohydrates: _scanResult?.nutrientTotal('karbohidrat') ??
            number(_carbsController),
        fat: _scanResult?.nutrientTotal('lemak') ?? number(_fatController),
        totalPortions: int.parse(_portionsController.text.trim()),
        nutritionStatus: _scanResult?.nutritionStatus.isNotEmpty == true
            ? _scanResult!.nutritionStatus
            : (_containsAllergen ? 'Perlu Ditinjau' : 'Baik'),
        photoRef: _scanResult?.photoRef ?? '',
        ingredients: _scanResult?.ingredients ?? const [],
        usedRecommendation: _usesRecommendation,
        recommendations: _recommendations,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppFailure.from(error).message)));
      return;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
    if (!mounted) return;
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
        content: Text(
          'Menu "${_menuNameController.text.trim()}" telah tercatat dan siap ditinjau oleh tim NutriSafe.',
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
                const _SectionTitle(number: '1', title: 'Isi informasi menu'),
                const SizedBox(height: 14),
                MenuNameField(controller: _menuNameController),
                const SizedBox(height: 12),
                _NutritionInputForm(
                  portionsController: _portionsController,
                  caloriesController: _caloriesController,
                  proteinController: _proteinController,
                  carbsController: _carbsController,
                  fatController: _fatController,
                ),
                const SizedBox(height: 20),
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
                    _scanResult = null;
                  }),
                ),
                const SizedBox(height: 14),
                AnalyzeFoodButton(isLoading: _isAnalyzing, onPressed: _analyze),
                const SizedBox(height: 20),
                _NutritionSummary(
                  hasAnalysis: _hasAnalysis,
                  portions: _portionsController.text,
                  calories: _caloriesController.text,
                  protein: _proteinController.text,
                  carbs: _carbsController.text,
                  fat: _fatController.text,
                  scanResult: _scanResult,
                ),
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
                  ingredients: _scanResult?.ingredients ?? const [],
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
                      recommendations: _recommendations,
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
      const _SectionTitle(number: '2', title: 'Ambil foto menu makanan'),
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

class _NutritionInputForm extends StatelessWidget {
  const _NutritionInputForm({
    required this.portionsController,
    required this.caloriesController,
    required this.proteinController,
    required this.carbsController,
    required this.fatController,
  });

  final TextEditingController portionsController;
  final TextEditingController caloriesController;
  final TextEditingController proteinController;
  final TextEditingController carbsController;
  final TextEditingController fatController;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFD6EAF8)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informasi gizi per porsi',
          style: TextStyle(
            color: AppColors.heading,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Data ini akan dibandingkan dengan hasil deteksi AI.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
        ),
        const SizedBox(height: 14),
        _RequiredNumberField(
          key: const Key('portions-field'),
          controller: portionsController,
          label: 'Jumlah porsi',
          suffix: 'porsi',
          allowDecimal: false,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _RequiredNumberField(
                key: const Key('calories-field'),
                controller: caloriesController,
                label: 'Kalori',
                suffix: 'kkal',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _RequiredNumberField(
                key: const Key('protein-field'),
                controller: proteinController,
                label: 'Protein',
                suffix: 'g',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _RequiredNumberField(
                key: const Key('carbs-field'),
                controller: carbsController,
                label: 'Karbohidrat',
                suffix: 'g',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _RequiredNumberField(
                key: const Key('fat-field'),
                controller: fatController,
                label: 'Lemak',
                suffix: 'g',
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _RequiredNumberField extends StatelessWidget {
  const _RequiredNumberField({
    super.key,
    required this.controller,
    required this.label,
    required this.suffix,
    this.allowDecimal = true,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final bool allowDecimal;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(
      labelText: '$label *',
      suffixText: suffix,
      filled: true,
      fillColor: const Color(0xFFF8FBFD),
    ),
    validator: (value) {
      final raw = value?.trim().replaceAll(',', '.') ?? '';
      if (raw.isEmpty) return '$label wajib diisi.';
      final number = num.tryParse(raw);
      if (number == null || number <= 0) return '$label harus lebih dari 0.';
      if (!allowDecimal && number % 1 != 0) {
        return '$label harus bilangan bulat.';
      }
      return null;
    },
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
  const _NutritionSummary({
    required this.hasAnalysis,
    required this.portions,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.scanResult,
  });

  final bool hasAnalysis;
  final String portions;
  final String calories;
  final String protein;
  final String carbs;
  final String fat;
  final ScanResult? scanResult;

  @override
  Widget build(BuildContext context) {
    final values = hasAnalysis
        ? [
            (portions, 'Total Porsi'),
            (calories, 'Kalori SPPG'),
            ('${_matchPercentage()}%', 'Kecocokan AI'),
          ]
        : const [
            ('-', 'Total Porsi'),
            ('-', 'Kalori SPPG'),
            ('-', 'Kecocokan AI'),
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var index = 0; index < values.length; index++) ...[
              if (index > 0) const SizedBox(width: 9),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 13,
                  ),
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
        ),
        if (hasAnalysis) ...[
          const SizedBox(height: 12),
          _AiComparisonCard(
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            scanResult: scanResult,
          ),
        ],
      ],
    );
  }

  int _matchPercentage() {
    final result = scanResult;
    if (result == null) return 0;
    final submitted = [
      calories,
      protein,
      carbs,
      fat,
    ].map((value) => num.tryParse(value.replaceAll(',', '.'))).toList();
    final detected = [
      result.nutrientPerPortion('kalori'),
      result.nutrientPerPortion('protein'),
      result.nutrientPerPortion('karbohidrat'),
      result.nutrientPerPortion('lemak'),
    ];
    final scores = <double>[];
    for (var index = 0; index < submitted.length; index++) {
      final input = submitted[index];
      final ai = detected[index];
      if (input == null || ai == null || (input == 0 && ai == 0)) continue;
      final maximum = input.abs() > ai.abs() ? input.abs() : ai.abs();
      scores.add((1 - (input - ai).abs() / maximum).clamp(0, 1));
    }
    if (scores.isEmpty) return 0;
    return (scores.reduce((a, b) => a + b) / scores.length * 100).round();
  }
}

class _AiComparisonCard extends StatelessWidget {
  const _AiComparisonCard({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.scanResult,
  });

  final String calories;
  final String protein;
  final String carbs;
  final String fat;
  final ScanResult? scanResult;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF6FF),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFB8DCF4)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Perbandingan input SPPG & deteksi AI',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.heading,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Text(
          'Input SPPG per porsi dibandingkan dengan estimasi AI per porsi.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
        ),
        const SizedBox(height: 12),
        _ComparisonRow(
          label: 'Kalori',
          submitted: '$calories kkal',
          detected: _aiValue('kalori', 'kkal'),
        ),
        _ComparisonRow(
          label: 'Protein',
          submitted: '$protein g',
          detected: _aiValue('protein', 'g'),
        ),
        _ComparisonRow(
          label: 'Karbohidrat',
          submitted: '$carbs g',
          detected: _aiValue('karbohidrat', 'g'),
        ),
        _ComparisonRow(
          label: 'Lemak',
          submitted: '$fat g',
          detected: _aiValue('lemak', 'g'),
        ),
        const SizedBox(height: 8),
        Text(
          scanResult?.nutritionStatus.isNotEmpty == true
              ? 'Status gizi AI: ${scanResult!.nutritionStatus}'
              : 'Status gizi AI belum tersedia.',
          style: TextStyle(
            color: Color(0xFF116B3A),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (scanResult != null) ...[
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          const Text(
            'Total nutrisi terdeteksi pada foto',
            style: TextStyle(
              color: AppColors.heading,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AiTotalChip(
                label: 'Kalori',
                value: _totalValue('kalori', 'kkal'),
              ),
              _AiTotalChip(
                label: 'Protein',
                value: _totalValue('protein', 'g'),
              ),
              _AiTotalChip(
                label: 'Karbohidrat',
                value: _totalValue('karbohidrat', 'g'),
              ),
              _AiTotalChip(
                label: 'Lemak',
                value: _totalValue('lemak', 'g'),
              ),
            ],
          ),
        ],
      ],
    ),
  );

  String _aiValue(String key, String unit) {
    final value = scanResult?.nutrientPerPortion(key);
    if (value == null) return '-';
    final formatted = value % 1 == 0
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
    return '$formatted $unit';
  }

  String _totalValue(String key, String unit) {
    final value = scanResult?.nutrientTotal(key);
    if (value == null) return '-';
    final formatted = value % 1 == 0
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
    return '$formatted $unit';
  }
}

class _AiTotalChip extends StatelessWidget {
  const _AiTotalChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFB8DCF4)),
    ),
    child: Text(
      '$label: $value',
      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
    ),
  );
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.label,
    required this.submitted,
    required this.detected,
  });

  final String label;
  final String submitted;
  final String detected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 11.5))),
        Expanded(
          child: Text(
            submitted,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 11.5),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 7),
          child: Icon(
            Icons.compare_arrows,
            size: 15,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            detected,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
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
    required this.ingredients,
  });

  final bool hasAnalysis;
  final bool containsAllergen;
  final String? detectedAllergen;
  final List<DetectedIngredient> ingredients;

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
              if (ingredients.isEmpty)
                const Text(
                  'AI tidak mengembalikan daftar bahan.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              for (var index = 0; index < ingredients.length; index++) ...[
                if (index > 0) const SizedBox(height: 8),
                _IngredientChip(
                  label: ingredients[index].name,
                  isAllergen: ingredients[index].isAllergen,
                ),
              ],
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
    required this.recommendations,
    required this.onSelect,
  });

  final String allergen;
  final List<Map<String, dynamic>> recommendations;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final menus = recommendations.map((item) => (
      name: '${item['menu_name'] ?? item['substitute'] ?? item['name'] ?? ''}',
      description: '${item['reason'] ?? item['description'] ?? ''}',
      calories: '${item['calories'] ?? item['kalori'] ?? '-'} kkal',
    )).where((item) => item.name.isNotEmpty).toList(growable: false);
    return Container(
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
        if (menus.isEmpty)
          const Text(
            'Belum ada rekomendasi dari server.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        for (var index = 0; index < menus.length; index++) ...[
          _RecommendationCard(
            name: menus[index].name,
            description: menus[index].description,
            calories: menus[index].calories,
            allergen: allergen,
            onSelect: () => onSelect(menus[index].name),
          ),
          if (index < menus.length - 1) const SizedBox(height: 10),
        ],
      ],
    ));
  }
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
