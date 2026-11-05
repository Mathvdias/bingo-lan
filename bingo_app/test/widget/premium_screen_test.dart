import 'package:bingo_app/features/premium/premium_screen.dart';
import 'package:bingo_app/shared/services/subscription_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  tearDown(() => SubscriptionService.isPremium.value = false);

  group('PremiumScreen', () {
    testWidgets('assinante vê o que está liberado', (tester) async {
      SubscriptionService.isPremium.value = true;

      await pumpApp(tester, const PremiumScreen());

      expect(find.text('Premium ativo'), findsOneWidget);
      // Os três gates reais do app.
      expect(find.text('Sem anúncios'), findsOneWidget);
      expect(find.byIcon(Icons.autorenew_rounded), findsOneWidget);
      expect(find.byIcon(Icons.groups_rounded), findsOneWidget);
      // Três selos de confirmação, um por benefício.
      expect(find.byIcon(Icons.check_circle), findsNWidgets(3));

      expect(find.byKey(const Key('premium_manage_button')), findsOneWidget);
      expect(find.byKey(const Key('premium_restore_button')), findsOneWidget);
      expect(
        find.byKey(const Key('premium_go_paywall_button')),
        findsNothing,
      );
    });

    testWidgets('sem assinatura, manda para a oferta', (tester) async {
      SubscriptionService.isPremium.value = false;

      await pumpApp(tester, const PremiumScreen());

      expect(
        find.byKey(const Key('premium_go_paywall_button')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('premium_manage_button')), findsNothing);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('reage à assinatura ativando durante a tela', (tester) async {
      SubscriptionService.isPremium.value = false;
      await pumpApp(tester, const PremiumScreen());
      expect(find.byKey(const Key('premium_manage_button')), findsNothing);

      SubscriptionService.isPremium.value = true;
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('premium_manage_button')), findsOneWidget);
    });
  });
}
