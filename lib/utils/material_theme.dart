import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff625098),
      surfaceTint: Color(0xff64539b),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff7b69b3),
      onPrimaryContainer: Color(0xfffffbff),
      secondary: Color(0xff625a78),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffe5dafe),
      onSecondaryContainer: Color(0xff665e7d),
      tertiary: Color(0xff625098),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff7b69b3),
      onTertiaryContainer: Color(0xfffffbff),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffdf7ff),
      onSurface: Color(0xff1c1b20),
      onSurfaceVariant: Color(0xff494550),
      outline: Color(0xff7a7581),
      outlineVariant: Color(0xffcac4d1),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff312f35),
      inversePrimary: Color(0xffcebdff),
      primaryFixed: Color(0xffe8ddff),
      onPrimaryFixed: Color(0xff200854),
      primaryFixedDim: Color(0xffcebdff),
      onPrimaryFixedVariant: Color(0xff4c3b81),
      secondaryFixed: Color(0xffe8ddff),
      onSecondaryFixed: Color(0xff1e1732),
      secondaryFixedDim: Color(0xffccc1e4),
      onSecondaryFixedVariant: Color(0xff4a425f),
      tertiaryFixed: Color(0xffe8ddff),
      onTertiaryFixed: Color(0xff200854),
      tertiaryFixedDim: Color(0xffcebdff),
      onTertiaryFixedVariant: Color(0xff4c3b81),
      surfaceDim: Color(0xffddd8df),
      surfaceBright: Color(0xfffdf7ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f2f9),
      surfaceContainer: Color(0xfff2ecf3),
      surfaceContainerHigh: Color(0xffece6ed),
      surfaceContainerHighest: Color(0xffe6e1e8),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff3b296f),
      surfaceTint: Color(0xff64539b),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff7362ab),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff39324e),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff716988),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff3b296f),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff7362ab),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffdf7ff),
      onSurface: Color(0xff121015),
      onSurfaceVariant: Color(0xff38353f),
      outline: Color(0xff54515c),
      outlineVariant: Color(0xff6f6b77),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff312f35),
      inversePrimary: Color(0xffcebdff),
      primaryFixed: Color(0xff7362ab),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff5b4991),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff716988),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff58506e),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff7362ab),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff5b4991),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffcac5cc),
      surfaceBright: Color(0xfffdf7ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f2f9),
      surfaceContainer: Color(0xffece6ed),
      surfaceContainerHigh: Color(0xffe0dbe2),
      surfaceContainerHighest: Color(0xffd5d0d7),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff311e65),
      surfaceTint: Color(0xff64539b),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff4f3d84),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff2f2843),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff4c4562),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff311e65),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff4f3d84),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffdf7ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff2e2b35),
      outlineVariant: Color(0xff4b4752),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff312f35),
      inversePrimary: Color(0xffcebdff),
      primaryFixed: Color(0xff4f3d84),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff38256c),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff4c4562),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff352e4a),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff4f3d84),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff38256c),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbcb7be),
      surfaceBright: Color(0xfffdf7ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4eff6),
      surfaceContainer: Color(0xffe6e1e8),
      surfaceContainerHigh: Color(0xffd8d3da),
      surfaceContainerHighest: Color(0xffcac5cc),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffcebdff),
      surfaceTint: Color(0xffcebdff),
      onPrimary: Color(0xff352369),
      primaryContainer: Color(0xff7b69b3),
      onPrimaryContainer: Color(0xfffffbff),
      secondary: Color(0xffccc1e4),
      onSecondary: Color(0xff332c48),
      secondaryContainer: Color(0xff4a425f),
      onSecondaryContainer: Color(0xffbab0d3),
      tertiary: Color(0xffcebdff),
      onTertiary: Color(0xff352369),
      tertiaryContainer: Color(0xff7b69b3),
      onTertiaryContainer: Color(0xfffffbff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff141317),
      onSurface: Color(0xffe6e1e8),
      onSurfaceVariant: Color(0xffcac4d1),
      outline: Color(0xff948f9b),
      outlineVariant: Color(0xff494550),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe6e1e8),
      inversePrimary: Color(0xff64539b),
      primaryFixed: Color(0xffe8ddff),
      onPrimaryFixed: Color(0xff200854),
      primaryFixedDim: Color(0xffcebdff),
      onPrimaryFixedVariant: Color(0xff4c3b81),
      secondaryFixed: Color(0xffe8ddff),
      onSecondaryFixed: Color(0xff1e1732),
      secondaryFixedDim: Color(0xffccc1e4),
      onSecondaryFixedVariant: Color(0xff4a425f),
      tertiaryFixed: Color(0xffe8ddff),
      onTertiaryFixed: Color(0xff200854),
      tertiaryFixedDim: Color(0xffcebdff),
      onTertiaryFixedVariant: Color(0xff4c3b81),
      surfaceDim: Color(0xff141317),
      surfaceBright: Color(0xff3a383e),
      surfaceContainerLowest: Color(0xff0f0d12),
      surfaceContainerLow: Color(0xff1c1b20),
      surfaceContainer: Color(0xff201f24),
      surfaceContainerHigh: Color(0xff2b292e),
      surfaceContainerHighest: Color(0xff363439),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffe2d6ff),
      surfaceTint: Color(0xffcebdff),
      onPrimary: Color(0xff2a165e),
      primaryContainer: Color(0xff9885d2),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffe2d7fb),
      onSecondary: Color(0xff28223c),
      secondaryContainer: Color(0xff958cad),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffe2d6ff),
      onTertiary: Color(0xff2a165e),
      tertiaryContainer: Color(0xff9885d2),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff141317),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffe0dae7),
      outline: Color(0xffb5b0bd),
      outlineVariant: Color(0xff938e9b),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe6e1e8),
      inversePrimary: Color(0xff4d3c83),
      primaryFixed: Color(0xffe8ddff),
      onPrimaryFixed: Color(0xff150043),
      primaryFixedDim: Color(0xffcebdff),
      onPrimaryFixedVariant: Color(0xff3b296f),
      secondaryFixed: Color(0xffe8ddff),
      onSecondaryFixed: Color(0xff130d27),
      secondaryFixedDim: Color(0xffccc1e4),
      onSecondaryFixedVariant: Color(0xff39324e),
      tertiaryFixed: Color(0xffe8ddff),
      onTertiaryFixed: Color(0xff150043),
      tertiaryFixedDim: Color(0xffcebdff),
      onTertiaryFixedVariant: Color(0xff3b296f),
      surfaceDim: Color(0xff141317),
      surfaceBright: Color(0xff464349),
      surfaceContainerLowest: Color(0xff08070b),
      surfaceContainerLow: Color(0xff1e1d22),
      surfaceContainer: Color(0xff29272c),
      surfaceContainerHigh: Color(0xff343237),
      surfaceContainerHighest: Color(0xff3f3d42),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff4edff),
      surfaceTint: Color(0xffcebdff),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffcab8ff),
      onPrimaryContainer: Color(0xff0e0034),
      secondary: Color(0xfff4edff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffc8bde0),
      onSecondaryContainer: Color(0xff0d0721),
      tertiary: Color(0xfff4edff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffcab8ff),
      onTertiaryContainer: Color(0xff0e0034),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff141317),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xfff4edfb),
      outlineVariant: Color(0xffc6c0cd),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe6e1e8),
      inversePrimary: Color(0xff4d3c83),
      primaryFixed: Color(0xffe8ddff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffcebdff),
      onPrimaryFixedVariant: Color(0xff150043),
      secondaryFixed: Color(0xffe8ddff),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffccc1e4),
      onSecondaryFixedVariant: Color(0xff130d27),
      tertiaryFixed: Color(0xffe8ddff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffcebdff),
      onTertiaryFixedVariant: Color(0xff150043),
      surfaceDim: Color(0xff141317),
      surfaceBright: Color(0xff524f55),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff201f24),
      surfaceContainer: Color(0xff312f35),
      surfaceContainerHigh: Color(0xff3d3a40),
      surfaceContainerHighest: Color(0xff48464b),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
