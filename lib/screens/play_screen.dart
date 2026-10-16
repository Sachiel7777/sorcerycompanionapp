import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../data/settings.dart';

class _Element {
  const _Element(this.key, this.label, this.icon, this.color);

  final String key;
  final String label;
  final IconData icon;
  final Color color;
}

const _elements = [
  _Element('air', 'Aria', Icons.air, Color(0xFF8FA7C4)),
  _Element('earth', 'Terra', Icons.landscape, Color(0xFF9A8A5A)),
  _Element('fire', 'Fuoco', Icons.local_fire_department, Color(0xFFD9653B)),
  _Element('water', 'Acqua', Icons.water_drop, Color(0xFF3F86C6)),
];

class _Player {
  _Player(this.life);

  int life;
  int mana = 0;
  final Map<String, int> threshold = {for (final e in _elements) e.key: 0};
}

/// Life, mana and threshold of two players during a game at the table.
/// The opponent's half is upside down, so the phone can lie between players.
class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key, required this.settings, required this.visible});

  final AppSettings settings;

  /// Whether this tab is the one on screen (it stays alive in the background).
  final bool visible;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late List<_Player> _players = _newGame();

  List<_Player> _newGame() => [_Player(widget.settings.startingLife), _Player(widget.settings.startingLife)];

  @override
  void initState() {
    super.initState();
    widget.settings.addListener(_updateWakelock);
    _updateWakelock();
  }

  @override
  void didUpdateWidget(PlayScreen old) {
    super.didUpdateWidget(old);
    if (old.visible != widget.visible) _updateWakelock();
  }

  @override
  void dispose() {
    widget.settings.removeListener(_updateWakelock);
    WakelockPlus.disable().ignore();
    super.dispose();
  }

  void _updateWakelock() {
    WakelockPlus.toggle(enable: widget.visible && widget.settings.keepScreenOn).ignore();
  }

  Future<void> _reset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuova partita?'),
        content: Text('Vita a ${widget.settings.startingLife}, mana e soglie a zero per entrambi.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ricomincia')),
        ],
      ),
    );
    if (ok == true) setState(() => _players = _newGame());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) {
            final sideBySide = box.maxWidth > box.maxHeight;
            final me = _PlayerPanel(
              key: const ValueKey('p1'),
              name: 'Giocatore 1',
              player: _players[0],
              onChanged: () => setState(() {}),
            );
            final opponent = _PlayerPanel(
              key: const ValueKey('p2'),
              name: 'Giocatore 2',
              player: _players[1],
              onChanged: () => setState(() {}),
            );
            final reset = IconButton.filledTonal(
              icon: const Icon(Icons.restart_alt),
              tooltip: 'Nuova partita',
              onPressed: _reset,
            );
            if (sideBySide) {
              return Row(
                children: [
                  Expanded(child: opponent),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Center(child: reset),
                  ),
                  Expanded(child: me),
                ],
              );
            }
            return Column(
              children: [
                Expanded(child: RotatedBox(quarterTurns: 2, child: opponent)),
                Padding(padding: const EdgeInsets.all(4), child: reset),
                Expanded(child: me),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PlayerPanel extends StatelessWidget {
  const _PlayerPanel({super.key, required this.name, required this.player, required this.onChanged});

  final String name;
  final _Player player;
  final VoidCallback onChanged;

  void _change(void Function() update) {
    update();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final deathsDoor = player.life == 0;
    return Card(
      margin: const EdgeInsets.all(8),
      color: deathsDoor ? scheme.errorContainer : scheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(name, style: text.titleSmall),
            Expanded(
              child: Row(
                children: [
                  _BigButton(
                    icon: Icons.remove,
                    label: 'Togli vita',
                    onTap: () => _change(() => player.life = (player.life - 1).clamp(0, 999)),
                    onLongPress: () => _change(() => player.life = (player.life - 5).clamp(0, 999)),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          child: Text(
                            '${player.life}',
                            style: text.displayLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 88),
                          ),
                        ),
                        Text(deathsDoor ? "Death's Door" : 'Vita', style: text.labelLarge),
                      ],
                    ),
                  ),
                  _BigButton(
                    icon: Icons.add,
                    label: 'Aggiungi vita',
                    onTap: () => _change(() => player.life++),
                    onLongPress: () => _change(() => player.life += 5),
                  ),
                ],
              ),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: [
                _Counter(
                  icon: Icons.auto_awesome,
                  label: 'Mana',
                  color: scheme.primary,
                  value: player.mana,
                  onChanged: (v) => _change(() => player.mana = v),
                ),
                for (final e in _elements)
                  _Counter(
                    icon: e.icon,
                    label: 'Soglia ${e.label}',
                    color: e.color,
                    value: player.threshold[e.key]!,
                    onChanged: (v) => _change(() => player.threshold[e.key] = v),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  const _BigButton({required this.icon, required this.label, required this.onTap, required this.onLongPress});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: onLongPress,
        child: SizedBox(width: 72, height: double.infinity, child: Icon(icon, size: 36)),
      ),
    );
  }
}

/// A small counter (mana or one element's threshold) that never goes below zero.
class _Counter extends StatelessWidget {
  const _Counter({
    required this.icon,
    required this.label,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final Color color;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Tooltip(
      message: label,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.remove, size: 18),
              tooltip: '$label −1',
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
            ),
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text('$value', style: text.titleMedium),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.add, size: 18),
              tooltip: '$label +1',
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
      ),
    );
  }
}
