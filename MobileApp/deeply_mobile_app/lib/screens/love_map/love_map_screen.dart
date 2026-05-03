import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/features_provider.dart';
import '../../data/models/love_map_model.dart';
import '../../widgets/common/app_button.dart';

class LoveMapScreen extends StatefulWidget {
  const LoveMapScreen({super.key});

  @override
  State<LoveMapScreen> createState() => _LoveMapScreenState();
}

class _LoveMapScreenState extends State<LoveMapScreen> {
  final _picker = ImagePicker();
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeaturesProvider>().fetchLovePoints();
    });
  }

  Future<void> _openAddSheet() async {
    final descCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    File? selectedImage;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textHint,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Добавить место',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Address field
                    TextField(
                      controller: addressCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Адрес места...',
                        hintStyle: const TextStyle(color: AppColors.textHint),
                        filled: true,
                        fillColor: AppColors.bgInput,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.textHint),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description field
                    TextField(
                      controller: descCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Описание (что здесь особенного?)...',
                        hintStyle: const TextStyle(color: AppColors.textHint),
                        filled: true,
                        fillColor: AppColors.bgInput,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Photo section
                    Text(
                      'Фотография места',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (selectedImage != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              selectedImage!,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => setSheetState(() => selectedImage = null),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      GestureDetector(
                        onTap: () async {
                          final xfile = await _picker.pickImage(source: ImageSource.gallery);
                          if (xfile != null) {
                            setSheetState(() => selectedImage = File(xfile.path));
                          }
                        },
                        child: Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.bgInput,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  color: AppColors.textHint, size: 32),
                              const SizedBox(height: 6),
                              Text(
                                'Добавить фото',
                                style: TextStyle(color: AppColors.textHint, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),
                    AppButton(
                      text: 'Сохранить',
                      onPressed: () async {
                        final address = addressCtrl.text.trim();
                        final desc = descCtrl.text.trim();
                        if (address.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Введите адрес места'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }
                        final fp = context.read<FeaturesProvider>();
                        await fp.addLovePoint(
                          latitude: 0,
                          longitude: 0,
                          description: desc.isNotEmpty ? desc : null,
                          photoFile: selectedImage,
                          address: address,
                        );
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        await fp.fetchLovePoints();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _viewPoint(LoveMapPointModel point) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (point.photoUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    point.photoUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: AppColors.bgInput,
                      child: const Center(child: Icon(Icons.broken_image, color: AppColors.textHint)),
                    ),
                  ),
                ),
              if (point.photoUrl != null) const SizedBox(height: 16),
              if (point.address != null) ...[
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        point.address!,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              if (point.description != null) ...[
                Text(
                  point.description!,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
                ),
              ],
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Закрыть', style: TextStyle(color: AppColors.primary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fp = context.watch<FeaturesProvider>();
    final points = fp.lovePoints;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Карта мест',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: AppColors.textSecondary,
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _openAddSheet,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
      body: fp.isLoading && points.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : points.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('📍', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        const Text(
                          'Нет добавленных мест',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Нажмите + чтобы добавить\nпервое особенное место',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textHint, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              : _isGridView
                  ? GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: points.length,
                      itemBuilder: (context, index) {
                        final point = points[index];
                        return GestureDetector(
                          onTap: () => _viewPoint(point),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (point.photoUrl != null)
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      child: Image.network(
                                        point.photoUrl!,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: AppColors.bgInput,
                                          child: const Center(
                                            child: Icon(Icons.broken_image, color: AppColors.textHint),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppColors.bgInput,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      ),
                                      child: const Center(
                                        child: Text('📍', style: TextStyle(fontSize: 32)),
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        point.address ?? 'Место',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (point.description != null) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          point.description!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.textHint,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: points.length,
                      itemBuilder: (context, index) {
                        final point = points[index];
                        return GestureDetector(
                          onTap: () => _viewPoint(point),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                            ),
                            child: Row(
                              children: [
                                if (point.photoUrl != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      point.photoUrl!,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 56,
                                        height: 56,
                                        color: AppColors.bgInput,
                                        child: const Icon(Icons.broken_image, color: AppColors.textHint),
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Text('📍', style: TextStyle(fontSize: 24)),
                                    ),
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        point.address ?? 'Место',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (point.description != null) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          point.description!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: AppColors.textHint, size: 18),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
