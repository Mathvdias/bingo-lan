import 'package:bingo_app/shared/services/revenue_config_service.dart';
import 'package:bingo_core/bingo_core.dart';

/// Uma flag conhecida do Remote Config, para a tela `/debug/flags`.
class FeatureFlag {
  final String key;
  final ConfigValueType type;

  /// Descrição curta (a mesma de `remoteconfig/prod.template.json`).
  final String description;

  /// Valores possíveis quando a flag é um enum (strings); vazio = livre.
  final List<String> options;

  const FeatureFlag({
    required this.key,
    required this.type,
    required this.description,
    this.options = const [],
  });
}

/// Catálogo das flags em uso. Derivado de `remoteconfig/prod.template.json`
/// e das chaves de [RevenueConfigService]; ao criar uma flag nova, adicione
/// aqui também (não há descoberta automática).
const List<FeatureFlag> featureFlagCatalog = [
  FeatureFlag(
    key: RevenueConfigService.keyPurchasesEnabled,
    type: ConfigValueType.boolean,
    description: 'Mostra botão de upgrade, paywall e auto-globo.',
  ),
  FeatureFlag(
    key: RevenueConfigService.keyAdsEnabled,
    type: ConfigValueType.boolean,
    description: 'Liga todos os anúncios.',
  ),
  FeatureFlag(
    key: RevenueConfigService.keyRevenueModel,
    type: ConfigValueType.string,
    description:
        'paywall_host: host paga acima do limite de jogadores. '
        'ad_supported: tudo grátis com anúncios.',
    options: ['paywall_host', 'ad_supported'],
  ),
  FeatureFlag(
    key: RevenueConfigService.keyMaxFreePlayersPathA,
    type: ConfigValueType.integer,
    description: 'Jogadores grátis por sala no modelo paywall_host.',
  ),
  FeatureFlag(
    key: RevenueConfigService.keySoloModeEnabled,
    type: ConfigValueType.boolean,
    description: 'Mostra o modo individual no lobby.',
  ),
  FeatureFlag(
    key: RevenueConfigService.keyIsGloboPaid,
    type: ConfigValueType.boolean,
    description: 'Cobra pelo auto-globo (sorteio automático).',
  ),
  FeatureFlag(
    key: RevenueConfigService.keyIsHostPremium,
    type: ConfigValueType.boolean,
    description: 'Cobra para criar sala.',
  ),
  FeatureFlag(
    key: RevenueConfigService.keyPaywallVariant,
    type: ConfigValueType.string,
    description:
        'Variante do paywall próprio para testes A/B via Experiments '
        '(texto livre; "default" é a padrão).',
  ),
];
