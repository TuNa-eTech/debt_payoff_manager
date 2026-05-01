import 'package:debt_payoff_manager/core/router/app_router.dart';
import 'package:debt_payoff_manager/features/sharing/data/invite_link_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('inviteAcceptLocationFromUri', () {
    test('routes valid HTTPS invite links with encoded tokens', () {
      final location = inviteAcceptLocationFromUri(
        Uri.parse('https://debtpayoff.app/invite?token=a+b/c=='),
      );

      expect(
        location,
        Uri(
          path: AppRoutes.inviteAccept,
          queryParameters: {'token': 'a b/c=='},
        ).toString(),
      );
    });

    test('routes nested invite paths used by hosting fallbacks', () {
      final location = inviteAcceptLocationFromUri(
        Uri.parse('https://debtpayoff.app/app/invite?token=abc123'),
      );

      expect(location, '${AppRoutes.inviteAccept}?token=abc123');
    });

    test('ignores links without invite tokens or invite paths', () {
      expect(
        inviteAcceptLocationFromUri(Uri.parse('https://debtpayoff.app/invite')),
        isNull,
      );
      expect(
        inviteAcceptLocationFromUri(
          Uri.parse('https://debtpayoff.app/settings?token=abc123'),
        ),
        isNull,
      );
    });
  });
}
