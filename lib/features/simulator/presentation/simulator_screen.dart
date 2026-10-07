import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatech_investment_companion/app/theme/app_colors.dart';
import 'package:versatech_investment_companion/core/widgets/animated_financial_value.dart';
import 'package:versatech_investment_companion/features/market_data/data/repositories/cached_market_data_repository.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/portfolio_rules.dart';
import 'package:versatech_investment_companion/features/portfolio/presentation/portfolio_messages.dart';
import 'package:versatech_investment_companion/features/simulator/application/dca_controller.dart';
import 'package:versatech_investment_companion/features/simulator/domain/dca_models.dart';
import 'package:versatech_investment_companion/features/simulator/domain/dca_rules.dart';
import 'package:versatech_investment_companion/features/simulator/presentation/dca_chart.dart';
import 'package:versatech_investment_companion/features/simulator/presentation/dca_messages.dart';

class SimulatorScreen extends ConsumerStatefulWidget {
  const SimulatorScreen({
    this.initialSymbol = '',
    super.key,
  });

  final String initialSymbol;

  @override
  ConsumerState<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends ConsumerState<SimulatorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _symbol;
  late final TextEditingController _initial;
  late final TextEditingController _monthly;
  late final TextEditingController _start;
  late final TextEditingController _end;
  var _autovalidate = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    _symbol = TextEditingController(text: _preferredSymbol());
    _initial = TextEditingController();
    _monthly = TextEditingController();
    _start = TextEditingController();
    _end = TextEditingController();
  }

  @override
  void didUpdateWidget(SimulatorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = normalizeSymbol(widget.initialSymbol);
    if (next.isNotEmpty && next != normalizeSymbol(oldWidget.initialSymbol)) {
      _symbol.text = next;
    }
  }

  @override
  void dispose() {
    _symbol.dispose();
    _initial.dispose();
    _monthly.dispose();
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  String _preferredSymbol() {
    final requested = normalizeSymbol(ref.read(dcaRequestedSymbolProvider));
    if (requested.isNotEmpty) {
      return requested;
    }
    return normalizeSymbol(widget.initialSymbol);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = calendarDay(ref.watch(clockProvider).now());
    final state = ref.watch(dcaControllerProvider);
    final busy = state.status == DcaRunStatus.loading ||
        state.status == DcaRunStatus.refreshing;

    ref.listen<String>(dcaRequestedSymbolProvider, (previous, next) {
      final symbol = normalizeSymbol(next);
      if (symbol.isEmpty || symbol == _symbol.text) {
        return;
      }
      _symbol.text = symbol;
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(dcaScreenTitle),
        actions: [
          IconButton(
            key: const Key('dca-refresh'),
            tooltip: 'Actualiser l’historique',
            style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: state.status == DcaRunStatus.ready ||
                    state.status == DcaRunStatus.error
                ? () => unawaited(
                      ref.read(dcaControllerProvider.notifier).refresh(),
                    )
                : null,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidate,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Investissement périodique',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dcaFrequencyNote,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _Note(dcaEducationRegular),
                  const SizedBox(height: 16),
                  if (state.status == DcaRunStatus.loading)
                    const _StatusLine(message: dcaLoadingMessage)
                  else if (state.status == DcaRunStatus.refreshing)
                    const _StatusLine(message: dcaRefreshingMessage),
                  TextFormField(
                    key: const Key('dca-symbol'),
                    controller: _symbol,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Symbole',
                      helperText: 'Action ou ETF, par exemple AAPL',
                    ),
                    validator: (value) => dcaSymbolError(value ?? ''),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('dca-initial'),
                    controller: _initial,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Montant initial',
                      helperText: '0 si vous ne versez qu’une mensualité',
                    ),
                    validator: (value) => dcaInitialAmountError(value ?? ''),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('dca-monthly'),
                    controller: _monthly,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Versement mensuel',
                      helperText: '0 si vous ne versez que le montant initial',
                    ),
                    validator: (value) => dcaMonthlyAmountError(
                      value ?? '',
                      _initial.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DateField(
                    fieldKey: const Key('dca-start'),
                    controller: _start,
                    label: 'Date de début',
                    tooltip: 'Choisir la date de début',
                    today: today,
                    validator: (value) => dcaStartDateError(value ?? ''),
                  ),
                  const SizedBox(height: 12),
                  _DateField(
                    fieldKey: const Key('dca-end'),
                    controller: _end,
                    label: 'Date de fin',
                    tooltip: 'Choisir la date de fin',
                    today: today,
                    validator: (value) => dcaEndDateError(
                      value ?? '',
                      _start.text,
                      today,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const Key('dca-submit'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: busy ? null : () => unawaited(_submit(today)),
                    child: const Text('Simuler'),
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage!,
                      key: const Key('dca-error'),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                  if (state.result != null) ...[
                    const SizedBox(height: 24),
                    _Result(state: state),
                  ] else ...[
                    const SizedBox(height: 24),
                    const DcaChart(points: []),
                  ],
                  const SizedBox(height: 20),
                  const _Note(dcaEducationPast),
                  const SizedBox(height: 8),
                  const _Note(dcaEducationNoGuarantee),
                  const SizedBox(height: 16),
                  Text(
                    dcaDisclaimer,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(DateTime today) async {
    setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    try {
      final input = checkedDcaInput(
        symbol: _symbol.text,
        initialAmount: _initial.text,
        monthlyAmount: _monthly.text,
        startDate: _start.text,
        endDate: _end.text,
        today: today,
      );
      await ref.read(dcaControllerProvider.notifier).simulate(input);
    } on InvalidDcaInput catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.userMessage)),
      );
    }
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.tooltip,
    required this.today,
    required this.validator,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final String tooltip;
  final DateTime today;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      keyboardType: TextInputType.datetime,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        helperText: 'JJ/MM/AAAA',
        suffixIcon: IconButton(
          tooltip: tooltip,
          onPressed: () => unawaited(_pick(context)),
          icon: const Icon(Icons.calendar_today_outlined),
        ),
      ),
      validator: validator,
    );
  }

  Future<void> _pick(BuildContext context) async {
    final initial = tryParsePurchaseDate(controller.text) ?? today;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(initial.year, initial.month, initial.day),
      firstDate: DateTime(1990),
      lastDate: DateTime(today.year, today.month, today.day),
    );
    if (picked == null) {
      return;
    }
    controller.text = formatPurchaseDay(
      DateTime.utc(picked.year, picked.month, picked.day),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.state});

  final DcaState state;

  @override
  Widget build(BuildContext context) {
    final result = state.result!;
    final theme = Theme.of(context);
    final performance = result.performancePercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.isStale) ...[
          Text(
            dcaStaleMessage,
            key: const Key('dca-stale'),
            style: theme.textTheme.bodyLarge,
          ),
          if (state.historyUpdatedAt != null)
            Text(
              formatPortfolioTimestamp(state.historyUpdatedAt!),
              key: const Key('dca-stale-date'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 12),
        ],
        if (result.historyBeginsAfterStart)
          const _Note(dcaDeferredStartMessage),
        if (result.purchaseMovedToNextSession)
          const _Note(dcaNextSessionMessage),
        if (result.valuedOnEarlierSession)
          const _Note(dcaEarlierSessionMessage),
        _Figure(
          label: dcaInvestedLabel,
          value: formatPortfolioAmount(result.totalInvested),
          valueKey: const Key('dca-invested'),
        ),
        const SizedBox(height: 12),
        _Figure(
          label: dcaQuantityLabel,
          value: formatQuantity(result.totalQuantity),
          valueKey: const Key('dca-quantity'),
        ),
        const SizedBox(height: 12),
        Text(dcaFinalValueLabel, style: theme.textTheme.titleMedium),
        Semantics(
          label:
              '$dcaFinalValueLabel ${formatPortfolioAmount(result.finalValue)}',
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedFinancialValue(
              value: result.finalValue,
              formatter: formatPortfolioAmount,
              style: theme.textTheme.displaySmall,
              textKey: const Key('dca-final-value'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (performance == null)
          Text(
            'Performance indisponible',
            key: const Key('dca-performance'),
          )
        else
          _GainLine(
            gain: result.gainLoss,
            performance: performance,
          ),
        const SizedBox(height: 20),
        const Text('Évolution'),
        const SizedBox(height: 8),
        DcaChart(points: result.timeline),
      ],
    );
  }
}

class _GainLine extends StatelessWidget {
  const _GainLine({
    required this.gain,
    required this.performance,
  });

  final double gain;
  final double performance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = AppSemanticColors.of(context);
    final positive = gain > 0;
    final negative = gain < 0;
    final color = positive
        ? semantic.gain
        : negative
            ? semantic.loss
            : theme.colorScheme.onSurfaceVariant;
    final icon = positive
        ? Icons.trending_up
        : negative
            ? Icons.trending_down
            : Icons.remove;
    final label = positive
        ? 'Gain'
        : negative
            ? 'Perte'
            : 'Écart nul';

    return Semantics(
      label:
          '$label ${formatPortfolioSigned(gain)}, ${formatPortfolioPercent(performance)}',
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          Icon(icon, color: color),
          Text(label,
              style: theme.textTheme.titleSmall?.copyWith(color: color)),
          Text(
            formatPortfolioSigned(gain),
            key: const Key('dca-gain'),
            style: theme.textTheme.titleMedium?.copyWith(color: color),
          ),
          Text(
            formatPortfolioPercent(performance),
            key: const Key('dca-performance'),
            style: theme.textTheme.titleMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.label,
    required this.value,
    required this.valueKey,
  });

  final String label;
  final String value;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$label $value',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleMedium,
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              key: valueKey,
              style: theme.textTheme.headlineMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.hourglass_top),
          const SizedBox(width: 12),
          Flexible(child: Text(message)),
        ],
      ),
    );
  }
}
