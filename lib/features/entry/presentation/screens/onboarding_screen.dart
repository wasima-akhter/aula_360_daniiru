import '../../../share/export/screen_export.dart';
import '../../../share/widgets/button/app_logo.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<_OnboardingData> pages = [
    _OnboardingData(
      image: 'assets/images/onboarding_1.jpg',
      title: 'Centralized Academy\nIntelligence',
      description:
          'Experience all-in-one academy management. Connect curriculum, classes, educators, and institutional operations in a unified cloud platform.',
      tags: [
        _OnboardingTagData(name: 'Unified Hub', icon: Icons.hub_outlined),
        _OnboardingTagData(
          name: 'Smart Timetables',
          icon: Icons.calendar_month_outlined,
        ),
        _OnboardingTagData(name: 'Real-Time Sync', icon: Icons.sync),
      ],
    ),
    _OnboardingData(
      image: 'assets/images/onboarding_2.png',
      title: 'Empowering Parents with\nClarity',
      description:
          'Effortlessly monitor real-time attendance, track homework submissions, review weekly exam reports, and stay aligned with your student’s learning journey.',
      tags: [
        _OnboardingTagData(
          name: 'Live Attendance',
          icon: Icons.fact_check_outlined,
        ),

        _OnboardingTagData(
          name: 'Homework Tracker',
          icon: Icons.assignment_outlined,
        ),

        _OnboardingTagData(
          name: 'Progress Reports',
          icon: Icons.bar_chart_outlined,
        ),

        _OnboardingTagData(
          name: 'Class Schedules',
          icon: Icons.calendar_month_outlined,
        ),
      ],
    ),
    _OnboardingData(
      image: 'assets/images/onboarding_3.jpg',
      title: 'Direct Communication &\nGrowth',
      description:
          'Instant two-way messaging with educators, urgent academy broadcasts, milestone badges, and comprehensive performance analytics at your fingertips.',
      tags: [],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AulaLogo(width: 90),
                  GestureDetector(
                    onTap: _skip,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w500,
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
                  return _buildPage(page);
                }).toList(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_dot(0), _dot(1), _dot(2)],
                  ),
                  const SizedBox(height: 14),
                  AulaPrimaryButton(
                    text: _currentPage == 2 ? 'Continue' : 'Next',
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

  Widget _buildPage(_OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: [
          const SizedBox(height: 8),

          Container(
            width: double.infinity,

            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFD),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Image.asset(
                data.image,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) {
                  return const Icon(
                    Icons.school_outlined,
                    size: 80,
                    color: AppColors.primary,
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 17),

          Text(
            data.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryDark,
              fontSize: 22.sp,
              height: 1.25,
              letterSpacing: -0.3,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.secondaryText,

              height: 1.55,
            ),
          ),

          if (data.tags.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 7,
              children: data.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tag.icon,
                        color: AppColors.deepBlueColor,
                        size: 14.sp,
                      ),
                      Gap(5),
                      Text(
                        tag.name,
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
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
