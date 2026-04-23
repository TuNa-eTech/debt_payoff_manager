import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../domain/entities/debt.dart';
import '../../../../domain/repositories/debt_repository.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'add_debt_page.dart';

class EditDebtPage extends StatelessWidget {
  const EditDebtPage({super.key, required this.id});

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
            appBar: AppBar(title: Text(context.l10n.editDebtTitle)),
            body: Center(child: Text(context.l10n.logPaymentNotFound)),
          );
        }

        return AddDebtPage.edit(debt: debt);
      },
    );
  }
}
