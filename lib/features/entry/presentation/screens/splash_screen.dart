import 'package:aula360/core/storage/storage_provider.dart';
import 'package:aula360/core/utils/jwt_helper.dart';
import 'package:aula360/features/auth/presentation/controllers/auth_controller.dart';
import 'package:aula360/features/auth/presentation/screens/active_otp_screen.dart';
import 'package:aula360/features/nav/user_role/user_role_provider.dart';
import 'package:aula360/features/share/export/screen_export.dart';
import 'package:aula360/utils/enum/app_enum.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key, this.onInitializationComplete});

  final VoidCallback? onInitializationComplete;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
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
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Check if token exists and is valid
    final storageService = ref.read(storageServiceProvider);
    final hasValidToken = await storageService.hasValidAccessToken();

    if (hasValidToken) {
      // Decode access token to retrieve and persist email
      final accessToken = await storageService.getAccessToken();
      final emailFromToken = JwtHelper.extractEmail(accessToken);

      debugPrint("emailFromToken: $emailFromToken");
      if (emailFromToken != null && emailFromToken.isNotEmpty) {
        await storageService.saveUserEmail(emailFromToken);
      }

      // Validate session with backend /api/v1/auth/check
      final authNotifier = ref.read(authControllerProvider.notifier);
      final isAuthenticated = await authNotifier.checkSession();

      if (!mounted) return;

      if (isAuthenticated) {
        final authState = ref.read(authControllerProvider);
        var user = authState.user;
        final role = authState.role ?? user?.role;

        final effectiveEmail = (user?.email != null && user!.email.isNotEmpty)
            ? user.email
            : (emailFromToken ?? storageService.getUserEmail() ?? '');

        if (user != null && effectiveEmail.isNotEmpty && user.email.isEmpty) {
          user = user.copyWith(email: effectiveEmail);
          ref.read(authControllerProvider.notifier).updateUser(user);
        }

        // Set role & language to the app properly
        if (user != null) {
          if (user.language != null && user.language!.isNotEmpty) {
            final appLang = AppLanguage.fromCode(user.language!);
            await ref.read(languageProvider.notifier).changeLanguage(appLang);
          }
          if (role == UserRole.teacher) {
            ref.read(userRoleProvider.notifier).loginAsTeacher();
          } else {
            ref.read(userRoleProvider.notifier).loginAsParent();
          }
        }

        if (!mounted) return;

        // If 'status' is active and 'isProfileSetup' is true -> navigate to nav page acc to the 'role'
        if (user != null && user.isActive && user.isProfileSetup) {
          context.pushReplacement(RoutePath.navigationPages);
          return;
        }

        // If 'status' is active and 'isProfileSetup' is false -> navigate to profile setup screen
        if (user != null && user.isActive && !user.isProfileSetup) {
          if (role == UserRole.teacher) {
            context.pushReplacement(
              RoutePath.teacherProfileSetup,
              extra: effectiveEmail,
            );
          } else {
            context.pushReplacement(
              RoutePath.profileSetup,
              extra: effectiveEmail,
            );
          }
          return;
        }

        // If 'status' is inactive -> route to active OTP screen
        if (user != null && user.isInactive) {
          await ref
              .read(authControllerProvider.notifier)
              .resendOtp(email: effectiveEmail);
          if (!mounted) return;
          context.pushReplacement(
            RoutePath.activeOtpScreen,
            extra: OtpArgs(
              email: effectiveEmail,
              purpose: OtpPurpose.signup,
              role: role == UserRole.teacher ? OtpRole.teacher : OtpRole.parent,
            ),
          );
          return;
        }
      }
    } else {
      // Clear any invalid or expired tokens
      final hasToken = await storageService.hasAccessToken();
      if (hasToken) {
        await storageService.clearAuthentication();
      }
    }

    if (!mounted) return;

    // Existing fallback logic: Check if the user has already chosen a language.
    final hasChosen = await ref
        .read(languageProvider.notifier)
        .hasLanguageBeenChosen();

    if (!mounted) return;

    if (hasChosen) {
      // context.pushReplacement(RoutePath.chooseRoleScreen);
      context.pushReplacement(RoutePath.chooseLanguageScreen);
    } else {
      context.pushReplacement(RoutePath.chooseLanguageScreen);
    }
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
                  fontSize: 35.5.sp,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF123477),
                  letterSpacing: 0.1,
                ),
              ),

              const SizedBox(height: 8),

              // App description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Empowering Modern Academies &\nConnected Learning',
                  textAlign: TextAlign.center,
                  style: TxtStyle.titleLarge(
                    fontSize: 18.sp,
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
              style: TxtStyle.titleLarge(
                fontSize: 31.5.sp,
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
            Flexible(
              child: Text(
                'Initializing secure session...',
                style: TxtStyle.titleLarge(
                  fontSize: 16.sp,
                  color: Color(0xFF7D8AA3),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
