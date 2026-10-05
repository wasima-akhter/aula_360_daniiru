import '../../../../utils/enum/app_enum.dart';
import '../../../nav/user_role/user_role_provider.dart';
import '../../../share/export/screen_export.dart';
import '../../../share/widgets/button/app_logo.dart';

class ChooseRoleScreen extends ConsumerWidget {
  const ChooseRoleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watchTr;
    final selectedRole = ref.watch(userRoleProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),

              // Logo
              const AulaLogo(width: 90),

              const SizedBox(height: 30),

              // Title
              Text(
                tr(AppStrings.roleSelectTitle),
                style: TxtStyle.titleLarge(
                  color: AppColors.primaryDark,
                  fontSize: 27.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                tr(AppStrings.roleSelectSubtitle),
                style: TxtStyle.bodyMedium(color: AppColors.secondaryText),
              ),

              const SizedBox(height: 27),

              // Parent card
              _RoleCard(
                icon: Icons.family_restroom_rounded,
                title: tr(AppStrings.roleParentTitle),
                subtitle: tr(AppStrings.roleParentSubtitle),
                description: tr(AppStrings.roleParentDescription),
                selected: selectedRole == UserRole.parent,
                onTap: () {
                  ref
                      .read(userRoleProvider.notifier)
                      .setRole(UserRole.parent);
                },
              ),

              const SizedBox(height: 12),

              // Teacher card
              _RoleCard(
                icon: Icons.school_outlined,
                title: tr(AppStrings.roleTeacherTitle),
                subtitle: null,
                description: tr(AppStrings.roleTeacherDescription),
                selected: selectedRole == UserRole.teacher,
                onTap: () {
                  ref
                      .read(userRoleProvider.notifier)
                      .setRole(UserRole.teacher);
                },
              ),

              const Spacer(),

              // Continue button
              AulaPrimaryButton(
                text: selectedRole == UserRole.parent
                    ? '${tr(AppStrings.roleContinueAsParent)} →'
                    : '${tr(AppStrings.roleContinueAsTeacher)} →',
                onTap: () {
                  if (selectedRole == UserRole.parent) {
                    context.go(RoutePath.loginScreen);
                  } else {
                    context.go(RoutePath.teacherLoginScreen);
                  }
                },
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Role Card Widget
// ─────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.blueSoft : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: .12)
                    : const Color(0xFFF0F2F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: selected ? AppColors.primary : AppColors.secondaryText,
                size: 22,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TxtStyle.titleLarge(
                          color: selected
                              ? AppColors.primaryDark
                              : AppColors.text,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(width: 3),
                        Text(
                          subtitle!,
                          style: TxtStyle.titleLarge(
                            color: selected
                                ? AppColors.primaryDark
                                : AppColors.text,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: TxtStyle.bodyMedium(
                      color: AppColors.secondaryText,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : const Color(0xFFBFC5D0),
                  width: selected ? 5.5 : 1.8,
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
