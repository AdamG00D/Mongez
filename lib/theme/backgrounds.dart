import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import 'palettes.dart';

class BackgroundOption {
  const BackgroundOption(this.id, this.name, this.icon);

  final String id;
  final String name;
  final IconData icon;
}

const List<BackgroundOption> backgroundOptions = <BackgroundOption>[
  BackgroundOption('plain', 'سادة', Icons.crop_square_rounded),
  BackgroundOption('soft', 'هادئ', Icons.gradient_rounded),
  BackgroundOption('aurora', 'شفق', Icons.blur_on_rounded),
  BackgroundOption('mesh', 'متدرّج', Icons.auto_awesome_rounded),
  BackgroundOption('dots', 'نقاط', Icons.grain_rounded),
  BackgroundOption('waves', 'أمواج', Icons.waves_rounded),
  BackgroundOption('grid', 'شبكة', Icons.grid_4x4_rounded),
  BackgroundOption('stars', 'نجوم', Icons.star_outline_rounded),
];

/// Paints the user's chosen background behind [child].
class AppBackground extends StatelessWidget {
  const AppBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        BackgroundLayer(
          id: settings.backgroundId,
          customPath: settings.customBackgroundPath,
          dim: settings.backgroundDim,
        ),
        child,
      ],
    );
  }
}

class BackgroundLayer extends StatelessWidget {
  const BackgroundLayer({
    required this.id,
    this.customPath,
    this.dim = 0.35,
    super.key,
  });

  final String id;
  final String? customPath;
  final double dim;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.brand.gradient;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = scheme.surface;

    if (id == 'custom' && customPath != null) {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.file(
            File(customPath!),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => ColoredBox(color: surface),
          ),
          ColoredBox(color: surface.withValues(alpha: dim.clamp(0.0, 0.85))),
        ],
      );
    }

    return RepaintBoundary(
      child: CustomPaint(
        painter: _BackgroundPainter(
          id: id,
          colors: colors,
          surface: surface,
          isDark: isDark,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  _BackgroundPainter({
    required this.id,
    required this.colors,
    required this.surface,
    required this.isDark,
  });

  final String id;
  final List<Color> colors;
  final Color surface;
  final bool isDark;

  double get _a => isDark ? 0.22 : 0.16;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = surface);

    switch (id) {
      case 'plain':
        return;
      case 'soft':
        canvas.drawRect(
          rect,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                colors[1].withValues(alpha: _a + 0.04),
                colors[2].withValues(alpha: _a * 0.4),
                surface.withValues(alpha: 0),
              ],
              stops: const <double>[0, 0.45, 1],
            ).createShader(rect),
        );
      case 'aurora':
        _blob(
          canvas,
          size,
          Offset(size.width * 0.9, size.height * 0.05),
          size.width * 0.9,
          colors[0],
        );
        _blob(
          canvas,
          size,
          Offset(size.width * 0.05, size.height * 0.35),
          size.width * 0.8,
          colors[2],
        );
        _blob(
          canvas,
          size,
          Offset(size.width * 0.8, size.height * 0.85),
          size.width * 0.9,
          colors[1],
        );
      case 'mesh':
        canvas.drawRect(
          rect,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: colors
                  .map((Color c) => c.withValues(alpha: _a + 0.1))
                  .toList(),
            ).createShader(rect),
        );
        _blob(
          canvas,
          size,
          Offset(size.width * 0.2, size.height * 0.1),
          size.width,
          surface.withValues(alpha: 0.9),
          alpha: isDark ? 0.5 : 0.7,
        );
      case 'dots':
        _blob(canvas, size, Offset(size.width, 0), size.width, colors[1]);
        final paint = Paint()
          ..color = colors[1].withValues(alpha: isDark ? 0.16 : 0.13);
        const gap = 22.0;
        for (var y = gap / 2; y < size.height; y += gap) {
          for (var x = gap / 2; x < size.width; x += gap) {
            canvas.drawCircle(Offset(x, y), 1.4, paint);
          }
        }
      case 'waves':
        _blob(canvas, size, Offset(0, 0), size.width * 0.9, colors[0]);
        for (var i = 0; i < 3; i++) {
          final path = Path();
          final baseY = size.height * (0.72 + i * 0.09);
          path.moveTo(0, baseY);
          for (var x = 0.0; x <= size.width; x += 8) {
            path.lineTo(
              x,
              baseY +
                  math.sin((x / size.width * 2 * math.pi) + i * 1.3) *
                      (18 + i * 6),
            );
          }
          path
            ..lineTo(size.width, size.height)
            ..lineTo(0, size.height)
            ..close();
          canvas.drawPath(
            path,
            Paint()
              ..color = colors[i % colors.length].withValues(
                alpha: (isDark ? 0.14 : 0.1) + i * 0.03,
              ),
          );
        }
      case 'grid':
        _blob(canvas, size, Offset(size.width * 0.5, 0), size.width, colors[1]);
        final paint = Paint()
          ..color = colors[1].withValues(alpha: isDark ? 0.1 : 0.08)
          ..strokeWidth = 1;
        const gap = 32.0;
        for (var x = 0.0; x < size.width; x += gap) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
        }
        for (var y = 0.0; y < size.height; y += gap) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
      case 'stars':
        _blob(
          canvas,
          size,
          Offset(size.width * 0.1, size.height * 0.1),
          size.width,
          colors[0],
        );
        _blob(
          canvas,
          size,
          Offset(size.width, size.height * 0.6),
          size.width,
          colors[2],
        );
        final random = math.Random(7);
        final paint = Paint();
        for (var i = 0; i < 90; i++) {
          final o = Offset(
            random.nextDouble() * size.width,
            random.nextDouble() * size.height,
          );
          paint.color = (isDark ? Colors.white : colors[1]).withValues(
            alpha: 0.12 + random.nextDouble() * (isDark ? 0.45 : 0.2),
          );
          canvas.drawCircle(o, 0.6 + random.nextDouble() * 1.4, paint);
        }
      default:
        return;
    }
  }

  void _blob(
    Canvas canvas,
    Size size,
    Offset center,
    double radius,
    Color color, {
    double? alpha,
  }) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            color.withValues(alpha: alpha ?? _a + 0.06),
            color.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) =>
      oldDelegate.id != id ||
      oldDelegate.surface != surface ||
      oldDelegate.isDark != isDark ||
      oldDelegate.colors != colors;
}
