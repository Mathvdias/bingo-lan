# CI/CD

| Workflow | Quando | O que faz |
|---|---|---|
| `CI` (`ci.yml`) | todo PR e push na `main` | `flutter analyze --fatal-infos` e `flutter test` no `bingo_core` e no `bingo_app`; em push, compila o APK dev e anexa como artefato |
| `Release` (`release.yml`) | tag `vX.Y.Z` (ou manual) | compila o APK **prod** assinado, sem chave do RevenueCat (edição aberta), e publica uma GitHub Release com o APK e o `sha256` |

## Publicar uma versão

```bash
# atualize `version:` em bingo_app/pubspec.yaml
git tag v1.1.0 && git push origin v1.1.0
```

O `versionCode` é o `run_number` do workflow.

## Secrets necessários (Settings → Secrets → Actions)

| Secret | Conteúdo |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | keystore de assinatura em base64 (`base64 -w0 upload-keystore.jks`) |
| `ANDROID_KEYSTORE_PASSWORD` | senha da keystore |
| `ANDROID_KEY_PASSWORD` | senha da chave |
| `ANDROID_KEY_ALIAS` | alias da chave |

## Flavors

- `dev`: projeto Firebase de desenvolvimento, ferramentas de debug.
- `alpha`: mesmo pacote da prod, nome `Bingo β`, ícone com faixa BETA e tela `/debug/flags` (5 toques na versão no "Sobre").
- `prod`: build publicado.

Com `--dart-define=RC_ANDROID_KEY=...` o app liga o paywall do RevenueCat e os anúncios controlados pelo Remote Config. Sem a chave, é a edição aberta.
