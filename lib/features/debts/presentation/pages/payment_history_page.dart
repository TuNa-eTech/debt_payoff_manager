import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../domain/repositories/debt_repository.dart';

class PaymentHistoryPage extends StatelessWidget {
  const PaymentHistoryPage({
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
          appBar: AppBar(title: const Text('Lịch sử thanh toán')),
          body: Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Center(
              child: AppCard(
                color: AppColors.mdSurfaceContainerLow,
                child: Text(
                  debt == null
                      ? 'Khoản nợ này không còn tồn tại.'
                      : 'Lịch sử thanh toán của "${debt.name}" chưa được mở ở UI hiện tại. Màn này sẽ hiển thị dữ liệu thật khi payment tracking được bật.',
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
