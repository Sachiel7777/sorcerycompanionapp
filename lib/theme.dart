import 'package:flutter/material.dart';

/// Parchment and bronze by day, ink and gold by night, with Cinzel
/// (a typeface cut from Roman inscriptions) for titles.
const _titleFont = 'Cinzel';

/// Colours of the four elements, used for thresholds and filters.
const elementColors = {
  'Air': Color(0xFF8FA7C4),
  'Earth': Color(0xFFA08C55),
  'Fire': Color(0xFFD9653B),
  'Water': Color(0xFF3F86C6),
};

const elementIcons = {
  'Air': Icons.air,
  'Earth': Icons.landscape,
  'Fire': Icons.local_fire_department,
  'Water': Icons.water_drop,
};

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final base = ColorScheme.fromSeed(seedColor: const Color(0xFF8C6A3F), brightness: brightness);
  final scheme = dark
      ? base.copyWith(
          primary: const Color(0xFFDDB673),
          onPrimary: const Color(0xFF2B1D07),
          primaryContainer: const Color(0xFF4A3818),
          onPrimaryContainer: const Color(0xFFF6E2B8),
          surface: const Color(0xFF15120E),
          surfaceContainerLowest: const Color(0xFF100D0A),
          surfaceContainerLow: const Color(0xFF1B1712),
          surfaceContainer: const Color(0xFF211C16),
          surfaceContainerHigh: const Color(0xFF2A241C),
          surfaceContainerHighest: const Color(0xFF342C22),
          outlineVariant: const Color(0xFF4A4034),
        )
      : base.copyWith(
          primary: const Color(0xFF7A5321),
          primaryContainer: const Color(0xFFF1DDB5),
          onPrimaryContainer: const Color(0xFF3A2708),
          surface: const Color(0xFFF7F0E3),
          surfaceContainerLowest: const Color(0xFFFFFBF4),
          surfaceContainerLow: const Color(0xFFF3EADA),
          surfaceContainer: const Color(0xFFEFE4D1),
          surfaceContainerHigh: const Color(0xFFE9DCC6),
          surfaceContainerHighest: const Color(0xFFE2D3BA),
          outlineVariant: const Color(0xFFD5C3A5),
        );

  final textTheme = ThemeData(brightness: brightness).textTheme;
  TextStyle? title(TextStyle? s, [FontWeight weight = FontWeight.w600]) => s?.copyWith(
    fontFamily: _titleFont,
    fontWeight: weight,
    fontVariations: [FontVariation('wght', weight.value.toDouble())],
    letterSpacing: 0.5,
  );

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: textTheme.copyWith(
      displayLarge: title(textTheme.displayLarge, FontWeight.w700),
      displayMedium: title(textTheme.displayMedium, FontWeight.w700),
      headlineSmall: title(textTheme.headlineSmall),
      headlineMedium: title(textTheme.headlineMedium),
      titleLarge: title(textTheme.titleLarge),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 2,
      titleTextStyle: title(textTheme.titleLarge, FontWeight.w700)?.copyWith(color: scheme.onSurface),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      indicatorColor: scheme.primaryContainer,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(color: scheme.outlineVariant),
    ),
    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerLowest),
      side: WidgetStatePropertyAll(BorderSide(color: scheme.outlineVariant)),
      elevation: const WidgetStatePropertyAll(0),
    ),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: scheme.surfaceContainerLow),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant.withValues(alpha: 0.5)),
    listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
  );
}

/// Small section heading in the title font, used above groups of settings or cards.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.padding = const EdgeInsets.fromLTRB(16, 24, 16, 8)});

  final String text;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: padding,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: _titleFont,
          fontVariations: const [FontVariation('wght', 700)],
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 1.4,
          color: scheme.primary,
        ),
      ),
    );
  }
}
