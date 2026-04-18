import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../domain/repositories/debt_repository.dart';

class LogPaymentPage extends StatelessWidget {
  const LogPaymentPage({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    final debtRepository = getIt.get<DebtRepository>();
    return FutureBuilder(
      future: debtRepository.getDebtById(id),
      builder: (context, snapshot) {
        final debt = snapshot.data;
        return Scaffold(
          appBar: AppBar(title: const Text('Log payment')),
          body: Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Center(
              child: AppCard(
                color: AppColors.mdSurfaceContainerLow,
                child: Text(
                  debt == null
                      ? 'Khoản nợ này không còn tồn tại.'
                      : 'Luồng ghi nhận thanh toán cho "${debt.name}" chưa được bật ở UI hiện tại. Thông tin khoản nợ của bạn vẫn đang được lưu đầy đủ.',
                  style: AppTextStyles.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
