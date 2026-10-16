import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/card_repository.dart';
import '../data/settings.dart';
import 'offline_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.db, required this.settings});

  final CardDatabase db;
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    Widget header(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(title, style: text.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => ListView(
          children: [
            header('Aspetto'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('Auto')),
                  ButtonSegment(value: ThemeMode.light, label: Text('Chiaro')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Scuro')),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (s) => settings.themeMode = s.first,
              ),
            ),
            header('Partita'),
            ListTile(
              title: const Text('Vita iniziale'),
              subtitle: const Text('Vale dalla prossima partita'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    tooltip: 'Meno vita',
                    onPressed: settings.startingLife > 1 ? () => settings.startingLife -= 1 : null,
                  ),
                  Text('${settings.startingLife}', style: text.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Più vita',
                    onPressed: () => settings.startingLife += 1,
                  ),
                ],
              ),
            ),
            if (!kIsWeb)
              SwitchListTile(
                title: const Text('Schermo sempre acceso'),
                subtitle: const Text('Durante la partita lo schermo non si spegne'),
                value: settings.keepScreenOn,
                onChanged: (v) => settings.keepScreenOn = v,
              ),
            if (!kIsWeb) ...[
              header('Immagini'),
              ListTile(
                leading: const Icon(Icons.download_for_offline_outlined),
                title: const Text('Uso offline'),
                subtitle: const Text('Scarica tutte le immagini delle carte'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => OfflineScreen(db: db))),
              ),
            ],
            header('Informazioni'),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Archivio carte'),
              subtitle: Text('${db.cards.length} carte in ${db.setInfo.length} set'),
            ),
            const ListTile(
              leading: Icon(Icons.copyright),
              title: Text('Crediti'),
              subtitle: Text(
                'Nomi, testi e immagini delle carte sono © Erik\'s Curiosa. '
                'Dati e immagini da Kairos Archive (kairosarchive.net). '
                'App non ufficiale, ispirata a sorcery-companion.com.',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Licenze del software'),
              onTap: () => showLicensePage(context: context, applicationName: 'Sorcery Companion'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
