import '../../../share/export/screen_export.dart';
import '../../../share/widgets/button/app_logo.dart';

class ChooseLanguageScreen extends ConsumerWidget {
  const ChooseLanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langAsync = ref.watch(languageProvider);

    // If data is ready, use it; otherwise fallback to default English state while loading.
    final langState =
        langAsync.valueOrNull ??
        const LanguageState(language: AppLanguage.english, strings: {});

    return _ChooseLanguageBody(langState: langState);
  }
}

class _ChooseLanguageBody extends ConsumerStatefulWidget {
  const _ChooseLanguageBody({required this.langState});

  final LanguageState langState;

  @override
  ConsumerState<_ChooseLanguageBody> createState() =>
      _ChooseLanguageBodyState();
}

class _ChooseLanguageBodyState extends ConsumerState<_ChooseLanguageBody> {
  late AppLanguage _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.langState.language;
  }

  void _onContinue() async {
    await ref.read(languageProvider.notifier).changeLanguage(_selected);
    if (!mounted) return;
    context.go(RoutePath.onboardingScreen);
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watchTr;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              // Logo
              const AulaLogo(width: 120),

              const SizedBox(height: 48),

              // Title
              Text(
                tr(AppStrings.languageSelectTitle),
                textAlign: TextAlign.center,
                style: TxtStyle.titleLarge(
                  color: AppColors.primaryDark,
                  fontSize: 27.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 10),

              // Subtitle
              Text(
                tr(AppStrings.languageSelectSubtitle),
                textAlign: TextAlign.center,
                style: TxtStyle.bodyMedium(
                  color: AppColors.secondaryText,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 44),

              // Language options
              _LanguageOption(
                language: AppLanguage.english,
                label: tr(AppStrings.languageEnglish),
                flagEmoji: '🇺🇸',
                selected: _selected == AppLanguage.english,
                onTap: () => setState(() => _selected = AppLanguage.english),
              ),

              const SizedBox(height: 14),

              _LanguageOption(
                language: AppLanguage.spanish,
                label: tr(AppStrings.languageSpanish),
                flagEmoji: '🇪🇸',
                selected: _selected == AppLanguage.spanish,
                onTap: () => setState(() => _selected = AppLanguage.spanish),
              ),

              const Spacer(),

              // Continue button
              AulaPrimaryButton(
                text: tr(AppStrings.languageContinue),
                onTap: _onContinue,
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Language Option Card
// ─────────────────────────────────────────────

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.language,
    required this.label,
    required this.flagEmoji,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final String label;
  final String flagEmoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.blueSoft : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.8 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Flag
            Text(flagEmoji, style: TextStyle(fontSize: 32.sp)),

            const SizedBox(width: 16),

            // Language name
            Expanded(
              child: Text(
                label,
                style: TxtStyle.titleLarge(
                  color: selected ? AppColors.primaryDark : AppColors.text,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : const Color(0xFFB8BFCA),
                  width: selected ? 6 : 2,
                ),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
