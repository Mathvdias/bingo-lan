# CI/CD

## Pipelines

| Workflow | Quando roda | O que faz |
| --- | --- | --- |
| `CI` | todo PR e push na `main` | `flutter analyze --fatal-infos` e `flutter test` nos dois pacotes; depois compila o APK dev e anexa como artefato por 7 dias |
| `Release Android` | tag `vX.Y.Z` ou execução manual | App Bundle `prod` assinado e ofuscado, artefatos por 30 dias, envio para a trilha interna da Play quando a service account existir |

Promoção de interna para teste fechado e produção fica manual no Play Console.

## Como lançar

```bash
# 1. subir a versão no pubspec (só o build-name importa; o build-number vem do run_number)
# 2. tag e push
git tag v1.0.0 && git push origin v1.0.0
```

## Secrets do repositório (Settings → Secrets and variables → Actions)

| Secret | Conteúdo | Como obter |
| --- | --- | --- |
| `ANDROID_KEYSTORE_BASE64` | `base64 -i bingo_app/android/app/upload-keystore.jks` | keystore local de upload |
| `ANDROID_KEYSTORE_PASSWORD` | senha do keystore | `android/key.properties` local |
| `ANDROID_KEY_PASSWORD` | senha da chave | idem |
| `ANDROID_KEY_ALIAS` | `upload` | idem |
| `RC_ANDROID_KEY` | chave pública `goog_…` do RevenueCat | RevenueCat → API keys |
| `RC_IOS_KEY` | chave pública `appl_…` (vazio até existir o app iOS) | idem |
| `RC_TEST_STORE_KEY` | chave `test_…` da Test Store, usada só no APK dev do CI | idem |
| `PLAY_SERVICE_ACCOUNT_JSON` | JSON da service account com acesso à Play Developer API | Play Console → Configurações → Acesso à API; Google Cloud → IAM → Service accounts → chave JSON; dar permissão "Lançar para trilhas de teste" no Play Console → Usuários e permissões |

A mesma service account serve para o RevenueCat validar compras (Apps → bingo (Play Store) → Service account credentials).

## iOS (depois)

Runner macOS do GitHub tem cota limitada no plano gratuito. Plano: fastlane `pilot` com chave da App Store Connect, disparado só por tag, quando o app iOS existir.
