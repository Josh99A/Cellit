import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/themes/app_sizes.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final controller = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);

  // Prevents popping more than once when multiple frames detect a barcode
  bool isHandled = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onDetect(BarcodeCapture capture) {
    if (isHandled) return;

    final barcode = capture.barcodes.map((e) => e.rawValue).whereType<String>().firstOrNull;

    if (barcode == null || barcode.isEmpty) return;

    isHandled = true;
    context.pop(barcode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [_TorchButton(controller: controller)],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: controller,
            onDetect: onDetect,
            errorBuilder: (context, error) => _ErrorState(error: error),
          ),
          const _ScanAreaOverlay(),
        ],
      ),
    );
  }
}

class _TorchButton extends StatelessWidget {
  final MobileScannerController controller;

  const _TorchButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, _) {
        final isTorchOn = state.torchState == TorchState.on;

        return Padding(
          padding: const EdgeInsets.only(right: AppSizes.padding / 2),
          child: IconButton(
            icon: Icon(
              isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: Colors.white,
            ),
            onPressed: () => controller.toggleTorch(),
          ),
        );
      },
    );
  }
}

class _ScanAreaOverlay extends StatelessWidget {
  const _ScanAreaOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 260,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radius),
              border: Border.all(
                width: 2,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.padding),
          Text(
            'Point the camera at a barcode',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final MobileScannerException error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    final isPermissionDenied = error.errorCode == MobileScannerErrorCode.permissionDenied;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.padding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.no_photography_rounded,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: AppSizes.padding),
            Text(
              isPermissionDenied
                  ? 'Camera permission denied. Allow camera access in your device settings to scan barcodes.'
                  : 'Failed to start the camera',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
