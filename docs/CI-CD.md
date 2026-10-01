# CI/CD

## Pipelines

| Workflow | Quando roda | O que faz |
| --- | --- | --- |
| `CI` | todo PR e push na `main` ou `develop` | `flutter analyze --fatal-infos` e `flutter test` nos dois pacotes; em push, compila o APK dev e anexa como artefato por 7 dias |
| `Release Android` | push na `develop`, tag `vX.Y.Z` na `main` ou execução manual | App Bundle `prod` assinado e ofuscado, artefatos por 30 dias, envio para a Play quando a service account existir |

## Branches e trilhas da Play

| Branch | Evento | Trilha | Nome da versão | Quem recebe |
| --- | --- | --- | --- | --- |
| `develop` | todo push (merge de PR) | **alpha** (teste fechado) | `<pubspec>-alpha.<run_number>`, ex. `1.0.5-alpha.14`; flavor `alpha` (ícone BETA, tela de flags) | grupo bingo-testadores, automaticamente |
| `main` | tag `vX.Y.Z` | `RELEASE_TRACK` do workflow: `internal` hoje, `production` quando a Play liberar | `X.Y.Z` (da tag) | testadores de licença (interna) / público (produção) |

O `versionCode` é o `run_number` do workflow, único e crescente nos dois caminhos. Regras:

- PRs do dia a dia entram na `develop`. Cada merge vira uma Alpha nova sem passar pelo Console.
- Para lançar: merge de `develop` em `main` **antes** da tag. Uma tag num commit mais antigo que a Alpha atual gera um `versionCode` maior mesmo assim, mas publicaria código mais velho que o dos testadores.
- A Play não deixa um usuário "descer" de versão: quem está no grupo da Alpha só recebe a produção quando o `versionCode` dela passar o da Alpha. Com o contador único isso acontece naturalmente.
- O primeiro envio de cada trilha para revisão ("Enviar para revisão" na Visão geral da publicação) é manual no Console; depois disso os uploads seguintes entram sozinhos.

## Flavor alpha

O flavor `alpha` é o build da trilha de teste fechado: mesmo `applicationId` (`com.nightstudios.bingo`), mesmo projeto Firebase (`android/app/src/alpha/google-services.json` é cópia do de prod), mesmas chaves do RevenueCat, Crashlytics, anúncios e validação de `RC_ANDROID_KEY` que a prod. O que muda: nome `Bingo β`, ícone com a faixa BETA (`android/app/src/alpha/res`, gerado por `tool/icons/make_alpha_icon.py` + `dart run flutter_launcher_icons -f flutter_launcher_icons-alpha.yaml`) e `AppConfig.hasDebugTools = true`, que liga a tela `/debug/flags` (overrides locais de Remote Config) e a entrada escondida no "Sobre" (5 toques na versão). A prod continua sem nada disso.

```bash
# App Bundle para a trilha alpha (as mesmas secrets/keystore do release prod)
flutter build appbundle --release --flavor alpha -t lib/main_alpha.dart \
  --dart-define=ENVIRONMENT=alpha --dart-define=RC_ANDROID_KEY=$RC_ANDROID_KEY \
  --build-name=X.Y.Z-alpha.N --build-number=N

# APK de depuração local
flutter build apk --debug --flavor alpha -t lib/main_alpha.dart --dart-define=ENVIRONMENT=alpha
```

## Como lançar

```bash
# 1. subir `version:` no pubspec na develop (vira o prefixo das Alphas e o nome das tags seguintes)
# 2. quando estiver pronto para o público: merge develop → main
git checkout main && git merge --ff-only develop && git push origin main
# 3. tag na main
git tag v1.0.5 && git push origin v1.0.5
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
