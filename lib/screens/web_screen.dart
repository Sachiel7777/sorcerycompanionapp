import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../l10n/strings.dart';

/// Whether the platform has an embedded web view (Android and iOS only).
bool get inAppBrowserSupported =>
    !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

/// Opens [uri] in the in-app browser, or in the external one where no web
/// view is available.
Future<void> openInApp(BuildContext context, Uri uri) async {
  if (inAppBrowserSupported) {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => WebScreen(uri)));
  } else {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// A page inside the app, with a close button and a way out to the browser.
class WebScreen extends StatefulWidget {
  const WebScreen(this.uri, {super.key});

  final Uri uri;

  @override
  State<WebScreen> createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> {
  late final WebViewController _controller;
  var _progress = 0;
  var _title = '';
  late Uri _current = widget.uri;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (p) => setState(() => _progress = p),
        onPageFinished: (url) async {
          final title = await _controller.getTitle();
          if (!mounted) return;
          setState(() {
            _title = title ?? '';
            _current = Uri.tryParse(url) ?? _current;
          });
        },
        onNavigationRequest: (request) {
          // Hand anything that isn't a web page (app links, mailto) to the system.
          final scheme = Uri.tryParse(request.url)?.scheme;
          if (scheme == 'http' || scheme == 'https' || scheme == 'about') {
            return NavigationDecision.navigate;
          }
          return NavigationDecision.prevent;
        },
      ))
      ..loadRequest(widget.uri);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: s.close,
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(_title.isEmpty ? (_current.host) : _title, overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: s.reload,
              onPressed: _controller.reload,
            ),
            IconButton(
              icon: const Icon(Icons.open_in_browser),
              tooltip: s.openInBrowser,
              onPressed: () => launchUrl(_current, mode: LaunchMode.externalApplication),
            ),
          ],
          bottom: _progress < 100
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(2),
                  child: LinearProgressIndicator(value: _progress / 100, minHeight: 2),
                )
              : null,
        ),
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}
