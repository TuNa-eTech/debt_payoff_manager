import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../domain/entities/debt.dart';
import '../../../../domain/repositories/debt_repository.dart';
import 'add_debt_page.dart';

class EditDebtPage extends StatelessWidget {
  const EditDebtPage({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    final debtRepository = getIt<DebtRepository>();
    return FutureBuilder<Debt?>(
      future: debtRepository.getDebtById(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final debt = snapshot.data;
        if (debt == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chỉnh sửa khoản nợ')),
            body: const Center(
              child: Text('Khoản nợ này không còn tồn tại hoặc đã bị xóa.'),
            ),
          );
        }

        return AddDebtPage.edit(debt: debt);
      },
    );
  }
}
