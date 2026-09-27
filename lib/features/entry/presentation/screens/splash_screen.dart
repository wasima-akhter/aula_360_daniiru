import 'package:aula360/features/share/export/screen_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.onInitializationComplete});

  final VoidCallback? onInitializationComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // TODO:
    // Add your actual initialization here:
    // - Check authentication/session
    // - Load saved user data
    // - Initialize Firebase
    // - Load app configuration
    // - Check onboarding status
    // etc.

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // widget.onInitializationComplete?.call();

    context.pushReplacement(RoutePath.loginScreen);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDFF),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const Spacer(),

              // Logo
              _buildLogo(),

              const SizedBox(height: 12),

              // App name
              Text(
                'Aula 360',
                style: context.titleLarge.copyWith(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF123477),
                  letterSpacing: 0.1,
                ),
              ),

              const SizedBox(height: 8),

              // App description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  'Empowering Modern Academies &\nConnected Learning',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    height: 1.55,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF7D8AA3),
                  ),
                ),
              ),

              const SizedBox(height: 52),

              // Loading section
              _buildLoadingIndicator(),

              const Spacer(),

              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 175,
      height: 82,
      child: Image.asset(
        'assets/images/app_logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(
              'AULA360',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                color: Color(0xFF123477),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 1.sw * 0.6,
          height: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8ECF7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 0.52,
                      child: Transform.translate(
                        offset: Offset((_controller.value * 90) - 45, 0),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xFF38A7FF), Color(0xFF1654B8)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF123477),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Initializing secure session...',
              style: TextStyle(
                fontSize: 13.sp,
                color: Color(0xFF7D8AA3),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
