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

  @override
  String get themeToggleTooltip => 'Alternar tema';

  @override
  String get categoriesTab => 'Categorias';

  @override
  String get playlistsTab => 'Playlists';

  @override
  String get categoryMeetings => 'Reuniões';

  @override
  String get categoryVocals => 'Vocal';

  @override
  String get categoryInstrumental => 'Instrumental';

  @override
  String get categoryChildren => 'Músicas Infantis';

  @override
  String get downloadAll => 'Baixar tudo';

  @override
  String downloadingProgress(int done, int total) {
    return 'Baixando $done de $total';
  }

  @override
  String get downloadAllComplete => 'Todas as músicas foram baixadas';

  @override
  String get newPlaylist => 'Nova playlist';

  @override
  String get playlistNameHint => 'Nome da playlist';

  @override
  String get create => 'Criar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get renamePlaylist => 'Renomear playlist';

  @override
  String get noPlaylistsYet =>
      'Nenhuma playlist ainda. Toque em + para criar uma.';

  @override
  String get emptyPlaylist => 'Esta playlist está vazia';

  @override
  String get addToPlaylist => 'Adicionar à playlist';

  @override
  String get removeFromPlaylist => 'Remover da playlist';

  @override
  String get deletePlaylist => 'Excluir playlist';

  @override
  String deletePlaylistConfirm(String name) {
    return 'Excluir \"$name\"? Essa ação não pode ser desfeita.';
  }

  @override
  String get delete => 'Excluir';

  @override
  String addedToPlaylist(String name) {
    return 'Adicionada à \"$name\"';
  }

  @override
  String get shuffleTooltip => 'Aleatório';

  @override
  String get repeatOffTooltip => 'Repetir desligado';

  @override
  String get repeatAllTooltip => 'Repetir tudo';

  @override
  String get repeatOneTooltip => 'Repetir uma';

  @override
  String get updateAvailableTooltip =>
      'Nova versão disponível — toque para atualizar';
}
