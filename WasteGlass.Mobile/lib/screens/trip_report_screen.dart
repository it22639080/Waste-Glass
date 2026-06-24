import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_text_styles.dart';
import '../data/models/trip_report_model.dart';
import '../providers/trip_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/eco_hero_card.dart';
import '../widgets/premium_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/shortfall_badge.dart';
import '../widgets/status_badge.dart';
import '../widgets/supplier_icon_box.dart';
import '../widgets/supplier_report_card.dart';

class TripReportScreen extends StatefulWidget {
  const TripReportScreen({super.key, this.onBackToSequence});

  final VoidCallback? onBackToSequence;

  @override
  State<TripReportScreen> createState() => _TripReportScreenState();
}

class _TripReportScreenState extends State<TripReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TripProvider>();
      provider.refreshUnsyncedCount();
      provider.loadReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, provider, _) {
        final report = provider.report;

        return RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: () async {
            await provider.loadReport();
            await provider.refreshUnsyncedCount();
          },
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
                  title: 'Trip Report',
                  leadingIcon: Icons.arrow_back_rounded,
                  onBack: widget.onBackToSequence,
                  trailing: [
                    HeaderIconButton(
                      icon: Icons.ios_share_rounded,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.space20),
                if (provider.isLoading && report == null)
                  const _ReportLoadingCard()
                else if (report == null)
                  _EmptyReportCard(
                    message: provider.errorMessage ??
                        'Report will appear after trip data loads.',
                    onBack: widget.onBackToSequence,
                  )
                else ...[
                  EcoHeroCard(
                    title: 'Trip Completed',
                    dateText: DateFormat('d MMM yyyy - h:mm a')
                        .format(report.completedAt ?? DateTime.now()),
                    message:
                        "Great job! You've helped keep glass out of landfill.",
                    variant: EcoHeroVariant.completed,
                  ),
                  const SizedBox(height: AppSizes.space16),
                  _MetricsRow(report: report),
                  const SizedBox(height: AppSizes.space24),
                  _SupplierSummaryHeader(
                    unsyncedCount: provider.unsyncedCount,
                  ),
                  const SizedBox(height: AppSizes.space12),
                  if (report.suppliers.isEmpty)
                    const _EmptySuppliersCard()
                  else
                    ...report.suppliers.map(
                      (item) => SupplierReportCard(
                        item: item,
                        address: _addressFor(provider, item.supplierCode),
                      ),
                    ),
                  const SizedBox(height: AppSizes.space16),
                  _EcoMessageCard(totalKg: report.totalCollectedKg),
                  const SizedBox(height: AppSizes.space20),
                  PrimaryButton(
                    label: 'Sync to Server',
                    icon: Icons.cloud_upload_rounded,
                    isLoading: provider.isSyncing,
                    onPressed: provider.syncLocalRecords,
                  ),
                  if (provider.syncMessage != null) ...[
                    const SizedBox(height: AppSizes.space12),
                    _SyncMessageCard(message: provider.syncMessage!),
                  ],
                  if (provider.errorMessage != null && report != null) ...[
                    const SizedBox(height: AppSizes.space12),
                    _ErrorMessageCard(message: provider.errorMessage!),
                  ],
                  const SizedBox(height: AppSizes.space12),
                  Center(
                    child: Text(
                      'Records safely stored on device until sync',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _addressFor(TripProvider provider, String supplierCode) {
    final stops = provider.trip?.stops ?? const [];
    for (final stop in stops) {
      if (stop.supplierCode == supplierCode) {
        return stop.address;
      }
    }
    return 'Address unavailable';
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: onBack ?? () {},
        ),
        const SizedBox(width: AppSizes.space12),
        const Expanded(
          child: Text(
            'Trip Report',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.screenHeading,
          ),
        ),
        _RoundIconButton(
          icon: Icons.ios_share_rounded,
          onTap: () {},
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
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
            boxShadow: AppColors.softShadow,
          ),
          child: Icon(icon, color: AppColors.darkGreen),
        ),
      ),
    );
  }
}

class _CompletionHero extends StatelessWidget {
  const _CompletionHero({required this.report});

  final TripReportModel report;

