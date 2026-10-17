import '../models/sorcery_card.dart';

/// A line of text read from a photo, with its height in pixels: card names
/// are printed larger than rules text, so taller lines count more.
class ScannedLine {
  const ScannedLine(this.text, {this.height = 1});

  final String text;
  final double height;
}

class CardMatch {
  const CardMatch(this.card, this.score);

  final SorceryCard card;

  /// 0 to 1; 1 means a line read exactly as the card's name.
  final double score;
}

/// Finds the cards whose names best match the lines read from a photo.
/// Text recognition often drops or swaps a few letters, so names are
/// compared by edit distance, ignoring case, accents and punctuation.
List<CardMatch> matchCards(List<ScannedLine> lines, List<SorceryCard> cards, {int limit = 5}) {
  final usable = [
    for (final l in lines)
      if (_key(l.text).length >= 3) (key: _key(l.text), height: l.height),
  ]..sort((a, b) => b.height.compareTo(a.height)); // tall lines first, so weak ones can be skipped
  if (usable.isEmpty) return const [];
  final tallest = usable.map((l) => l.height).reduce((a, b) => a > b ? a : b);

  final scored = <CardMatch>[];
  for (final card in cards) {
    final name = _key(card.name);
    if (name.isEmpty) continue;
    var best = 0.0;
    for (final l in usable) {
      // Weight: a line as tall as the tallest keeps its score, a small one loses up to 30%.
      final weight = tallest <= 0 ? 1.0 : 0.7 + 0.3 * (l.height / tallest);
      // Lines much shorter than the name can't match it well; skip them cheaply.
      if (l.key.length * 2 < name.length || weight <= best) continue;
      final s = _similarity(l.key, name) * weight;
      if (s > best) best = s;
    }
    if (best >= 0.5) scored.add(CardMatch(card, best));
  }
  scored.sort((a, b) => b.score.compareTo(a.score));
  return scored.take(limit).toList();
}

/// Similarity of a read line to a name. A line may carry extra text around
/// the name (cost, type line), so the name is also looked for inside it.
double _similarity(String line, String name) {
  if (line == name) return 1;
  final whole = 1 - _distance(line, name) / (line.length > name.length ? line.length : name.length);
  if (line.length <= name.length) return whole;
  if (line.contains(name)) return 0.95;
  // Names sit on short lines; long lines are rules text, not worth a window search.
  if (line.length > name.length + 12) return whole;
  // Best window of the line with the name's length.
  var bestWindow = 0.0;
  for (var i = 0; i + name.length <= line.length; i++) {
    final w = 1 - _distance(line.substring(i, i + name.length), name) / name.length;
    if (w > bestWindow) bestWindow = w;
  }
  // A short name found inside a long line is weaker evidence.
  final cover = name.length / line.length;
  final inside = bestWindow * (0.75 + 0.2 * cover);
  return inside > whole ? inside : whole;
}

int _distance(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  var prev = List<int>.generate(b.length + 1, (i) => i);
  var cur = List<int>.filled(b.length + 1, 0);
  for (var i = 1; i <= a.length; i++) {
    cur[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      final del = prev[j] + 1, ins = cur[j - 1] + 1, sub = prev[j - 1] + cost;
      cur[j] = del < ins ? (del < sub ? del : sub) : (ins < sub ? ins : sub);
    }
    final t = prev;
    prev = cur;
    cur = t;
  }
  return prev[b.length];
}

String _key(String s) {
  const from = 'àáâäãåèéêëìíîïòóôöõùúûüñç';
  const to = 'aaaaaaeeeeiiiiooooouuuunc';
  final b = StringBuffer();
  for (final ch in s.toLowerCase().split('')) {
    final i = from.indexOf(ch);
    final c = i < 0 ? ch : to[i];
    if (RegExp(r'[a-z0-9]').hasMatch(c)) b.write(c);
  }
  return b.toString();
}
