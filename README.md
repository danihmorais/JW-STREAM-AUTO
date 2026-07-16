# JW Stream Auto

App Flutter para reprodução em streaming de músicas do JW.org, com suporte a Android Auto (media browser service)e CarPlay e download
offline das faixas.

## Idiomas / Localization

O app usa o sistema oficial de localização do Flutter (`flutter gen-l10n`).

- Strings de UI: `lib/l10n/app_en.arb` (template/inglês) e `lib/l10n/app_pt.arb` (português).
- Configuração do gerador: `l10n.yaml`.
- O arquivo `lib/l10n/app_localizations.dart` é **gerado automaticamente** ao
  rodar `flutter pub get` (ou `flutter gen-l10n`) — não precisa (nem deve)
  ser commitado manualmente.

Para adicionar um novo idioma:
1. Copie `lib/l10n/app_en.arb` para `lib/l10n/app_<código>.arb` (ex.: `app_es.arb`).
2. Traduza os valores (mantenha as chaves e os placeholders `{query}` etc. iguais).
3. Rode `flutter pub get` para regenerar `AppLocalizations`.
4. O novo `Locale` já aparece automaticamente em `AppLocalizations.supportedLocales`,
   usado pelo `MaterialApp` em `lib/main.dart`.

## Rodando o projeto

```bash
flutter pub get
flutter run
```
