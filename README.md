# Sorcery Companion (app)

App per Android (e in futuro Linux, Windows, macOS) ispirata a
[sorcery-companion.com](https://www.sorcery-companion.com/). Scritta in Flutter:
un solo codice produce l'app per tutte le piattaforme.

## Cosa fa adesso

- Lista di tutte le 1100 carte di Sorcery: Contested Realm, in griglia con le immagini.
- Ricerca per nome, testo delle regole, sottotipi e parole chiave.
- Filtri per espansione, tipo, elemento e rarità; ordinamento per nome o costo.
- Scheda della carta: statistiche, testo, tutte le stampe (cliccando una stampa si vede la sua immagine).
- Le immagini già viste restano in cache sul telefono.
- Pulsante "Uso offline" per scaricare tutte le immagini in una volta.

## Da dove vengono i dati

- Le carte vengono dall'API ufficiale (`api.sorcerytcg.com`), che chiede di non usarla come
  backend live ma di scaricare i dati e ospitarli da sé.
- Usiamo l'esportazione di [Kairos Archive](https://github.com/sadkinglabs/sorcery-registry)
  (`export/registry.json`), che ripubblica gli stessi dati con ID stabili e ospita le immagini
  su `api.kairosarchive.net` (hotlink consentito, con credito a Erik's Curiosa).
- `tool/build_cards.py` riduce l'esportazione a `assets/data/cards.json`, incluso nell'app.

Nomi, testi e immagini delle carte sono © Erik's Curiosa.

## Aggiornare le carte

```sh
curl -L -o registry.json https://raw.githubusercontent.com/sadkinglabs/sorcery-registry/main/export/registry.json
python3 tool/build_cards.py registry.json
```

## Compilare

```sh
flutter pub get
flutter run              # sul dispositivo collegato
flutter build apk        # Android
flutter build linux      # / windows / macos / web
```

## Scaricare l'APK

A ogni modifica su `main`, GitHub Actions compila l'APK: apri la scheda **Actions**, scegli
l'ultima esecuzione di **Build** e scarica `sorcery-companion-apk` in fondo alla pagina.

## Prossimi passi

1. Aggiornamento automatico della lista carte quando esce una nuova versione dell'archivio.
2. Collezione, mazzi, regole (come sul sito).
