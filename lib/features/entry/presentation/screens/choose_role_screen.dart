import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_path.dart';
import '../../../../utils/color/app_colors.dart';
import '../../../../utils/extension/base_extension.dart';
import '../../../share/widgets/button/app_logo.dart';
import '../../../share/widgets/button/app_primary_button.dart';

class ChooseRoleScreen extends StatefulWidget {
  const ChooseRoleScreen({super.key});

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  String selectedRole = 'parent';

  void _continue() {
    context.go(RoutePath.loginScreen.addBasePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 17,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const Spacer(),
                  const AulaLogo(width: 90),
                  const Spacer(),
                  const SizedBox(width: 17),
                ],
              ),

              const SizedBox(height: 43),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select your role',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose how you’ll be accessing your academy portal.',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 11,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              _roleCard(
                role: 'parent',
                title: 'Parent /',
                subtitle: 'Guardian',
                description:
                    'Track your child’s classes, attendance records, homework, and teacher updates.',
                icon: Icons.family_restroom_rounded,
              ),

              const SizedBox(height: 12),

              _roleCard(
                role: 'teacher',
                title: 'Teacher / Educator',
                subtitle: '',
                description:
                    'Manage classroom schedules, log daily attendance, post assignments, and communicate with parents.',
                icon: Icons.co_present_rounded,
              ),

              const Spacer(),

              AulaPrimaryButton(text: 'Continue', onTap: _continue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleCard({
    required String role,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
  }) {
    final selected = selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .08),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.blueSoft
                        : const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: selected
                        ? AppColors.primary
                        : const Color(0xFF718096),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          ' $subtitle',
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected ? AppColors.primary : const Color(0xFFB8BFCA),
                  size: 21,
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Divider(height: 1, color: AppColors.border),

            const SizedBox(height: 10),

            Text(
              description,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 10,
                height: 1.5,
              ),
            ),

            if (selected && role == 'parent') ...[
              const SizedBox(height: 7),
              const Text(
                'Continue as Parent Login →',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
