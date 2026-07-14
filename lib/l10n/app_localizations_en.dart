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

  @override
  String get themeToggleTooltip => 'Switch theme';

  @override
  String get categoriesTab => 'Categories';

  @override
  String get playlistsTab => 'Playlists';

  @override
  String get categoryMeetings => 'Meetings';

  @override
  String get categoryVocals => 'Vocal';

  @override
  String get categoryInstrumental => 'Instrumental';

  @override
  String get categoryChildren => 'Children\'s Songs';

  @override
  String get downloadAll => 'Download all';

  @override
  String downloadingProgress(int done, int total) {
    return 'Downloading $done of $total';
  }

  @override
  String get downloadAllComplete => 'All songs downloaded';

  @override
  String get newPlaylist => 'New playlist';

  @override
  String get playlistNameHint => 'Playlist name';

  @override
  String get create => 'Create';

  @override
  String get cancel => 'Cancel';

  @override
  String get noPlaylistsYet => 'No playlists yet. Tap + to create one.';

  @override
  String get emptyPlaylist => 'This playlist is empty';

  @override
  String get addToPlaylist => 'Add to playlist';

  @override
  String get removeFromPlaylist => 'Remove from playlist';

  @override
  String get deletePlaylist => 'Delete playlist';

  @override
  String deletePlaylistConfirm(String name) {
    return 'Delete \"$name\"? This can\'t be undone.';
  }

  @override
  String get delete => 'Delete';

  @override
  String addedToPlaylist(String name) {
    return 'Added to \"$name\"';
  }

  @override
  String get shuffleTooltip => 'Shuffle';

  @override
  String get repeatOffTooltip => 'Repeat off';

  @override
  String get repeatAllTooltip => 'Repeat all';

  @override
  String get repeatOneTooltip => 'Repeat one';
}
