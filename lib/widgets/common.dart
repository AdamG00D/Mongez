import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/palettes.dart';

class MongezLogo extends StatelessWidget {
  const MongezLogo({this.size = 40, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.26),
      child: Image.asset(
        'assets/icon.png',
        width: size,
        height: size,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

/// Card filled with the active palette gradient.
class GradientCard extends StatelessWidget {
  const GradientCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 26,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: brand.linear,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: brand.gradient[1].withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: <Widget>[
            PositionedDirectional(
              top: -40,
              end: -30,
              child: _Circle(size: 140, alpha: 0.12),
            ),
            PositionedDirectional(
              bottom: -50,
              start: -20,
              child: _Circle(size: 120, alpha: 0.08),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }
}

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    required this.value,
    this.size = 84,
    this.stroke = 9,
    this.color,
    this.trackColor,
    this.child,
    super.key,
  });

  final double value;
  final double size;
  final double stroke;
  final Color? color;
  final Color? trackColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value.clamp(0, 1)),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double animated, Widget? inner) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(
              value: animated,
              stroke: stroke,
              color: color ?? scheme.primary,
              track: trackColor ?? scheme.primary.withValues(alpha: 0.14),
            ),
            child: Center(child: inner),
          ),
        );
      },
      child: child,
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.stroke,
    required this.color,
    required this.track,
  });

  final double value;
  final double stroke;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, base..color = track);
    if (value > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * value,
        false,
        base..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {this.trailing, this.padding, super.key});

  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(4, 18, 4, 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tint = color ?? scheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: tint, size: 20),
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: context.brand.linear,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (action != null) ...<Widget>[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

/// Simple vertical bar chart. [labels] and [values] must have equal length.
class MiniBarChart extends StatelessWidget {
  const MiniBarChart({
    required this.values,
    required this.labels,
    this.highlightIndex,
    this.valueLabel,
    this.height = 130,
    super.key,
  });

  final List<double> values;
  final List<String> labels;
  final int? highlightIndex;
  final String Function(double value)? valueLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxValue = values.fold<double>(0, math.max);
    final brand = context.brand;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List<Widget>.generate(values.length, (int i) {
          final ratio = maxValue == 0 ? 0.0 : values[i] / maxValue;
          final highlighted = i == (highlightIndex ?? values.length - 1);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  if (valueLabel != null && values[i] > 0)
                    FittedBox(
                      child: Text(
                        valueLabel!(values[i]),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: highlighted
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: ratio),
                      duration: Duration(milliseconds: 450 + i * 60),
                      curve: Curves.easeOutCubic,
                      builder: (BuildContext context, double r, _) {
                        return FractionallySizedBox(
                          heightFactor: math.max(r, 0.04),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: highlighted
                                  ? LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: <Color>[
                                        brand.gradient[0],
                                        brand.gradient[2],
                                      ],
                                    )
                                  : null,
                              color: highlighted
                                  ? null
                                  : scheme.primary.withValues(alpha: 0.22),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: highlighted
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: highlighted
                          ? scheme.onSurface
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Short confetti burst drawn over the current screen.
void showCelebration(BuildContext context) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) {
    return;
  }
  late OverlayEntry entry;
  entry = OverlayEntry(builder: (_) => _Confetti(onDone: () => entry.remove()));
  overlay.insert(entry);
}

class _Confetti extends StatefulWidget {
  const _Confetti({required this.onDone});

  final VoidCallback onDone;

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  final List<_Piece> _pieces = <_Piece>[];

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    const colors = <Color>[
      Color(0xFF6D5DFC),
      Color(0xFF14C2D6),
      Color(0xFFF59E0B),
      Color(0xFFEC4899),
      Color(0xFF10B981),
      Color(0xFF3B82F6),
    ];
    for (var i = 0; i < 70; i++) {
      _pieces.add(
        _Piece(
          x: random.nextDouble(),
          speed: 0.6 + random.nextDouble() * 0.7,
          drift: (random.nextDouble() - 0.5) * 0.3,
          spin: random.nextDouble() * 8,
          size: 5 + random.nextDouble() * 6,
          color: colors[random.nextInt(colors.length)],
          delay: random.nextDouble() * 0.25,
        ),
      );
    }
    _controller.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, _) => CustomPaint(
          size: MediaQuery.sizeOf(context),
          painter: _ConfettiPainter(_pieces, _controller.value),
        ),
      ),
    );
  }
}

class _Piece {
  _Piece({
    required this.x,
    required this.speed,
    required this.drift,
    required this.spin,
    required this.size,
    required this.color,
    required this.delay,
  });

  final double x;
  final double speed;
  final double drift;
  final double spin;
  final double size;
  final Color color;
  final double delay;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t);

  final List<_Piece> pieces;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final piece in pieces) {
      final local = ((t - piece.delay) / (1 - piece.delay)).clamp(0.0, 1.0);
      if (local <= 0) {
        continue;
      }
      final dx = (piece.x + piece.drift * local) * size.width;
      final dy = -20 + local * piece.speed * size.height;
      paint.color = piece.color.withValues(alpha: 1 - local * 0.6);
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(piece.spin * local * math.pi);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.size,
            height: piece.size * 0.55,
          ),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
