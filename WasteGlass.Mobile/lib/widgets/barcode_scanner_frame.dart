import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_text_styles.dart';

class BarcodeScannerFrame extends StatelessWidget {
  const BarcodeScannerFrame({
    super.key,
    required this.controller,
    required this.onDetect,
    this.success = false,
    this.error = false,
    this.height = 288,
  });

  final MobileScannerController controller;
  final ValueChanged<String> onDetect;
  final bool success;
  final bool error;
  final double height;

  @override
  Widget build(BuildContext context) {
    final message = success
        ? 'Scan successful'
        : error
            ? 'Wrong barcode. Scan again.'
            : 'Align barcode within the frame';

    return LayoutBuilder(
      builder: (context, constraints) {
        final responsiveHeight =
            (constraints.maxWidth * 0.72).clamp(238.0, height).toDouble();

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: responsiveHeight,
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
                    for (final barcode in capture.barcodes) {
                      final raw = barcode.rawValue;
                      if (raw != null && raw.isNotEmpty) {
                        onDetect(raw);
                        return;
                      }
                    }
                  },
                ),
              ),
              Positioned.fill(
                child: ColoredBox(
                  color: AppColors.darkGreen.withOpacity(0.22),
                ),
              ),
              Positioned(
                left: AppSizes.space16,
                right: AppSizes.space16,
                top: AppSizes.space20,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Text(
                    message,
                    key: ValueKey(message),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const Center(child: _ScannerFrameOverlay()),
              if (success || error)
                Positioned(
                  right: AppSizes.space16,
                  bottom: AppSizes.space16,
                  child: _ScannerStateBubble(success: success),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ScannerFrameOverlay extends StatefulWidget {
  const _ScannerFrameOverlay();

  @override
  State<_ScannerFrameOverlay> createState() => _ScannerFrameOverlayState();
}

class _ScannerFrameOverlayState extends State<_ScannerFrameOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 238,
      height: 132,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _ScannerFramePainter())),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final top = 18 + (132 - 36) * _controller.value;
              return Positioned(
                left: 18,
                right: 18,
                top: top,
                child: Container(
                  height: 2,
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
              );
            },
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

    canvas.drawRRect(
      BorderRadius.circular(18).toRRect(Offset.zero & size),
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

class _ScannerStateBubble extends StatelessWidget {
  const _ScannerStateBubble({required this.success});

  final bool success;

  @override
  Widget build(BuildContext context) {
    final color = success ? AppColors.primaryGreen : AppColors.dangerRed;

    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error_rounded,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: AppSizes.space6),
            Text(
              success ? 'Scan successful' : 'Scan blocked',
              style: AppTextStyles.mutedLabel.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
