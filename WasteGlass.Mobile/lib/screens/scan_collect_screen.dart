import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_text_styles.dart';
import '../data/models/supplier_stop_model.dart';
import '../providers/trip_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/barcode_scanner_frame.dart';
import '../widgets/collection_input_card.dart';
import '../widgets/eco_hero_card.dart';
import '../widgets/premium_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/status_badge.dart';
import '../widgets/supplier_icon_box.dart';

class ScanCollectScreen extends StatefulWidget {
  const ScanCollectScreen({
    super.key,
    this.onViewReport,
    this.onBack,
  });

  final VoidCallback? onViewReport;
  final VoidCallback? onBack;

  @override
  State<ScanCollectScreen> createState() => _ScanCollectScreenState();
}

class _ScanCollectScreenState extends State<ScanCollectScreen> {
  final _scannerController = MobileScannerController();
  final _clearController = TextEditingController();
  final _colouredController = TextEditingController();
  String _condition = 'Good';
  bool _handledScan = false;
  bool _hasConfirmedCollection = false;
  bool _lastSubmitSynced = false;
  String? _lastConfirmedSupplierCode;
  String? _nextReadySupplierCode;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _clearController.addListener(_onFormChanged);
    _colouredController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _clearController
      ..removeListener(_onFormChanged)
      ..dispose();
    _colouredController
      ..removeListener(_onFormChanged)
      ..dispose();
    super.dispose();
  }

  void _onFormChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, provider, _) {
        final trip = provider.trip;
        final stop = provider.currentNextStop;
        final formUnlocked = provider.isFormUnlocked && stop != null;
        final totalStops = trip?.stops.length ?? 0;
        final stopOrder = stop?.stopOrder ?? totalStops;
        final formValid = _isFormValid(formUnlocked);

        return SingleChildScrollView(
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
                title: 'Scan & Collect',
                leadingIcon: Icons.arrow_back_rounded,
                onBack: widget.onBack,
                trailing: [
                  HeaderIconButton(
                    icon: Icons.description_outlined,
                    onTap: widget.onViewReport ?? () {},
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.space20),
              _StopProgress(
                current: stopOrder <= 0 ? 1 : stopOrder,
                total: totalStops <= 0 ? 1 : totalStops,
              ),
              const SizedBox(height: AppSizes.space20),
              if (stop == null)
                const _CompleteTripCard()
              else
                EcoHeroCard(
                  title: 'Next Supplier',
                  variant: EcoHeroVariant.nextSupplier,
                  supplierName: stop.supplierName,
                  address: stop.address,
                  expectedKg: stop.expectedKg,
                  status: 'Next',
                ),
              if (stop != null) ...[
                const SizedBox(height: AppSizes.space12),
                _ExpectedBarcodeCard(supplierCode: stop.supplierCode),
              ],
              const SizedBox(height: AppSizes.space16),
              BarcodeScannerFrame(
                controller: _scannerController,
                success: provider.isFormUnlocked,
                error: provider.lastScannedCode != null &&
                    !provider.isFormUnlocked,
                onDetect: (code) {
                  if (_handledScan || provider.isSubmitting) return;
                  _handledScan = true;
                  provider.handleBarcode(code);
                  setState(() {
                    _hasConfirmedCollection = false;
                    _lastSubmitSynced = false;
                  });
                },
              ),
              const SizedBox(height: AppSizes.space16),
              _VerificationCard(provider: provider),
              const SizedBox(height: AppSizes.space16),
              CollectionInputCard(
                clearController: _clearController,
                colouredController: _colouredController,
                selectedCondition: _condition,
                enabled: formUnlocked,
                error: _formError,
                onConditionChanged: (value) {
                  setState(() {
                    _condition = value;
                    _formError = null;
                  });
                },
              ),
              if (_hasConfirmedCollection) ...[
                const SizedBox(height: AppSizes.space12),
                _CollectionSavedCard(
                  isSynced: _lastSubmitSynced,
                  supplierCode: _lastConfirmedSupplierCode,
                  nextSupplierCode: _nextReadySupplierCode,
                ),
              ],
              if (provider.errorMessage != null) ...[
                const SizedBox(height: AppSizes.space12),
                _OfflineInfoCard(message: provider.errorMessage!),
              ],
              const SizedBox(height: AppSizes.space20),
              PrimaryButton(
                label: 'Confirm Collection',
                icon: Icons.check_rounded,
                isLoading: provider.isSubmitting,
                onPressed: formValid && stop != null
                    ? () => _confirmCollection(provider)
                    : null,
              ),
              const SizedBox(height: AppSizes.space10),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppSizes.space8,
                  runSpacing: AppSizes.space8,
                  children: [
                    TextButton.icon(
                      onPressed: () => _resetScanner(provider),
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: const Text('Scan Again'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        textStyle:
                            AppTextStyles.cardTitle.copyWith(fontSize: 14),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: widget.onViewReport,
                      icon: const Icon(Icons.summarize_outlined),
                      label: const Text('View Trip Report'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.blueAccent,
                        textStyle:
                            AppTextStyles.cardTitle.copyWith(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isFormValid(bool formUnlocked) {
    if (!formUnlocked) return false;

    final clearText = _clearController.text.trim();
    final colouredText = _colouredController.text.trim();
    final clearKg = double.tryParse(clearText);
    final colouredKg = double.tryParse(colouredText);

    if (clearText.isNotEmpty && clearKg == null) return false;
    if (colouredText.isNotEmpty && colouredKg == null) return false;

    final clear = clearKg ?? 0;
    final coloured = colouredKg ?? 0;
    return clear >= 0 && coloured >= 0 && clear + coloured > 0;
  }

  Future<void> _confirmCollection(TripProvider provider) async {
    final stop = provider.currentNextStop;
    if (stop == null) return;

    final clearText = _clearController.text.trim();
    final colouredText = _colouredController.text.trim();
    final clearKg = double.tryParse(clearText);
    final colouredKg = double.tryParse(colouredText);
    final error = _validateForm(
      clearText: clearText,
      colouredText: colouredText,
      clearKg: clearKg,
      colouredKg: colouredKg,
    );

    if (error != null) {
      setState(() => _formError = error);
      return;
    }

    setState(() => _formError = null);
    final confirmedSupplierCode = stop.supplierCode;

    final ok = await provider.submitCollection(
      supplierCode: confirmedSupplierCode,
      clearGlassKg: clearKg ?? 0,
      colouredGlassKg: colouredKg ?? 0,
      condition: _condition,
    );

    if (!ok) return;

    setState(() {
      _clearController.clear();
      _colouredController.clear();
      _condition = 'Good';
      _handledScan = true;
      _hasConfirmedCollection = true;
      _lastSubmitSynced = provider.scanMessage == 'Collection saved and synced.';
      _lastConfirmedSupplierCode = confirmedSupplierCode;
      _nextReadySupplierCode = provider.currentNextStop?.supplierCode;
    });

    if (!mounted) return;
    await _showCollectionResultDialog(
      provider: provider,
      supplierCode: confirmedSupplierCode,
      synced: _lastSubmitSynced,
      nextSupplierCode: _nextReadySupplierCode,
    );
  }

  void _resetScanner(TripProvider provider) {
    _handledScan = false;
    provider.resetScan();
    setState(() {
      _formError = null;
      _hasConfirmedCollection = false;
      _lastSubmitSynced = false;
      _lastConfirmedSupplierCode = null;
      _nextReadySupplierCode = null;
    });
  }

  Future<void> _showCollectionResultDialog({
    required TripProvider provider,
    required String supplierCode,
    required bool synced,
    required String? nextSupplierCode,
  }) async {
    final shouldScanNext = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final hasNext = nextSupplierCode != null;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius20),
          ),
          title: Row(
            children: [
              const SupplierIconBox(
                icon: Icons.check_circle_rounded,
                backgroundColor: AppColors.lightGreen,
                iconColor: AppColors.primaryGreen,
                size: 40,
              ),
              const SizedBox(width: AppSizes.space10),
              Expanded(
                child: Text(
                  'Collection Successful',
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                synced
                    ? '$supplierCode collection was saved and synced.'
                    : '$supplierCode collection was saved locally. You can sync it later from Trip Report.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppSizes.space12),
              if (hasNext)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.space12),
                  decoration: BoxDecoration(
                    color: AppColors.softBlue,
                    borderRadius: BorderRadius.circular(AppSizes.radius16),
                    border: Border.all(
                      color: AppColors.blueAccent.withOpacity(0.14),
                    ),
                  ),
                  child: Text(
                    'Next expected barcode: $nextSupplierCode',
                    style: AppTextStyles.cardTitle.copyWith(
                      color: AppColors.blueAccent,
                    ),
                  ),
                )
              else
                Text(
                  'All available collections are complete. Open Trip Report to review totals.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(hasNext ? 'View Report' : 'Open Report'),
            ),
            if (hasNext)
              ElevatedButton.icon(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Scan Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (shouldScanNext == true && nextSupplierCode != null) {
      _resetScanner(provider);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Ready to scan $nextSupplierCode'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primaryGreen,
            duration: const Duration(seconds: 2),
          ),
        );
    } else {
      widget.onViewReport?.call();
    }
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
            'Scan & Collect',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.screenHeading,
          ),
        ),
        _RoundIconButton(
          icon: Icons.description_outlined,
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

class _StopProgress extends StatelessWidget {
  const _StopProgress({
    required this.current,
    required this.total,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSizes.space8,
        runSpacing: AppSizes.space8,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.primaryGreen.withOpacity(0.18)),
            ),
            child: Text(
              'Stop $current of $total',
              style: AppTextStyles.mutedLabel.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          for (var i = 1; i <= total; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: i == current ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == current
                    ? AppColors.primaryGreen
                    : AppColors.borderLight,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
        ],
      ),
    );
  }
}

class _NextSupplierCard extends StatelessWidget {
  const _NextSupplierCard({required this.stop});

  final SupplierStopModel stop;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      backgroundColor: AppColors.lightGreen,
      borderColor: AppColors.primaryGreen.withOpacity(0.12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SupplierIconBox(
            icon: Icons.storefront_rounded,
            backgroundColor: AppColors.surface,
            iconColor: AppColors.primaryGreen,
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
                        'Next Supplier',
                        style: AppTextStyles.mutedLabel.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const StatusBadge(status: 'Next'),
                  ],
                ),
                const SizedBox(height: AppSizes.space6),
                Text(
                  stop.supplierName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: AppSizes.space10),
                _SupplierLine(
                  icon: Icons.location_on_rounded,
                  text: stop.address,
                ),
                const SizedBox(height: AppSizes.space6),
                _SupplierLine(
                  icon: Icons.local_drink_rounded,
                  text: '${stop.expectedKg.toStringAsFixed(0)} kg expected',
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.space8),
          const _GlassIllustration(),
        ],
      ),
    );
  }
}

class _SupplierLine extends StatelessWidget {
  const _SupplierLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primaryGreen),
        const SizedBox(width: AppSizes.space6),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(color: AppColors.textDark),
          ),
        ),
      ],
    );
  }
}

