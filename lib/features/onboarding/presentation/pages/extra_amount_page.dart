import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_chip.dart';

class ExtraAmountPage extends StatefulWidget {
  const ExtraAmountPage({super.key});

  @override
  State<ExtraAmountPage> createState() => _ExtraAmountPageState();
}

class _ExtraAmountPageState extends State<ExtraAmountPage> {
  double _extraAmount = 200;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('Ngân sách thêm'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Bước 4/4 · Gần xong rồi!',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.mdPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: 1.0,
                          backgroundColor: AppColors.mdSurfaceContainerHighest,
                          color: AppColors.mdPrimary,
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 4,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    Text(
                      'Ngoài khoản tối thiểu,\nbạn có thể trả thêm bao nhiêu\nmỗi tháng?',
                      style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Không bắt buộc. Mặc định \$0. Có thể thay đổi bất kỳ lúc nào.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mdOnSurfaceVariant),
                    ),
                    const SizedBox(height: 32),
                    
                    // Huge Input
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.mdPrimaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.mdPrimary, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$',
                            style: AppTextStyles.displayMedium.copyWith(
                              color: AppColors.mdOnPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _extraAmount.toInt().toString(),
                            style: AppTextStyles.displayLarge.copyWith(
                              color: AppColors.mdOnPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.mdPrimary,
                        inactiveTrackColor: AppColors.mdSurfaceContainerHighest,
                        thumbColor: AppColors.mdPrimary,
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: _extraAmount,
                        min: 0,
                        max: 1000,
                        divisions: 20,
                        onChanged: (val) {
                          setState(() {
                            _extraAmount = val;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('\$0', style: AppTextStyles.labelSmall.copyWith(color: AppColors.mdOnSurfaceVariant)),
                          Text('\$1000', style: AppTextStyles.labelSmall.copyWith(color: AppColors.mdOnSurfaceVariant)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Chips
                    Row(
                      children: [
                        AppChip.assist(label: '+\$50', onTap: () => setState(() => _extraAmount += 50)),
                        const SizedBox(width: 8),
                        AppChip.assist(label: '+\$100', onTap: () => setState(() => _extraAmount += 100)),
                        const SizedBox(width: 8),
                        AppChip.assist(label: '+\$200', onTap: () => setState(() => _extraAmount += 200)),
                        const SizedBox(width: 8),
                        AppChip.assist(label: 'Max', onTap: () => setState(() => _extraAmount = 1000)),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Preview Impact
                    if (_extraAmount > 0)
                      Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: AppColors.mdSurfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.mdOutlineVariant),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(LucideIcons.zap, color: AppColors.mdPrimary, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Sức mạnh của \$${_extraAmount.toInt()}/tháng',
                                    style: AppTextStyles.titleSmall,
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: AppColors.mdOutlineVariant),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        'Trả xong sớm',
                                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.mdOnSurfaceVariant),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('8 tháng', style: AppTextStyles.titleMedium.copyWith(color: AppColors.mdPrimary)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Tiết kiệm lãi',
                                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.mdOnSurfaceVariant),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('+\$430', style: AppTextStyles.titleMedium.copyWith(color: AppColors.mdPrimary)),
                                    ],
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.mdSurface,
                border: Border(
                  top: BorderSide(color: AppColors.mdOutlineVariant, width: 1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton.filledLg(
                    label: 'Xem kế hoạch của tôi!',
                    icon: null,
                    trailingIcon: LucideIcons.arrowRight,
                    fullWidth: true,
                    onPressed: () {
                      context.go(AppRoutes.ahaMoment);
                    },
                  ),
                  const SizedBox(height: 16),
                  AppButton.text(
                    label: 'Bỏ qua, dùng \$0 — thay đổi sau',
                    onPressed: () {
                      context.go(AppRoutes.ahaMoment);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
