import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// The JW media API doesn't return a "category" field per track — but the
/// same songbook is published as separate `pub` codes depending on the
/// version (with vocals, instrumental only, etc). We use those as the
/// natural grouping for the home screen cards instead of inventing our
/// own taxonomy.
enum SongCategoryId { meetings, vocals, instrumental, children }

class SongCategory {
  final SongCategoryId id;

  /// The `pub` query parameter used against GETPUBMEDIALINKS.
  final String pubCode;
  final IconData icon;

  const SongCategory({
    required this.id,
    required this.pubCode,
    required this.icon,
  });

  static const meetings = SongCategory(
    id: SongCategoryId.meetings,
    pubCode: 'sjjm',
    icon: Icons.groups_outlined,
  );

  static const vocals = SongCategory(
    id: SongCategoryId.vocals,
    pubCode: 'sjjc',
    icon: Icons.mic_outlined,
  );

  static const instrumental = SongCategory(
    id: SongCategoryId.instrumental,
    pubCode: 'sjji',
    icon: Icons.piano_outlined,
  );

  static const children = SongCategory(
    id: SongCategoryId.children,
    pubCode: 'pksjj',
    icon: Icons.child_care_outlined,
  );

  static const all = <SongCategory>[meetings, vocals, instrumental, children];

  /// Categories are stored internally as the enum's raw name (e.g.
  /// "meetings") so MediaItemModel round-trips cleanly through local
  /// storage; this maps that id back to the localized label for display.
  static String label(AppLocalizations l10n, String? categoryId) {
    switch (categoryId) {
      case 'meetings':
        return l10n.categoryMeetings;
      case 'vocals':
        return l10n.categoryVocals;
      case 'instrumental':
        return l10n.categoryInstrumental;
      case 'children':
        return l10n.categoryChildren;
      default:
        return categoryId ?? '';
    }
  }
}
