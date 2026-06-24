import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_text_styles.dart';
import '../data/models/supplier_stop_model.dart';
import '../providers/trip_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/eco_hero_card.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/metric_card.dart';
import '../widgets/optimized_route_mini_map.dart';
import '../widgets/premium_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/status_badge.dart';
import '../widgets/supplier_stop_card.dart';
import '../widgets/supplier_icon_box.dart';
import '../widgets/timeline_number.dart';

class TripSequenceScreen extends StatefulWidget {
  const TripSequenceScreen({
    super.key,
    this.onStartCollection,
    this.onViewReport,
  });

  final VoidCallback? onStartCollection;
  final VoidCallback? onViewReport;

  @override
  State<TripSequenceScreen> createState() => _TripSequenceScreenState();
}

class _TripSequenceScreenState extends State<TripSequenceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().loadTodayTrip();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.trip == null) {
          return const _PremiumLoadingView();
        }

        if (provider.errorMessage != null && provider.trip == null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            child: Column(
              children: [
                AppHeader(
                  title: 'Trip Sequence',
                  leadingIcon: Icons.menu_rounded,
                  trailing: [
                    HeaderIconButton(
                      icon: Icons.notifications_none_rounded,
                      showBadge: true,
                      onTap: () {},
                    ),
                    const HeaderAvatar(),
                  ],
                ),
                const Spacer(),
                ErrorView(
                  message: provider.errorMessage!,
                  onRetry: provider.loadTodayTrip,
                ),
                const Spacer(),
              ],
            ),
          );
        }

        final trip = provider.trip;
        if (trip == null) {
          return const Center(child: Text('No trip available.'));
        }

        final isComplete = trip.remainingStops == 0;
        final dateText =
            'Today, ${DateFormat('d MMM yyyy').format(trip.tripDate)}';

        return RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: provider.loadTodayTrip,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePadding,
              AppSizes.space12,
              AppSizes.pagePadding,
              AppSizes.space24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeader(
                  title: 'Trip Sequence',
                  leadingIcon: Icons.menu_rounded,
                  trailing: [
                    HeaderIconButton(
                      icon: Icons.notifications_none_rounded,
                      showBadge: true,
                      onTap: () {},
                    ),
                    const HeaderAvatar(),
                  ],
                ),
                const SizedBox(height: AppSizes.space20),
                EcoHeroCard(
                  title: "Today's Route Overview",
                  dateText: dateText,
                  subtitle:
                      '${trip.remainingStops} of ${trip.stops.length} stops remaining',
                  message:
                      'Collect more glass, create a greener tomorrow.',
                  variant: EcoHeroVariant.overview,
                ),
                const SizedBox(height: AppSizes.space16),
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        label: 'Total Route Distance',
                        value:
                            '${trip.totalRouteDistanceKm.toStringAsFixed(1)} km',
                        icon: Icons.route_rounded,
                        backgroundColor: AppColors.lightGreen,
                        accentColor: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: AppSizes.space12),
                    Expanded(
                      child: MetricCard(
                        label: 'Remaining Stops',
                        value: trip.remainingStops.toString(),
                        icon: Icons.flag_rounded,
                        backgroundColor: AppColors.softBlue,
                        accentColor: AppColors.blueAccent,
                      ),
                    ),
                  ],
                ),
                if (provider.isLoading) ...[
                  const SizedBox(height: AppSizes.space12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: const LinearProgressIndicator(minHeight: 4),
                  ),
                ],
                const SizedBox(height: AppSizes.space24),
                Row(
                  children: [
                    const Icon(
                      Icons.location_pin,
                      color: AppColors.primaryGreen,
                      size: 21,
                    ),
                    const SizedBox(width: AppSizes.space8),
                    Text("Today's Stop Order", style: AppTextStyles.cardTitle),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Refresh route',
                      onPressed:
                          provider.isLoading ? null : provider.refreshTrip,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.space12),
                _StopTimeline(stops: trip.stops),
                const SizedBox(height: AppSizes.space20),
                OptimizedRouteMiniMap(stopCount: trip.stops.length),
                const SizedBox(height: AppSizes.space20),
                PrimaryButton(
                  label: isComplete ? 'View Trip Report' : 'Start Collection',
                  icon: isComplete
                      ? Icons.summarize_rounded
                      : Icons.eco_rounded,
                  onPressed:
                      isComplete ? widget.onViewReport : widget.onStartCollection,
                ),
                const SizedBox(height: AppSizes.space12),
                const Center(child: _OptimizedChip()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HeaderIconButton(
          icon: Icons.menu_rounded,
          onTap: () {},
        ),
        const SizedBox(width: AppSizes.space12),
        const Expanded(
          child: Text(
            'Trip Sequence',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.screenHeading,
          ),
        ),
        _NotificationButton(onTap: () {}),
        const SizedBox(width: AppSizes.space10),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: AppColors.darkGreen,
            size: 22,
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Icon(icon, color: AppColors.darkGreen),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _HeaderIconButton(icon: Icons.notifications_none_rounded, onTap: onTap),
        Positioned(
          top: 7,
          right: 8,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: AppColors.dangerRed,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _RouteOverviewCard extends StatelessWidget {
  const _RouteOverviewCard({
    required this.dateText,
    required this.remainingStops,
    required this.totalStops,
  });

  final String dateText;
  final int remainingStops;
  final int totalStops;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.space20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radius24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                    const SizedBox(width: AppSizes.space8),
                    Flexible(
                      child: Text(
                        dateText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white.withOpacity(0.88),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.space16),
                Text(
                  "Today's Route Overview",
                  style: AppTextStyles.screenHeading.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: AppSizes.space8),
                Text(
                  '$remainingStops of $totalStops stops remaining',
                  style: AppTextStyles.cardTitle.copyWith(
                    color: Colors.white.withOpacity(0.92),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.space12),
                Text(
                  'Collect more glass, create a greener tomorrow.',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withOpacity(0.78),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.space12),
          const _EcoIllustration(),
        ],
      ),
    );
  }
}

class _EcoIllustration extends StatelessWidget {
  const _EcoIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            top: 10,
            right: 4,
            child: Icon(
              Icons.recycling_rounded,
              color: Colors.white.withOpacity(0.34),
              size: 48,
            ),
          ),
          Positioned(
            bottom: 8,
            left: 22,
            child: Transform.rotate(
              angle: -0.18,
              child: const _BottleShape(height: 72),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 14,
            child: Transform.rotate(
              angle: 0.16,
              child: const _BottleShape(height: 58, opacity: 0.72),
            ),
          ),
          const Positioned(
            left: 8,
            bottom: 36,
            child: Icon(Icons.eco_rounded, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}

class _BottleShape extends StatelessWidget {
  const _BottleShape({
    required this.height,
    this.opacity = 0.92,
  });

  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: height * 0.22,
          height: height * 0.22,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Container(
          width: height * 0.36,
          height: height * 0.72,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Container(
              width: height * 0.18,
              height: height * 0.26,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.45),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StopTimeline extends StatelessWidget {
  const _StopTimeline({required this.stops});

  final List<SupplierStopModel> stops;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < stops.length; i++)
          SupplierStopCard(
            stopOrder: stops[i].stopOrder,
            supplierName: stops[i].supplierName,
            address: stops[i].address,
            expectedKg: stops[i].expectedKg,
            status: stops[i].status,
            isNext: stops[i].status == 'Next',
            isCollected: stops[i].status == 'Collected',
            isLast: i == stops.length - 1,
          ),
      ],
    );
  }
}

class _TimelineStopTile extends StatelessWidget {
  const _TimelineStopTile({
    required this.stop,
    required this.isLast,
  });

  final SupplierStopModel stop;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isNext = stop.status == 'Next';
    final isCollected = stop.status == 'Collected';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              TimelineNumber(
                number: stop.stopOrder,
                isActive: isNext,
                isCompleted: isCollected,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isCollected
                          ? AppColors.primaryGreen.withOpacity(0.42)
                          : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSizes.space12),
          Expanded(
            child: PremiumCard(
              margin: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.space14),
              borderColor:
                  isNext ? AppColors.primaryGreen : AppColors.borderLight,
              backgroundColor: isNext ? AppColors.lightGreen : AppColors.surface,
              showShadow: isNext,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SupplierIconBox(
                    icon: isCollected
                        ? Icons.check_rounded
                        : Icons.storefront_rounded,
                    backgroundColor:
                        isNext ? AppColors.surface : AppColors.lightGreen,
                    iconColor: isCollected
                        ? AppColors.primaryGreen
                        : AppColors.darkGreen,
                  ),
                  const SizedBox(width: AppSizes.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                stop.supplierName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.cardTitle,
                              ),
                            ),
                            const SizedBox(width: AppSizes.space8),
                            StatusBadge(status: stop.status),
                          ],
                        ),
                        const SizedBox(height: AppSizes.space8),
                        Text(
                          stop.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: AppSizes.space12),
                        Wrap(
                          spacing: AppSizes.space8,
                          runSpacing: AppSizes.space8,
                          children: [
                            _MiniStopChip(
                              icon: Icons.scale_rounded,
                              label:
                                  '${stop.expectedKg.toStringAsFixed(0)} kg expected',
                            ),
                            _MiniStopChip(
                              icon: Icons.pin_drop_rounded,
                              label: stop.supplierCode,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStopChip extends StatelessWidget {
  const _MiniStopChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.mutedLabel.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptimizedRouteMap extends StatelessWidget {
  const _OptimizedRouteMap({required this.stops});

  final List<SupplierStopModel> stops;

  @override
  Widget build(BuildContext context) {
    final markerCount = stops.isEmpty
        ? 5
        : stops.length > 5
            ? 5
            : stops.length;

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
            child: CustomPaint(
              painter: _RouteMapPainter(markerCount: markerCount),
              child: Stack(
                children: [
                  for (var i = 0; i < markerCount; i++)
                    _RouteMarker(index: i, count: markerCount),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteMarker extends StatelessWidget {
  const _RouteMarker({
    required this.index,
    required this.count,
  });

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final points = _RouteMapPainter.pointsFor(
          Size(constraints.maxWidth, constraints.maxHeight),
          count,
        );
        final point = points[index];

        return Positioned(
          left: point.dx - 15,
          top: point.dy - 15,
          child: Container(
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
                  color:
                      index == 0 ? Colors.white : AppColors.primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        );
      },
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
          previous.dy < current.dy
              ? previous.dy - 26
              : previous.dy + 26,
        );
        path.quadraticBezierTo(control.dx, control.dy, current.dx, current.dy);
      }
    }

    canvas.drawPath(path, roadPaint);
    _drawDashedPath(canvas, path, routePaint);

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.75)
      ..strokeWidth = 1;
    for (var x = 28.0; x < size.width; x += 56) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 26.0; y < size.height; y += 52) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
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

class _OptimizedChip extends StatelessWidget {
  const _OptimizedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.primaryGreen,
            size: 16,
          ),
          const SizedBox(width: AppSizes.space8),
          Text(
            'Optimized with shortest route',
            style: AppTextStyles.mutedLabel.copyWith(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumLoadingView extends StatelessWidget {
  const _PremiumLoadingView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              title: 'Trip Sequence',
              leadingIcon: Icons.menu_rounded,
              trailing: [
                HeaderIconButton(
                  icon: Icons.notifications_none_rounded,
                  showBadge: true,
                  onTap: () {},
                ),
                const HeaderAvatar(),
              ],
            ),
            const SizedBox(height: AppSizes.space20),
            const LoadingSkeleton(height: 164, radius: AppSizes.radius24),
            const SizedBox(height: AppSizes.space16),
            const Row(
              children: [
                Expanded(
                  child: LoadingSkeleton(
                    height: 116,
                    radius: AppSizes.radius20,
                  ),
                ),
                SizedBox(width: AppSizes.space12),
                Expanded(
                  child: LoadingSkeleton(
                    height: 116,
                    radius: AppSizes.radius20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space24),
            const LoadingSkeleton(width: 170, height: 20),
            const SizedBox(height: AppSizes.space12),
            for (var i = 0; i < 4; i++) ...[
              const LoadingSkeleton(height: 112, radius: AppSizes.radius20),
              const SizedBox(height: AppSizes.space12),
            ],
          ],
        ),
      ),
    );
  }
}
