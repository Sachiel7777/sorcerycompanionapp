import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/card_repository.dart';
import '../data/settings.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import 'codex_screen.dart';
import 'offline_screen.dart';
import 'rules_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.db, required this.settings});

  final CardDatabase db;
  final AppSettings settings;

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
