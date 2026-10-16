import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/card_repository.dart';
import 'data/settings.dart';
import 'l10n/strings.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(['Cinzel'], await rootBundle.loadString('assets/fonts/Cinzel-OFL.txt'));
  });
  final settings = await AppSettings.load();
  runApp(SorceryApp(settings: settings));
}

class SorceryApp extends StatelessWidget {
  const SorceryApp({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        title: 'Sorcery Companion',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: settings.themeMode,
        locale: settings.locale,
        supportedLocales: AppStrings.supportedLocales,
        // A device in any other language gets English.
        localeResolutionCallback: (device, supported) =>
            supported.firstWhere((l) => l.languageCode == device?.languageCode, orElse: () => const Locale('en')),
        localizationsDelegates: const [
          AppStrings.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: FutureBuilder<CardDatabase>(
          future: _cards,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Scaffold(body: Center(child: Text(context.s.loadError(snapshot.error!))));
            }
            if (!snapshot.hasData) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            return HomeScreen(db: snapshot.data!, settings: settings);
          },
        ),
      ),
    );
  }
}

final Future<CardDatabase> _cards = CardDatabase.loadBundled();