class _GlassIllustration extends StatelessWidget {
  const _GlassIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 86,
      child: Stack(
        children: [
          Positioned(
            top: 6,
            right: 2,
            child: Icon(
              Icons.recycling_rounded,
              size: 34,
              color: AppColors.primaryGreen.withOpacity(0.20),
            ),
          ),
          Positioned(
            bottom: 2,
            left: 8,
            child: Transform.rotate(
              angle: -0.14,
              child: Container(
                width: 22,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.22),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Transform.rotate(
              angle: 0.14,
              child: Container(
                width: 18,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.blueAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.blueAccent.withOpacity(0.16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerCard extends StatelessWidget {
  const _ScannerCard({
    required this.controller,
    required this.onDetect,
    required this.isVerified,
  });

  final MobileScannerController controller;
  final ValueChanged<String> onDetect;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 288,
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(AppSizes.radius24),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withOpacity(0.20),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) {
                String? code;
                for (final barcode in capture.barcodes) {
                  final raw = barcode.rawValue;
                  if (raw != null && raw.isNotEmpty) {
                    code = raw;
                    break;
                  }
                }
                if (code != null && code.isNotEmpty) {
                  onDetect(code);
                }
              },
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.darkGreen.withOpacity(0.22),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: AppSizes.space20,
            child: Text(
              isVerified ? 'Scan successful' : 'Align barcode within the frame',
              textAlign: TextAlign.center,
              style: AppTextStyles.cardTitle.copyWith(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          const Center(child: _ScannerFrame()),
          if (isVerified)
            const Positioned(
              right: AppSizes.space16,
              bottom: AppSizes.space16,
              child: _VerifiedBubble(),
            ),
        ],
      ),
    );
  }
}

class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 238,
      height: 132,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _ScannerFramePainter()),
          ),
          Center(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: AppColors.mintGreen,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mintGreen.withOpacity(0.72),
                    blurRadius: 10,
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

class _ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const length = 34.0;
    final radius = BorderRadius.circular(18).toRRect(Offset.zero & size);
    canvas.drawRRect(
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.05)
        ..style = PaintingStyle.fill,
    );

    canvas
      ..drawLine(Offset.zero, const Offset(length, 0), paint)
      ..drawLine(Offset.zero, const Offset(0, length), paint)
      ..drawLine(Offset(size.width, 0), Offset(size.width - length, 0), paint)
      ..drawLine(Offset(size.width, 0), Offset(size.width, length), paint)
      ..drawLine(Offset(0, size.height), Offset(length, size.height), paint)
      ..drawLine(Offset(0, size.height), Offset(0, size.height - length), paint)
      ..drawLine(
        Offset(size.width, size.height),
        Offset(size.width - length, size.height),
        paint,
      )
      ..drawLine(
        Offset(size.width, size.height),
        Offset(size.width, size.height - length),
        paint,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _VerifiedBubble extends StatelessWidget {
  const _VerifiedBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 16),
          const SizedBox(width: AppSizes.space6),
          Text(
            'Scan successful',
            style: AppTextStyles.mutedLabel.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpectedBarcodeCard extends StatelessWidget {
  const _ExpectedBarcodeCard({required this.supplierCode});

  final String supplierCode;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      showShadow: false,
      backgroundColor: AppColors.softBlue,
      borderColor: AppColors.blueAccent.withOpacity(0.14),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.space14,
        vertical: AppSizes.space12,
      ),
      child: Row(
        children: [
          const SupplierIconBox(
            icon: Icons.qr_code_2_rounded,
            backgroundColor: AppColors.surface,
            iconColor: AppColors.blueAccent,
            size: 40,
          ),
          const SizedBox(width: AppSizes.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expected barcode number',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSizes.space4),
                SelectableText(
                  supplierCode,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.blueAccent,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({required this.provider});

  final TripProvider provider;

  @override
  Widget build(BuildContext context) {
    final expected = provider.currentNextStop?.supplierCode;
    final scanned = provider.lastScannedCode?.trim();
    final hasScan = scanned != null && scanned.isNotEmpty;
    final isCorrect = provider.isFormUnlocked;
    final isWrong = hasScan && !isCorrect;
    final borderColor = isCorrect
        ? AppColors.primaryGreen
        : isWrong
            ? AppColors.dangerRed
            : AppColors.borderLight;
    final backgroundColor = isCorrect
        ? AppColors.lightGreen
        : isWrong
            ? AppColors.dangerRed.withOpacity(0.06)
            : AppColors.surface;

    return PremiumCard(
      backgroundColor: backgroundColor,
      borderColor: borderColor.withOpacity(0.55),
      showShadow: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SupplierIconBox(
            icon: isCorrect
                ? Icons.check_circle_rounded
                : isWrong
                    ? Icons.error_rounded
                    : Icons.qr_code_2_rounded,
            backgroundColor: isCorrect
                ? AppColors.surface
                : isWrong
                    ? AppColors.dangerRed.withOpacity(0.10)
                    : AppColors.lightGreen,
            iconColor: isCorrect
                ? AppColors.primaryGreen
                : isWrong
                    ? AppColors.dangerRed
                    : AppColors.darkGreen,
          ),
          const SizedBox(width: AppSizes.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hasScan) ...[
                  Text('Awaiting barcode scan', style: AppTextStyles.cardTitle),
                  const SizedBox(height: AppSizes.space6),
                  Text(
                    'Scan barcode ${expected ?? '-'} at the current supplier to unlock the form.',
                    style: AppTextStyles.caption,
                  ),
                ] else if (isWrong) ...[
                  Text(
                    'Wrong supplier barcode',
                    style: AppTextStyles.cardTitle.copyWith(
                      color: AppColors.dangerRed,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space8),
                  Text(
                    'Expected: ${expected ?? '-'}',
                    style: AppTextStyles.caption,
                  ),
                  Text(
                    'Scanned: $scanned',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.dangerRed,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ] else ...[
                  Text(
                    'Scanned Supplier ID: $scanned',
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: AppSizes.space8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Barcode verified',
                      style: AppTextStyles.mutedLabel.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionFormCard extends StatelessWidget {
  const _CollectionFormCard({
    required this.clearController,
    required this.colouredController,
    required this.condition,
    required this.enabled,
    required this.onConditionChanged,
    this.error,
  });

  final TextEditingController clearController;
  final TextEditingController colouredController;
  final String condition;
  final bool enabled;
  final ValueChanged<String> onConditionChanged;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: PremiumCard(
        showShadow: false,
        backgroundColor: enabled ? AppColors.surface : const Color(0xFFF8FAFC),
        child: IgnorePointer(
          ignoring: !enabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Collection Details', style: AppTextStyles.cardTitle),
              const SizedBox(height: AppSizes.space14),
              Row(
                children: [
                  Expanded(
                    child: _GlassInputBox(
                      controller: clearController,
                      label: 'Clear Glass',
                      icon: Icons.water_drop_outlined,
                    ),
                  ),
                  const SizedBox(width: AppSizes.space10),
                  Expanded(
                    child: _GlassInputBox(
                      controller: colouredController,
                      label: 'Coloured Glass',
                      icon: Icons.local_drink_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.space16),
              Text('Condition', style: AppTextStyles.mutedLabel),
              const SizedBox(height: AppSizes.space8),
              _ConditionSelector(
                selected: condition,
                onChanged: onConditionChanged,
              ),
              if (error != null) ...[
                const SizedBox(height: AppSizes.space10),
                Text(
                  error!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.dangerRed,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassInputBox extends StatelessWidget {
  const _GlassInputBox({
    required this.controller,
    required this.label,
    required this.icon,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SupplierIconBox(
          icon: icon,
          size: 34,
          backgroundColor: AppColors.lightGreen,
          iconColor: AppColors.primaryGreen,
        ),
        const SizedBox(height: AppSizes.space8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: label,
            suffixText: 'kg',
          ),
        ),
      ],
    );
  }
}

class _ConditionSelector extends StatelessWidget {
  const _ConditionSelector({
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = ['Good', 'Mixed', 'Damaged'];

    return Row(
      children: [
        for (final option in options) ...[
          Expanded(
            child: InkWell(
              onTap: () => onChanged(option),
              borderRadius: BorderRadius.circular(AppSizes.radius16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected == option
                      ? AppColors.lightGreen
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radius16),
                  border: Border.all(
                    color: selected == option
                        ? AppColors.primaryGreen
                        : AppColors.borderLight,
                    width: selected == option ? 1.4 : 1,
                  ),
                ),
                child: Text(
                  option,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.mutedLabel.copyWith(
                    color: selected == option
                        ? AppColors.primaryGreen
                        : AppColors.textGrey,
                    fontWeight:
                        selected == option ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          if (option != options.last) const SizedBox(width: AppSizes.space8),
        ],
      ],
    );
  }
}

class _CollectionSavedCard extends StatelessWidget {
  const _CollectionSavedCard({
    required this.isSynced,
    required this.supplierCode,
    required this.nextSupplierCode,
  });

  final bool isSynced;
  final String? supplierCode;
  final String? nextSupplierCode;

  @override
  Widget build(BuildContext context) {
    if (!isSynced) {
      return const _OfflineInfoCard(
        message:
            "You're offline. Don't worry, your data is saved on this device and will automatically sync to the server when you're back online.",
      );
    }

    return PremiumCard(
      backgroundColor: AppColors.lightGreen,
      borderColor: AppColors.primaryGreen.withOpacity(0.18),
      showShadow: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SupplierIconBox(
            icon: Icons.check_circle_rounded,
            backgroundColor: AppColors.surface,
            iconColor: AppColors.primaryGreen,
            size: 42,
          ),
          const SizedBox(width: AppSizes.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Collection saved successfully',
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: AppSizes.space6),
                Text(
                  supplierCode == null
                      ? 'The collection was added and synced.'
                      : '$supplierCode was added and synced.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.space8),
                Text(
                  nextSupplierCode == null
                      ? 'All available stops are collected. You can view the report now.'
                      : 'Ready for next scan: $nextSupplierCode',
                  style: AppTextStyles.mutedLabel.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineInfoCard extends StatelessWidget {
  const _OfflineInfoCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      backgroundColor: AppColors.softBlue,
      borderColor: AppColors.blueAccent.withOpacity(0.14),
      showShadow: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SupplierIconBox(
            icon: Icons.cloud_off_rounded,
            backgroundColor: AppColors.surface,
            iconColor: AppColors.blueAccent,
            size: 40,
          ),
          const SizedBox(width: AppSizes.space12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.blueAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompleteTripCard extends StatelessWidget {
  const _CompleteTripCard();

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      backgroundColor: AppColors.lightGreen,
      child: Row(
        children: [
          const SupplierIconBox(icon: Icons.check_circle_rounded),
          const SizedBox(width: AppSizes.space12),
          Expanded(
            child: Text(
              'All stops are collected. View the report to complete final sync.',
              style: AppTextStyles.cardTitle,
            ),
          ),
        ],
      ),
    );
  }
}

String? _validateForm({
  required String clearText,
  required String colouredText,
  required double? clearKg,
  required double? colouredKg,
}) {
  if (clearText.isNotEmpty && clearKg == null) {
    return 'Clear glass kg must be numeric.';
  }

  if (colouredText.isNotEmpty && colouredKg == null) {
    return 'Coloured glass kg must be numeric.';
  }

  final clear = clearKg ?? 0;
  final coloured = colouredKg ?? 0;

  if (clear < 0 || coloured < 0) {
    return 'Kg values must be 0 or greater.';
  }

  if (clear + coloured <= 0) {
    return 'Total collected kg must be greater than 0.';
  }

  return null;
}
