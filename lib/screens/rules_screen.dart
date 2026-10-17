import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/rules_content.dart';
import '../l10n/strings.dart';
import '../theme.dart';

/// Opens a link in the browser, or shows it to copy when that fails.
Future<void> openLink(BuildContext context, String url) async {
  var ok = false;
  try {
    ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (ok || !context.mounted) return;
  final s = context.s;
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(s.openLinkFailed), const SizedBox(height: 8), SelectableText(url)],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: url));
            Navigator.pop(context);
          },
          child: Text(s.copy),
        ),
      ],
    ),
  );
}

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final en = s.english;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(s.rulesTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(s.rulesNotice, style: text.bodyMedium),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(s.officialRulebook),
                onPressed: () => openLink(context, officialRulebookUrl),
              ),
            ),
          ),
          for (final (i, section) in rulesSections.indexed) ...[
            SectionTitle('${i + 1}. ${section.title.of(en)}'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final p in section.points)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 7, right: 10),
                              child: Icon(Icons.circle, size: 6, color: Theme.of(context).colorScheme.primary),
                            ),
                            Expanded(child: Text(p.of(en), style: text.bodyLarge)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