  @override
  Widget build(BuildContext context) {
    final completedAt = report.completedAt ?? DateTime.now();
    final dateText = DateFormat('d MMM yyyy - h:mm a').format(completedAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.space20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radius24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.24),
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
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.24)),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: AppSizes.space14),
                Text(
                  'Trip Completed',
                  style: AppTextStyles.screenHeading.copyWith(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(height: AppSizes.space8),
                Text(
                  "Great job! You've helped keep glass out of landfill.",
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withOpacity(0.82),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.space14),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white.withOpacity(0.86),
                      size: 15,
                    ),
                    const SizedBox(width: AppSizes.space8),
                    Expanded(
                      child: Text(
                        dateText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white.withOpacity(0.86),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.space10),
          const _HeroIllustration(),
        ],
      ),
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 94,
      height: 128,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.13),
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            top: 8,
            right: 6,
            child: Icon(
              Icons.recycling_rounded,
              color: Colors.white.withOpacity(0.32),
              size: 50,
            ),
          ),
          Positioned(
            bottom: 10,
            left: 20,
            child: Transform.rotate(
              angle: -0.16,
              child: const _Bottle(height: 74),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 12,
            child: Transform.rotate(
              angle: 0.18,
              child: const _Bottle(height: 58, opacity: 0.74),
            ),
          ),
          Positioned(
            left: 6,
            bottom: 38,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bottle extends StatelessWidget {
  const _Bottle({
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

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({required this.report});

  final TripReportModel report;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ReportMetricCard(
            label: 'Collected',
            value: '${report.totalCollectedKg.toStringAsFixed(0)} kg',
            icon: Icons.recycling_rounded,
            color: AppColors.primaryGreen,
            background: AppColors.lightGreen,
          ),
        ),
        const SizedBox(width: AppSizes.space8),
        Expanded(
          child: _ReportMetricCard(
            label: 'Distance',
            value: '${report.totalRouteDistanceKm.toStringAsFixed(1)} km',
            icon: Icons.route_rounded,
            color: AppColors.blueAccent,
            background: AppColors.softBlue,
          ),
        ),
        const SizedBox(width: AppSizes.space8),
        Expanded(
          child: _ReportMetricCard(
            label: 'Duration',
            value: _formatDuration(report.duration),
            icon: Icons.timer_rounded,
            color: AppColors.darkGreen,
            background: AppColors.mintGreen,
          ),
        ),
      ],
    );
  }
}

