import 'package:flutter/material.dart';

class AppPalette {
  const AppPalette({
    required this.id,
    required this.name,
    required this.seed,
    required this.gradient,
  });

  final String id;
  final String name;
  final Color seed;

  /// Brand gradient used for hero cards, FAB and backgrounds.
  final List<Color> gradient;
}

const List<AppPalette> appPalettes = <AppPalette>[
  AppPalette(
    id: 'ocean',
    name: 'مُنجز',
    seed: Color(0xFF4F6BF6),
    gradient: <Color>[Color(0xFF6D5DFC), Color(0xFF3B7BF6), Color(0xFF14C2D6)],
  ),
  AppPalette(
    id: 'emerald',
    name: 'زمردي',
    seed: Color(0xFF10B981),
    gradient: <Color>[Color(0xFF047857), Color(0xFF10B981), Color(0xFF6EE7B7)],
  ),
  AppPalette(
    id: 'violet',
    name: 'بنفسجي',
    seed: Color(0xFF8B5CF6),
    gradient: <Color>[Color(0xFF6D28D9), Color(0xFF8B5CF6), Color(0xFFC084FC)],
  ),
  AppPalette(
    id: 'sunset',
    name: 'غروب',
    seed: Color(0xFFF97316),
    gradient: <Color>[Color(0xFFE11D48), Color(0xFFF97316), Color(0xFFFBBF24)],
  ),
  AppPalette(
    id: 'rose',
    name: 'وردي',
    seed: Color(0xFFEC4899),
    gradient: <Color>[Color(0xFFBE185D), Color(0xFFEC4899), Color(0xFFF9A8D4)],
  ),
  AppPalette(
    id: 'teal',
    name: 'فيروزي',
    seed: Color(0xFF0D9488),
    gradient: <Color>[Color(0xFF115E59), Color(0xFF0D9488), Color(0xFF5EEAD4)],
  ),
  AppPalette(
    id: 'amber',
    name: 'رملي',
    seed: Color(0xFFD97706),
    gradient: <Color>[Color(0xFFB45309), Color(0xFFD97706), Color(0xFFFCD34D)],
  ),
  AppPalette(
    id: 'royal',
    name: 'ملكي',
    seed: Color(0xFF1E40AF),
    gradient: <Color>[Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF60A5FA)],
  ),
  AppPalette(
    id: 'graphite',
    name: 'رمادي',
    seed: Color(0xFF475569),
    gradient: <Color>[Color(0xFF1F2937), Color(0xFF475569), Color(0xFF94A3B8)],
  ),
];

AppPalette paletteById(String id) => appPalettes.firstWhere(
  (AppPalette palette) => palette.id == id,
  orElse: () => appPalettes.first,
);

/// Gives access to the active palette's gradient from anywhere in the tree.
class BrandColors extends ThemeExtension<BrandColors> {
  const BrandColors({required this.gradient});

  final List<Color> gradient;

  LinearGradient get linear => LinearGradient(
    colors: gradient,
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  @override
  BrandColors copyWith({List<Color>? gradient}) =>
      BrandColors(gradient: gradient ?? this.gradient);

  @override
  BrandColors lerp(BrandColors? other, double t) {
    if (other == null) {
      return this;
    }
    return BrandColors(
      gradient: List<Color>.generate(
        gradient.length,
        (int i) => Color.lerp(
          gradient[i],
          other.gradient[i < other.gradient.length ? i : 0],
          t,
        )!,
      ),
    );
  }
}

extension BrandColorsContext on BuildContext {
  BrandColors get brand =>
      Theme.of(this).extension<BrandColors>() ??
      BrandColors(gradient: appPalettes.first.gradient);
}
