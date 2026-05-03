import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/couple_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../home/main_shell.dart';

class CoupleSetupScreen extends StatefulWidget {
  const CoupleSetupScreen({super.key});

  @override
  State<CoupleSetupScreen> createState() => _CoupleSetupScreenState();
}

class _CoupleSetupScreenState extends State<CoupleSetupScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  int _activeTab = 0;

  DateTime? _anniversaryDate;

  String? _createdInviteCode;

  final _inviteCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    _checkExistingCouple();
  }

  Future<void> _checkExistingCouple() async {
    final coupleProvider = context.read<CoupleProvider>();
    await coupleProvider.fetchCouple();
    
    if (!mounted) return;
    
    if (coupleProvider.hasCouple) {
      debugPrint('[CoupleSetupScreen] Existing couple found, navigating to home');
      _goToHome();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  void _goToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
  }

  Future<void> _pickAnniversaryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _anniversaryDate ?? now,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Дата годовщины',
      cancelText: 'Отмена',
      confirmText: 'Выбрать',
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.bgCard,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: DialogThemeData(backgroundColor: AppColors.bgCard),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _anniversaryDate = picked);
    }
  }

  Future<void> _createCouple() async {
    final coupleProvider = context.read<CoupleProvider>();

    final anniversaryString = _anniversaryDate != null
        ? '${_anniversaryDate!.year.toString().padLeft(4, '0')}'
              '-${_anniversaryDate!.month.toString().padLeft(2, '0')}'
              '-${_anniversaryDate!.day.toString().padLeft(2, '0')}'
        : null;

    final success = await coupleProvider.createCouple(
      anniversaryDate: anniversaryString,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _createdInviteCode = coupleProvider.couple?.inviteCode;
      });
    } else {
      _showError(coupleProvider.error ?? 'Ошибка создания пары');
    }
  }

  Future<void> _joinCouple() async {
    final code = _inviteCodeController.text.trim();
    if (code.isEmpty) {
      _showError('Введите код приглашения');
      return;
    }

    final coupleProvider = context.read<CoupleProvider>();
    final success = await coupleProvider.joinCouple(code);

    if (!mounted) return;

    if (success) {
      _goToHome();
    } else {
      _showError(coupleProvider.error ?? 'Неверный код');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<CoupleProvider>().isLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD63AF5),
              Color(0xFF9B35C8),
              Color(0xFF1A1060),
              Color(0xFF0D0B1E),
            ],
            stops: [0.0, 0.2, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 36),

                  _buildTabToggle(),
                  const SizedBox(height: 32),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: _activeTab == 0
                        ? _buildCreateMode(isLoading)
                        : _buildJoinMode(isLoading),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.45),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.favorite, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 20),
        const Text(
          'Настройка пары',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Создайте пару или присоединитесь к партнёру',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildTabToggle() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          _buildTabButton(index: 0, label: 'Создать пару'),
          _buildTabButton(index: 1, label: 'Присоединиться'),
        ],
      ),
    );
  }

  Widget _buildTabButton({required int index, required String label}) {
    final isSelected = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_activeTab != index) {
            setState(() {
              _activeTab = index;
              if (index != 0) _createdInviteCode = null;
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateMode(bool isLoading) {
    if (_createdInviteCode != null) {
      return _buildInviteCodeResult(_createdInviteCode!);
    }

    return Column(
      key: const ValueKey('create'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Дата годовщины (необязательно)'),
        const SizedBox(height: 10),
        _buildDatePickerField(),
        const SizedBox(height: 10),
        Text(
          'Выберите особенную дату вашей пары',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 36),

        AppButton(
          text: 'Создать пару',
          onPressed: _createCouple,
          isLoading: isLoading,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDatePickerField() {
    final hasDate = _anniversaryDate != null;
    return GestureDetector(
      onTap: _pickAnniversaryDate,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.bgInput,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasDate
                ? AppColors.primary.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.07),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: hasDate ? AppColors.primary : AppColors.textHint,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasDate
                    ? '${_anniversaryDate!.day.toString().padLeft(2, '0')}.'
                          '${_anniversaryDate!.month.toString().padLeft(2, '0')}.'
                          '${_anniversaryDate!.year}'
                    : 'Выберите дату',
                style: TextStyle(
                  color: hasDate ? AppColors.textPrimary : AppColors.textHint,
                  fontSize: 15,
                ),
              ),
            ),
            if (hasDate)
              GestureDetector(
                onTap: () => setState(() => _anniversaryDate = null),
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteCodeResult(String inviteCode) {
    return Column(
      key: const ValueKey('invite_result'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Success banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accentGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.accentGreen.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.accentGreen,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Пара создана! Поделитесь кодом с партнёром.',
                  style: TextStyle(
                    color: AppColors.accentGreen.withValues(alpha: 0.9),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _sectionLabel('Код приглашения'),
        const SizedBox(height: 10),

        // Invite code card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Code text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ваш код',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      inviteCode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
              // Copy button
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: inviteCode));
                  _showSuccess('Код скопирован');
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.copy_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Партнёр вводит этот код на экране «Присоединиться».',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 36),

        // Continue button
        AppButton(text: 'Продолжить', onPressed: _goToHome),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildJoinMode(bool isLoading) {
    return Column(
      key: const ValueKey('join'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Код приглашения'),
        const SizedBox(height: 10),
        AppTextField(
          hint: 'Введите код от партнёра',
          controller: _inviteCodeController,
          prefixIcon: Icons.vpn_key_outlined,
        ),
        const SizedBox(height: 10),
        Text(
          'Попросите партнёра создать пару и поделиться кодом',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 36),

        AppButton(
          text: 'Присоединиться',
          onPressed: _joinCouple,
          isLoading: isLoading,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