class _ReportMetricCard extends StatelessWidget {
  const _ReportMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(AppSizes.space12),
      backgroundColor: background,
      borderColor: color.withOpacity(0.12),
      showShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSizes.space10),
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: AppSizes.space6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: AppTextStyles.statNumber.copyWith(
                color: color,
                fontSize: 21,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupplierSummaryHeader extends StatelessWidget {
  const _SupplierSummaryHeader({required this.unsyncedCount});

  final int unsyncedCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.groups_rounded,
          color: AppColors.primaryGreen,
          size: 22,
        ),
        const SizedBox(width: AppSizes.space8),
        Expanded(
          child: Text('Supplier Summary', style: AppTextStyles.cardTitle),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color:
                unsyncedCount > 0 ? AppColors.softBlue : AppColors.lightGreen,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: unsyncedCount > 0
                  ? AppColors.blueAccent.withOpacity(0.16)
                  : AppColors.primaryGreen.withOpacity(0.16),
            ),
          ),
          child: Text(
            'Unsynced records $unsyncedCount',
            style: AppTextStyles.mutedLabel.copyWith(
              color: unsyncedCount > 0
                  ? AppColors.blueAccent
                  : AppColors.primaryGreen,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _SupplierSummaryCard extends StatelessWidget {
  const _SupplierSummaryCard({
    required this.item,
    required this.address,
  });

  final SupplierReportItemModel item;
  final String address;

  @override
  Widget build(BuildContext context) {
    final shortfallKg = item.expectedKg - item.totalKg;
    final hasShortfall = item.totalKg < item.expectedKg;
    final collectedColor =
        hasShortfall ? AppColors.warningOrange : AppColors.primaryGreen;

    return PremiumCard(
      margin: const EdgeInsets.only(bottom: AppSizes.space12),
      borderColor:
          hasShortfall ? AppColors.warningOrange.withOpacity(0.32) : AppColors.borderLight,
      backgroundColor:
          hasShortfall ? AppColors.warningOrange.withOpacity(0.06) : AppColors.surface,
      showShadow: !hasShortfall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SupplierIconBox(
                icon: hasShortfall
                    ? Icons.warning_amber_rounded
                    : Icons.storefront_rounded,
                backgroundColor:
                    hasShortfall ? AppColors.warningOrange.withOpacity(0.10) : AppColors.lightGreen,
                iconColor:
                    hasShortfall ? AppColors.warningOrange : AppColors.primaryGreen,
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
                            item.supplierName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.cardTitle,
                          ),
                        ),
                        const SizedBox(width: AppSizes.space8),
                        hasShortfall
                            ? const ShortfallBadge(message: 'Shortfall')
                            : const StatusBadge(status: 'Collected'),
                      ],
                    ),
                    const SizedBox(height: AppSizes.space6),
                    Text(
                      address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space14),
          Row(
            children: [
              Expanded(
                child: _KgColumn(
                  label: 'Expected',
                  value: '${item.expectedKg.toStringAsFixed(0)} kg',
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: AppSizes.space10),
              Expanded(
                child: _KgColumn(
                  label: 'Collected',
                  value: '${item.totalKg.toStringAsFixed(0)} kg',
                  color: collectedColor,
                ),
              ),
              const SizedBox(width: AppSizes.space10),
              Expanded(
                child: _KgColumn(
                  label: 'Estimated',
                  value: '${item.expectedKg.toStringAsFixed(0)} kg',
                  color: AppColors.blueAccent,
                ),
              ),
            ],
          ),
          if (hasShortfall) ...[
            const SizedBox(height: AppSizes.space10),
            Text(
              '${shortfallKg.toStringAsFixed(0)} kg less',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.warningOrange,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _KgColumn extends StatelessWidget {
  const _KgColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radius16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: AppSizes.space4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: AppTextStyles.cardTitle.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _EcoMessageCard extends StatelessWidget {
  const _EcoMessageCard({required this.totalKg});

  final double totalKg;

  @override
  Widget build(BuildContext context) {
    final bottles = (totalKg * 2.3).round();

    return PremiumCard(
      backgroundColor: AppColors.lightGreen,
      borderColor: AppColors.primaryGreen.withOpacity(0.14),
      showShadow: false,
      child: Row(
        children: [
          const SupplierIconBox(
            icon: Icons.eco_rounded,
            backgroundColor: AppColors.surface,
            iconColor: AppColors.primaryGreen,
          ),
          const SizedBox(width: AppSizes.space12),
          Expanded(
            child: Text(
              'You collected the equivalent of $bottles glass bottles!',
              style: AppTextStyles.cardTitle.copyWith(
                color: AppColors.darkGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncMessageCard extends StatelessWidget {
  const _SyncMessageCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final isSuccess = message.contains('failed, 0') ||
        message.contains('failed: 0') ||
        message.contains('0 failed');

    return PremiumCard(
      showShadow: false,
      backgroundColor: isSuccess ? AppColors.lightGreen : AppColors.softBlue,
      borderColor: isSuccess
          ? AppColors.primaryGreen.withOpacity(0.18)
          : AppColors.blueAccent.withOpacity(0.18),
      child: Row(
        children: [
          SupplierIconBox(
            icon: isSuccess
                ? Icons.check_circle_rounded
                : Icons.info_outline_rounded,
            backgroundColor: AppColors.surface,
            iconColor: isSuccess ? AppColors.primaryGreen : AppColors.blueAccent,
            size: 40,
          ),
          const SizedBox(width: AppSizes.space12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: isSuccess ? AppColors.primaryGreen : AppColors.blueAccent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorMessageCard extends StatelessWidget {
  const _ErrorMessageCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      showShadow: false,
      backgroundColor: AppColors.dangerRed.withOpacity(0.06),
      borderColor: AppColors.dangerRed.withOpacity(0.18),
      child: Row(
        children: [
          const SupplierIconBox(
            icon: Icons.error_outline_rounded,
            backgroundColor: AppColors.surface,
            iconColor: AppColors.dangerRed,
            size: 40,
          ),
          const SizedBox(width: AppSizes.space12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.dangerRed,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportLoadingCard extends StatelessWidget {
  const _ReportLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const PremiumCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.space32),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: AppColors.primaryGreen),
              SizedBox(height: AppSizes.space14),
              Text('Loading trip report...'),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyReportCard extends StatelessWidget {
  const _EmptyReportCard({
    required this.message,
    required this.onBack,
  });

  final String message;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        children: [
          const SupplierIconBox(
            icon: Icons.summarize_outlined,
            size: 54,
          ),
          const SizedBox(height: AppSizes.space12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSizes.space16),
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.route_outlined),
            label: const Text('Back to Sequence'),
          ),
        ],
      ),
    );
  }
}

class _EmptySuppliersCard extends StatelessWidget {
  const _EmptySuppliersCard();

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      showShadow: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.space16),
          child: Text(
            'No supplier records yet.',
            style: AppTextStyles.caption,
          ),
        ),
      ),
    );
  }
}

String _formatDuration(int minutes) {
  if (minutes < 60) {
    return '${minutes}m';
  }

  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  return remainder == 0 ? '${hours}h' : '${hours}h ${remainder}m';
}
