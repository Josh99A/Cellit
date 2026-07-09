import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_icon_button.dart';

class AppScanButton extends StatelessWidget {
  final double? iconSize;
  final EdgeInsets padding;
  final double borderRadius;
  final ValueChanged<String> onScanned;

  const AppScanButton({
    super.key,
    this.iconSize,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = 100,
    required this.onScanned,
  });

  // Camera barcode scanning (mobile_scanner) is not supported on Windows/Linux
  static bool get isSupported =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  @override
  Widget build(BuildContext context) {
    if (!isSupported) return const SizedBox.shrink();

    return AppIconButton(
      icon: Icons.qr_code_scanner_rounded,
      iconSize: iconSize,
      padding: padding,
      borderRadius: borderRadius,
      onTap: () async {
        final barcode = await context.push<String>('/barcode-scanner');

        if (barcode != null && barcode.isNotEmpty) onScanned(barcode);
      },
    );
  }
}
