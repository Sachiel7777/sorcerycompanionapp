import 'package:flutter/material.dart';

/// Mist and indigo by day, midnight and lavender by night, with Cinzel
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
  final base = ColorScheme.fromSeed(seedColor: const Color(0xFF4B49B8), brightness: brightness);
  final scheme = dark
      ? base.copyWith(
          primary: const Color(0xFFB7B9FF),
          onPrimary: const Color(0xFF15174D),
          primaryContainer: const Color(0xFF2D2F78),
          onPrimaryContainer: const Color(0xFFE1E1FF),
          surface: const Color(0xFF0E1020),
          surfaceContainerLowest: const Color(0xFF0A0B18),
          surfaceContainerLow: const Color(0xFF13162A),
          surfaceContainer: const Color(0xFF191C34),
          surfaceContainerHigh: const Color(0xFF22263F),
          surfaceContainerHighest: const Color(0xFF2D314C),
          outlineVariant: const Color(0xFF3F4466),
        )
      : base.copyWith(
          primary: const Color(0xFF3B3AA0),
          primaryContainer: const Color(0xFFDEDFFF),
          onPrimaryContainer: const Color(0xFF13145C),
          surface: const Color(0xFFF4F5FB),
          surfaceContainerLowest: const Color(0xFFFFFFFF),
          surfaceContainerLow: const Color(0xFFEDEFF8),
          surfaceContainer: const Color(0xFFE6E8F4),
          surfaceContainerHigh: const Color(0xFFDEE1F0),
          surfaceContainerHighest: const Color(0xFFD5D9EB),
          outlineVariant: const Color(0xFFC2C7E0),
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
