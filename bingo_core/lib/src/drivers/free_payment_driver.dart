import 'i_payment_driver.dart';

/// Driver da edição aberta: todo usuário é premium e não há loja.
///
/// Usado quando o app é compilado sem chave do RevenueCat (build open source,
/// fork, release do GitHub). Nenhum SDK de compra é chamado.
class FreePaymentDriver implements IPaymentDriver {
  const FreePaymentDriver();

  @override
  Future<void> init() async {}

  @override
  Future<bool> get isProUser async => true;

  @override
  Future<void> purchasePro() async {}

  @override
  Future<void> restorePurchases() async {}
}
