import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/date_time_formatter.dart';
import '../../providers/expenses/expense_form_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_drop_down.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/app_text_field.dart';

const expenseCategories = [
  'Rent',
  'Utilities',
  'Supplies',
  'Salaries',
  'Transport',
  'Maintenance',
  'Marketing',
  'Other',
];

class ExpenseFormScreen extends ConsumerStatefulWidget {
  final int? id;

  const ExpenseFormScreen({
    super.key,
    this.id,
  });

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final amountController = TextEditingController();
  final descController = TextEditingController();
  final dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(expenseFormNotifierProvider.notifier).initExpenseForm(widget.id);

      final state = ref.read(expenseFormNotifierProvider);
      amountController.text = state.amount?.toString() ?? '';
      descController.text = state.description ?? '';
      dateController.text = state.date != null ? DateTimeFormatter.slashDate(state.date!) : '';
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    descController.dispose();
    dateController.dispose();
    super.dispose();
  }

  void onTapDate() async {
    final notifier = ref.read(expenseFormNotifierProvider.notifier);
    final currentDate = DateTime.tryParse(ref.read(expenseFormNotifierProvider).date ?? '') ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      notifier.onChangedDate(picked.toIso8601String());
      dateController.text = DateTimeFormatter.slashDate(picked.toIso8601String());
    }
  }

  void createExpense() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(expenseFormNotifierProvider.notifier).createExpense();
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.pop();
      AppSnackBar.show('Expense created');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  void updateExpense() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(expenseFormNotifierProvider.notifier).updateExpense(widget.id!);
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.pop();
      AppSnackBar.show('Expense updated');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  void deleteExpense() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(expenseFormNotifierProvider.notifier).deleteExpense(widget.id!);
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.pop();
      AppSnackBar.show('Expense deleted');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(expenseFormNotifierProvider.notifier);

    final isLoaded = ref.watch(expenseFormNotifierProvider.select((s) => s.isLoaded));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'Add Expense' : 'Edit Expense'),
        titleSpacing: 0,
      ),
      body: !isLoaded
          ? const AppProgressIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryField(onChanged: notifier.onChangedCategory),
                  _AmountField(
                    controller: amountController,
                    onChanged: notifier.onChangedAmount,
                  ),
                  _DateField(
                    controller: dateController,
                    onTap: onTapDate,
                  ),
                  _DescriptionField(
                    controller: descController,
                    onChanged: notifier.onChangedDescription,
                  ),
                  _CreateOrUpdateButton(
                    id: widget.id,
                    onCreateExpense: createExpense,
                    onUpdateExpense: updateExpense,
                  ),
                  _DeleteButton(
                    id: widget.id,
                    onDeleteExpense: deleteExpense,
                  ),
                ],
              ),
            ),
    );
  }
}

class _CategoryField extends ConsumerWidget {
  final ValueChanged<String?> onChanged;

  const _CategoryField({required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(expenseFormNotifierProvider.select((s) => s.category));

    return AppDropDown<String>(
      labelText: 'Category',
      hintText: 'Select category...',
      selectedValue: category,
      dropdownItems: expenseCategories.map((e) {
        return DropdownMenuItem<String>(
          value: e,
          child: Text(e),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _AmountField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: controller,
        labelText: 'Amount',
        hintText: 'Expense amount...',
        type: AppTextFieldType.currency,
        onChanged: onChanged,
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onTap;

  const _DateField({
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          child: AppTextField(
            controller: controller,
            labelText: 'Date',
            hintText: 'Expense date...',
          ),
        ),
      ),
    );
  }
}

class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _DescriptionField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: controller,
        labelText: 'Description',
        hintText: 'Expense description...',
        maxLines: 4,
        onChanged: onChanged,
      ),
    );
  }
}

class _CreateOrUpdateButton extends ConsumerWidget {
  final int? id;
  final VoidCallback onCreateExpense;
  final VoidCallback onUpdateExpense;

  const _CreateOrUpdateButton({
    required this.id,
    required this.onCreateExpense,
    required this.onUpdateExpense,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFormValid = ref.watch(
      expenseFormNotifierProvider.select((s) {
        return (s.category?.isNotEmpty ?? false) && (s.amount ?? 0) > 0;
      }),
    );

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding * 1.5),
      child: AppButton(
        text: id == null ? 'Add Expense' : 'Update Expense',
        enabled: isFormValid,
        onTap: () {
          if (id != null) {
            onUpdateExpense();
          } else {
            onCreateExpense();
          }
        },
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final int? id;
  final VoidCallback onDeleteExpense;

  const _DeleteButton({
    required this.id,
    required this.onDeleteExpense,
  });

  @override
  Widget build(BuildContext context) {
    if (id == null) return const SizedBox(height: AppSizes.padding * 2);

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSizes.padding,
        bottom: AppSizes.padding * 2,
      ),
      child: AppButton(
        text: 'Delete',
        textColor: Theme.of(context).colorScheme.error,
        buttonColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        onTap: () {
          AppDialog.show(
            title: 'Confirm',
            text: 'Are you sure want to delete this expense?',
            leftButtonText: 'Cancel',
            rightButtonText: 'Delete',
            rightButtonColor: Theme.of(context).colorScheme.errorContainer,
            rightButtonTextColor: Theme.of(context).colorScheme.error,
            onTapRightButton: (context) async {
              context.pop();
              onDeleteExpense();
            },
          );
        },
      ),
    );
  }
}
