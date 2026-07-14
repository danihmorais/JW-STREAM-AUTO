// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'JW Stream Auto';

  @override
  String get searchHint => 'Buscar música...';

  @override
  String get noSongsFound => 'Nenhuma música encontrada';

  @override
  String noSongMatchesQuery(String query) {
    return 'Nenhuma música corresponde a \"$query\"';
  }

  @override
  String get loadError =>
      'Não foi possível carregar as músicas. Verifique sua conexão e tente novamente.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get untitledSong => 'Música sem título';

  @override
  String get noSongSelected => 'Nenhuma música selecionada';

  @override
  String get languageToggleTooltip => 'Alternar idioma da música';
}
