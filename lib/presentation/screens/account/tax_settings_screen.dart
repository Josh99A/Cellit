import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_sizes.dart';
import '../../providers/tax/tax_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/app_text_field.dart';

class TaxSettingsScreen extends ConsumerStatefulWidget {
  const TaxSettingsScreen({super.key});

  @override
  ConsumerState<TaxSettingsScreen> createState() => _TaxSettingsScreenState();
}

class _TaxSettingsScreenState extends ConsumerState<TaxSettingsScreen> {
  final taxRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taxRate = ref.read(taxNotifierProvider).taxRate;
      taxRateController.text = taxRate == 0 ? '' : taxRate.toString();
    });
  }

  @override
  void dispose() {
    taxRateController.dispose();
    super.dispose();
  }

  void saveTaxRate() {
    final taxRate = double.tryParse(taxRateController.text) ?? 0;

    if (taxRate < 0 || taxRate > 100) {
      AppSnackBar.showError('Tax rate must be between 0 and 100');
      return;
    }

    ref.read(taxNotifierProvider.notifier).changeTaxRate(taxRate);
    context.pop();
    AppSnackBar.show('Tax rate saved');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Settings'),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: taxRateController,
              labelText: 'Tax Rate (%)',
              hintText: 'e.g. 7.5',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
            ),
            const SizedBox(height: AppSizes.padding / 2),
            Text(
              'Applied to the subtotal of every new sale. Set to 0 to disable tax.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSizes.padding * 1.5),
            AppButton(
              text: 'Save',
              onTap: saveTaxRate,
            ),
          ],
        ),
      ),
    );
  }
}
