import 'package:url_launcher/url_launcher.dart';

/// Shops where a card's market price can be looked up. The app shows no
/// prices itself: TCGplayer's terms don't allow reusing its price data.
class PriceLink {
  const PriceLink(this.label, this._url);

  final String label;
  final String Function(String name) _url;

  Uri uriFor(String cardName) => Uri.parse(_url(Uri.encodeQueryComponent(cardName)));

  Future<bool> open(String cardName) =>
      launchUrl(uriFor(cardName), mode: LaunchMode.externalApplication);
}

final priceLinks = [
  PriceLink('TCGplayer', (q) =>
      'https://www.tcgplayer.com/search/sorcery-contested-realm/product?q=$q&productLineName=sorcery-contested-realm'),
  PriceLink('eBay', (q) => 'https://www.ebay.it/sch/i.html?_nkw=sorcery+contested+realm+$q'),
];
