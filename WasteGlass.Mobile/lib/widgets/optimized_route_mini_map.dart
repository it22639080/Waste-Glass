import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_text_styles.dart';
import 'premium_card.dart';

class OptimizedRouteMiniMap extends StatelessWidget {
  const OptimizedRouteMiniMap({
    super.key,
    this.stopCount = 5,
  });

  final int stopCount;

  @override
  Widget build(BuildContext context) {
    final markerCount = stopCount <= 0
        ? 5
        : stopCount > 5
            ? 5
            : stopCount;

    return PremiumCard(
      backgroundColor: const Color(0xFFF7FBF8),
      borderColor: AppColors.borderLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Optimized Route',
                  style: AppTextStyles.mutedLabel.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.map_rounded, color: AppColors.primaryGreen),
            ],
          ),
          const SizedBox(height: AppSizes.space12),
          SizedBox(
            height: 154,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final points = _RouteMapPainter.pointsFor(
                  Size(constraints.maxWidth, constraints.maxHeight),
                  markerCount,
                );

                return CustomPaint(
                  painter: _RouteMapPainter(markerCount: markerCount),
                  child: Stack(
                    children: [
                      for (var i = 0; i < points.length; i++)
                        Positioned(
                          left: points[i].dx - 15,
                          top: points[i].dy - 15,
                          child: _RouteMarker(index: i),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteMarker extends StatelessWidget {
  const _RouteMarker({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: index == 0 ? AppColors.primaryGreen : AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryGreen, width: 2),
        boxShadow: AppColors.softShadow,
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: index == 0 ? Colors.white : AppColors.primaryGreen,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _RouteMapPainter extends CustomPainter {
  _RouteMapPainter({required this.markerCount});

  final int markerCount;

  static List<Offset> pointsFor(Size size, int count) {
    final normalized = <Offset>[
      const Offset(0.12, 0.70),
      const Offset(0.32, 0.36),
      const Offset(0.52, 0.58),
      const Offset(0.72, 0.28),
      const Offset(0.88, 0.62),
    ];

    return normalized
        .take(count)
        .map((p) => Offset(p.dx * size.width, p.dy * size.height))
        .toList();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final points = pointsFor(size, markerCount);
    final backgroundPaint = Paint()
      ..color = AppColors.lightGreen.withOpacity(0.45)
      ..style = PaintingStyle.fill;
    final roadPaint = Paint()
      ..color = AppColors.borderLight
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final routePaint = Paint()
      ..color = AppColors.primaryGreen
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(AppSizes.radius16),
      ),
      backgroundPaint,
    );

    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < points.length; i++) {
        final previous = points[i - 1];
        final current = points[i];
        final control = Offset(
          (previous.dx + current.dx) / 2,
          previous.dy < current.dy ? previous.dy - 26 : previous.dy + 26,
        );
        path.quadraticBezierTo(control.dx, control.dy, current.dx, current.dy);
      }
    }

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.75)
      ..strokeWidth = 1;
    for (var x = 28.0; x < size.width; x += 56) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 26.0; y < size.height; y += 52) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.drawPath(path, roadPaint);
    _drawDashedPath(canvas, path, routePaint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      const dash = 9.0;
      const gap = 7.0;
      while (distance < metric.length) {
        final next = distance + dash;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RouteMapPainter oldDelegate) {
    return oldDelegate.markerCount != markerCount;
  }
}
