import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/backup.dart';
import '../data/card_repository.dart';
import '../data/collection_store.dart';
import '../data/deck_store.dart';
import '../data/settings.dart';
import '../data/text_files.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import 'codex_screen.dart';
import 'offline_screen.dart';
import 'rules_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.db, required this.settings, required this.decks});

  final CardDatabase db;
  final AppSettings settings;
  final DeckStore decks;

  Future<void> _exportBackup(BuildContext context) async {
    final s = context.s;
    final messenger = ScaffoldMessenger.of(context);
    final backup = Backup(
      decks: decks.decks,
      collections: CollectionScope.of(context).collections,
      settings: settings.toBackup(),
    );
    try {
      if (await saveTextFile(backup.fileName, backup.toJson(), mimeType: 'application/json')) {
        messenger.showSnackBar(SnackBar(content: Text(s.backupSaved)));
      }
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(s.fileFailed)));
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    final s = context.s;
    final messenger = ScaffoldMessenger.of(context);
    final collections = CollectionScope.of(context);
    final String? text;
    try {
      text = await pickTextFile();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(s.fileFailed)));
      return;
    }
    if (text == null) return;
    final Backup backup;
    try {
      backup = Backup.fromJson(text);
    } on FormatException {
      messenger.showSnackBar(SnackBar(content: Text(s.backupInvalid)));
      return;
    }
    final result = decks.merge(backup.decks);
    final fromCollections = collections.merge(backup.collections);
    settings.restore(backup.settings);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          s.backupImported(result.added, result.updated, fromCollections.added, fromCollections.updated),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final text = Theme.of(context).textTheme;
    Widget group(List<Widget> children) => Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
    Widget padded(Widget child) =>
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: child);

    return Scaffold(
      appBar: AppBar(title: Text(s.settingsTitle)),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            SectionTitle(s.language, padding: const EdgeInsets.fromLTRB(16, 8, 16, 8)),
            group([
              padded(
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'auto', label: Text(s.languageAuto)),
                      const ButtonSegment(value: 'it', label: Text('Italiano')),
                      const ButtonSegment(value: 'en', label: Text('English')),
                    ],
                    selected: {settings.locale?.languageCode ?? 'auto'},
                    onSelectionChanged: (v) => settings.locale = v.first == 'auto' ? null : Locale(v.first),
                  ),
                ),
              ),
            ]),
            SectionTitle(s.appearance),
            group([
              padded(
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: const Icon(Icons.brightness_auto_outlined),
                        label: Text(s.themeAuto),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: const Icon(Icons.light_mode_outlined),
                        label: Text(s.themeLight),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: const Icon(Icons.dark_mode_outlined),
                        label: Text(s.themeDark),
                      ),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (v) => settings.themeMode = v.first,
                  ),
                ),
              ),
            ]),
            SectionTitle(s.rulesGroup),
            group([
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(s.rulesTitle),
                subtitle: Text(s.rulesHint),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RulesScreen())),
              ),
              ListTile(
                leading: const Icon(Icons.auto_stories_outlined),
                title: Text(s.codexTitle),
                subtitle: Text(s.codexHint),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CodexScreen(db: db))),
              ),
            ]),
            SectionTitle(s.game),
            group([
              ListTile(
                leading: const Icon(Icons.favorite_outline),
                title: Text(s.startingLife),
                subtitle: Text(s.startingLifeHint),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      tooltip: s.lessLife,
                      onPressed: settings.startingLife > 1 ? () => settings.startingLife -= 1 : null,
                    ),
                    SizedBox(
                      width: 32,
                      child: Text('${settings.startingLife}', textAlign: TextAlign.center, style: text.titleMedium),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: s.moreLife,
                      onPressed: () => settings.startingLife += 1,
                    ),
                  ],
                ),
              ),
              if (!kIsWeb)
                SwitchListTile(
                  secondary: const Icon(Icons.light_mode_outlined),
                  title: Text(s.keepScreenOn),
                  subtitle: Text(s.keepScreenOnHint),
                  value: settings.keepScreenOn,
                  onChanged: (v) => settings.keepScreenOn = v,
                ),
            ]),
            if (!kIsWeb) ...[
              SectionTitle(s.images),
              group([
                ListTile(
                  leading: const Icon(Icons.download_for_offline_outlined),
                  title: Text(s.offline),
                  subtitle: Text(s.offlineHint),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => OfflineScreen(db: db))),
                ),
              ]),
            ],
            SectionTitle(s.backupGroup),
            group([
              ListTile(
                leading: const Icon(Icons.upload_file_outlined),
                title: Text(s.exportBackup),
                subtitle: Text(s.exportBackupHint),
                onTap: () => _exportBackup(context),
              ),
              ListTile(
                leading: const Icon(Icons.restore_page_outlined),
                title: Text(s.importBackup),
                subtitle: Text(s.importBackupHint),
                onTap: () => _importBackup(context),
              ),
            ]),
            SectionTitle(s.about),
            group([
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(s.cardArchive),
                subtitle: Text(s.archiveSummary(db.cards.length, db.setInfo.length)),
              ),
              ListTile(leading: const Icon(Icons.copyright), title: Text(s.credits), subtitle: Text(s.creditsText)),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(s.licenses),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showLicensePage(context: context, applicationName: 'Sorcery Companion'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
