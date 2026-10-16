import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../data/card_repository.dart';
import '../data/settings.dart';
import '../l10n/strings.dart';
import '../theme.dart';

class _Player {
  _Player(this.life);

  int life;
  int mana = 0;
  final Map<String, int> threshold = {for (final e in CardDatabase.elements) e: 0};
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
    final s = context.s;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.newGameQuestion),
        content: Text(s.newGameText(widget.settings.startingLife)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(s.restart)),
        ],
      ),
    );
    if (ok == true) setState(() => _players = _newGame());
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) {
            final sideBySide = box.maxWidth > box.maxHeight;
            final me = _PlayerPanel(
              key: const ValueKey('p1'),
              name: s.player(1),
              accent: scheme.primary,
              player: _players[0],
              onChanged: () => setState(() {}),
            );
            final opponent = _PlayerPanel(
              key: const ValueKey('p2'),
              name: s.player(2),
              accent: elementColors['Water']!,
              player: _players[1],
              onChanged: () => setState(() {}),
            );
            final reset = IconButton.filled(icon: const Icon(Icons.restart_alt), tooltip: s.newGame, onPressed: _reset);
            if (sideBySide) {
              return Row(
                children: [
                  Expanded(child: opponent),
                  Center(child: reset),
                  Expanded(child: me),
                ],
              );
            }
            return Column(
              children: [
                Expanded(child: RotatedBox(quarterTurns: 2, child: opponent)),
                reset,
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
  const _PlayerPanel({
    super.key,
    required this.name,
    required this.accent,
    required this.player,
    required this.onChanged,
  });

  final String name;
  final Color accent;
  final _Player player;
  final VoidCallback onChanged;

  void _change(void Function() update) {
    update();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final deathsDoor = player.life == 0;
    final tint = deathsDoor ? scheme.error : accent;
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tint.withValues(alpha: 0.5), width: 1.5),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [tint.withValues(alpha: 0.22), scheme.surfaceContainerLow],
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(name.toUpperCase(), style: text.labelLarge?.copyWith(letterSpacing: 1.5, color: tint)),
          Expanded(
            child: Row(
              children: [
                _BigButton(
                  icon: Icons.remove,
                  label: s.loseLife,
                  onTap: () => _change(() => player.life = (player.life - 1).clamp(0, 999)),
                  onLongPress: () => _change(() => player.life = (player.life - 5).clamp(0, 999)),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: FittedBox(
                          child: Text(
                            '${player.life}',
                            style: text.displayLarge?.copyWith(fontSize: 96, height: 1, color: scheme.onSurface),
                          ),
                        ),
                      ),
                      Text(
                        deathsDoor ? s.deathsDoor : s.life,
                        style: text.labelLarge?.copyWith(color: deathsDoor ? scheme.error : scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                _BigButton(
                  icon: Icons.add,
                  label: s.gainLife,
                  onTap: () => _change(() => player.life++),
                  onLongPress: () => _change(() => player.life += 5),
                ),
              ],
            ),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              _Counter(
                icon: Icons.auto_awesome,
                label: s.mana,
                color: scheme.primary,
                value: player.mana,
                onChanged: (v) => _change(() => player.mana = v),
              ),
              for (final e in CardDatabase.elements)
                _Counter(
                  icon: elementIcons[e]!,
                  label: s.threshold(s.element(e)),
                  color: elementColors[e]!,
                  value: player.threshold[e]!,
                  onChanged: (v) => _change(() => player.threshold[e] = v),
                ),
            ],
          ),
        ],
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
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        onLongPress: onLongPress,
        child: SizedBox(
          width: 72,
          height: double.infinity,
          child: Icon(icon, size: 36, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
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
          color: color.withValues(alpha: value > 0 ? 0.22 : 0.08),
          border: Border.all(color: color.withValues(alpha: 0.7)),
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
            Text('$value', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
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
