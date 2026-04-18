import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AhaMomentPage extends StatelessWidget {
  const AhaMomentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mdPrimary,
      body: Stack(
        children: [
          // Background floating shapes
          Positioned(top: 60, left: -30, child: _Circle(size: 120, opacity: 0.1)),
          Positioned(top: 100, right: -10, child: _Circle(size: 80, opacity: 0.1)),
          Positioned(top: 20, left: 160, child: _Circle(size: 60, opacity: 0.08)),
          Positioned(top: 220, right: 30, child: _Circle(size: 40, opacity: 0.12)),
          
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.arrowLeft, color: AppColors.mdOnPrimary),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 48), // balance
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Trophy
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.mdOnPrimary.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.trophy, size: 40, color: AppColors.mdOnPrimary),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        Text(
                          'Bạn có kế hoạch\ntrả hết nợ rồi! 🎉',
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: AppColors.mdOnPrimary,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        
                        // Summary Card
                        Container(
                          width: double.infinity,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: AppColors.mdOnPrimary,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    Text(
                                      'Ngày hết nợ dự kiến',
                                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mdOnSurfaceVariant),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tháng 8, 2026',
                                      style: AppTextStyles.displaySmall.copyWith(
                                        color: AppColors.mdPrimary,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Còn 28 tháng nữa',
                                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mdOnSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: AppColors.mdOutlineVariant),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _StatCol(label: 'Tổng lãi', value: '\$4,280', hint: 'với Snowball'),
                                    Container(width: 1, height: 44, color: AppColors.mdOutlineVariant),
                                    _StatCol(label: 'Tổng thanh toán', value: '\$685', hint: 'mỗi tháng'),
                                    Container(width: 1, height: 44, color: AppColors.mdOutlineVariant),
                                    _StatCol(label: 'Tiết kiệm được', value: '\$1,240', hint: 'tiền lãi', emphasize: true),
                                  ],
                                ),
                              ),
                              
                              // Local First Trust Badge
                              Container(
                                width: double.infinity,
                                color: AppColors.mdPrimaryContainer,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(LucideIcons.shield, size: 16, color: AppColors.mdPrimary),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Dữ liệu ở trên thiết bị của bạn.\nKhông cần tài khoản để bắt đầu.',
                                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.mdPrimary),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Bottom CTA
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: () {
                            // Finish onboarding, go to HOME
                            context.go(AppRoutes.home);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.mdOnPrimary,
                            foregroundColor: AppColors.mdPrimary,
                            shape: const StadiumBorder(),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Vào màn hình chính',
                                style: AppTextStyles.labelLarge.copyWith(color: AppColors.mdPrimary),
                              ),
                              const SizedBox(width: 8),
                              const Icon(LucideIcons.arrowRight, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
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

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.opacity});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.mdOnPrimary.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  const _StatCol({
    required this.label,
    required this.value,
    required this.hint,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final String hint;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.mdOnSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.moneyLarge.copyWith(
            color: emphasize ? AppColors.mdPrimary : AppColors.mdOnSurface,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          hint,
          style: AppTextStyles.bodySmall.copyWith(fontSize: 10, color: AppColors.mdOnSurfaceVariant),
        ),
      ],
    );
  }
}

