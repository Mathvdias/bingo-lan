import 'package:bingo_app/shared/ui/tokens/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PaywallView(
        onDismiss: () => context.pop(),
        onPurchaseCompleted: (customerInfo, storeTransaction) {
          context.go('/lobby');
        },
        onRestoreCompleted: (customerInfo) {
           if (customerInfo.entitlements.all['premium']?.isActive ?? false) {
             context.go('/lobby');
           }
        },
      ),
    );
  }
}
