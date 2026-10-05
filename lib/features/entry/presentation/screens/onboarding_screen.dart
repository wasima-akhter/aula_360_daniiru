import '../../../share/export/screen_export.dart';
import '../../../share/widgets/button/app_logo.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  List<_OnboardingData> _buildPages(String Function(String) tr) => [
    _OnboardingData(
      image: 'assets/images/onboarding_1.jpg',
      title: tr(AppStrings.onboardingTitle1),
      description: tr(AppStrings.onboardingDesc1),
      tags: [
        _OnboardingTagData(
          name: tr(AppStrings.onboardingTagUnifiedHub),
          icon: Icons.hub_outlined,
        ),
        _OnboardingTagData(
          name: tr(AppStrings.onboardingTagSmartTimetables),
          icon: Icons.calendar_month_outlined,
        ),
        _OnboardingTagData(
          name: tr(AppStrings.onboardingTagRealtimeSync),
          icon: Icons.sync,
        ),
      ],
    ),
    _OnboardingData(
      image: 'assets/images/onboarding_2.png',
      title: tr(AppStrings.onboardingTitle2),
      description: tr(AppStrings.onboardingDesc2),
      tags: [
        _OnboardingTagData(
          name: tr(AppStrings.onboardingTagLiveAttendance),
          icon: Icons.fact_check_outlined,
        ),
        _OnboardingTagData(
          name: tr(AppStrings.onboardingTagHomeworkTracker),
          icon: Icons.assignment_outlined,
        ),
        _OnboardingTagData(
          name: tr(AppStrings.onboardingTagProgressReports),
          icon: Icons.bar_chart_outlined,
        ),
        _OnboardingTagData(
          name: tr(AppStrings.onboardingTagClassSchedules),
          icon: Icons.calendar_month_outlined,
        ),
      ],
    ),
    _OnboardingData(
      image: 'assets/images/onboarding_3.jpg',
      title: tr(AppStrings.onboardingTitle3),
      description: tr(AppStrings.onboardingDesc3),
      tags: [],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    final pages = _buildPages(
      ref.read(languageProvider).valueOrNull?.tr ?? (k) => k,
    );
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      context.go(RoutePath.chooseRoleScreen);
    }
  }

  void _skip() {
    context.go(RoutePath.chooseRoleScreen);
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watchTr;
    final pages = _buildPages(tr);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AulaLogo(width: 90),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _skip,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 6.h,
                      ),
                      child: Text(
                        tr(AppStrings.onboardingSkip),
                        style: TxtStyle.labelLarge(
                          color: AppColors.text,
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: pages.map((page) {
                  return _buildPage(page, context);
                }).toList(),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(22.w, 4.h, 22.w, 12.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_dot(0), _dot(1), _dot(2)],
                  ),
                  SizedBox(height: 8.h),
                  AulaPrimaryButton(
                    text: _currentPage == 2
                        ? tr(AppStrings.onboardingContinue)
                        : tr(AppStrings.onboardingNext),
                    onTap: _next,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingData data, BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;

        // Keep image reasonably large on small phones,
        // but give more room on larger phones.
        final imageHeight = (availableHeight * 0.42).clamp(170.0, 300.0);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image
              Container(
                width: double.infinity,
                height: imageHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAFD),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.asset(
                    data.image,
                    width: double.infinity,
                    height: imageHeight,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) {
                      return const Center(
                        child: Icon(
                          Icons.school_outlined,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: 14.h),

              // Title
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: TxtStyle.titleLarge(
                  color: AppColors.primaryDark,
                  fontSize: 22.sp,
                  height: 1.25,
                  letterSpacing: -0.3,
                  fontWeight: FontWeight.w800,
                ),
              ),

              SizedBox(height: 8.h),

              // Description
              Text(
                data.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14.sp,
                  height: 1.45,
                ),
              ),

              // Tags
              if (data.tags.isNotEmpty) ...[
                SizedBox(height: 8.h),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: data.tags.map((tag) {
                    return Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width - 50.w,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 9.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tag.icon,
                            color: AppColors.deepBlueColor,
                            size: 13.sp,
                          ),
                          Gap(5.w),
                          Flexible(
                            child: Text(
                              tag.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TxtStyle.titleLarge(
                                color: AppColors.text,
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],

              SizedBox(height: 8.h),
            ],
          ),
        );
      },
    );
  }

  Widget _dot(int index) {
    final selected = _currentPage == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: selected ? 20 : 6,
      height: 5,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : const Color(0xFFD6DAE2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class _OnboardingData {
  final String image;
  final String title;
  final String description;
  final List<_OnboardingTagData> tags;

  const _OnboardingData({
    required this.image,
    required this.title,
    required this.description,
    required this.tags,
  });
}

class _OnboardingTagData {
  final String name;
  final IconData icon;

  _OnboardingTagData({required this.name, required this.icon});
}
