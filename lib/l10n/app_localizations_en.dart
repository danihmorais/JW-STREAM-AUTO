// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'JW Stream Auto';

  @override
  String get searchHint => 'Search song...';

  @override
  String get noSongsFound => 'No songs found';

  @override
  String noSongMatchesQuery(String query) {
    return 'No songs match \"$query\"';
  }

  @override
  String get loadError =>
      'Couldn\'t load songs. Check your connection and try again.';

  @override
  String get retry => 'Retry';

  @override
  String get untitledSong => 'Untitled song';

  @override
  String get noSongSelected => 'No song selected';

  @override
  String get languageToggleTooltip => 'Switch song language';
}
