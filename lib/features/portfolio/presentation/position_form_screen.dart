import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:versatech_investment_companion/features/market_data/data/repositories/cached_market_data_repository.dart';
import 'package:versatech_investment_companion/features/market_data/domain/cache/cache_policy.dart';
import 'package:versatech_investment_companion/features/portfolio/application/portfolio_providers.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/portfolio_rules.dart';
import 'package:versatech_investment_companion/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:versatech_investment_companion/features/portfolio/presentation/portfolio_messages.dart';

class PositionFormScreen extends ConsumerStatefulWidget {
  const PositionFormScreen({
    this.initialSymbol = '',
    super.key,
  });

  final String initialSymbol;

  @override
  ConsumerState<PositionFormScreen> createState() => _PositionFormScreenState();
}

class _PositionFormScreenState extends ConsumerState<PositionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _symbol;
  late final TextEditingController _quantity;
  late final TextEditingController _price;
  late final TextEditingController _date;
  var _autovalidate = AutovalidateMode.disabled;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _symbol = TextEditingController(
      text: normalizeSymbol(widget.initialSymbol),
    );
    _quantity = TextEditingController();
    _price = TextEditingController();
    _date = TextEditingController();
  }

  @override
  void dispose() {
    _symbol.dispose();
    _quantity.dispose();
    _price.dispose();
    _date.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = calendarDay(ref.watch(clockProvider).now());

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Nouvelle position'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidate,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Text(
                  'Position fictive',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Indiquez l’actif, la quantité, le prix d’achat et la date. Rien n’est envoyé à un courtier.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  key: const Key('position-symbol'),
                  controller: _symbol,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Symbole',
                    helperText: 'Action ou ETF, par exemple AAPL',
                  ),
                  validator: (value) => symbolError(value ?? ''),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('position-quantity'),
                  controller: _quantity,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Quantité',
                  ),
                  validator: (value) => quantityError(value ?? ''),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('position-price'),
                  controller: _price,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Prix d’achat',
                  ),
                  validator: (value) => purchasePriceError(value ?? ''),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('position-date'),
                  controller: _date,
                  keyboardType: TextInputType.datetime,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Date d’achat',
                    helperText: 'JJ/MM/AAAA',
                    suffixIcon: IconButton(
                      tooltip: 'Choisir la date d’achat',
                      onPressed: () => unawaited(_pickDate(today)),
                      icon: const Icon(Icons.calendar_today_outlined),
                    ),
                  ),
                  validator: (value) => purchaseDateError(value ?? '', today),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('position-submit'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: _saving ? null : () => unawaited(_submit(today)),
                  child: const Text('Enregistrer la position'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(DateTime today) async {
    final initial = tryParsePurchaseDate(_date.text) ?? today;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(initial.year, initial.month, initial.day),
      firstDate: DateTime(1990),
      lastDate: DateTime(today.year, today.month, today.day),
    );
    if (picked == null) {
      return;
    }
    _date.text = formatPurchaseDay(
      DateTime.utc(picked.year, picked.month, picked.day),
    );
  }

  Future<void> _submit(DateTime today) async {
    setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    setState(() => _saving = true);
    try {
      final draft = PortfolioPositionDraft.checked(
        symbol: _symbol.text,
        quantity: _quantity.text,
        purchasePrice: _price.text,
        purchaseDate: _date.text,
        today: today,
      );
      await ref.read(portfolioRepositoryProvider).addPosition(draft);
      if (!mounted) {
        return;
      }
      context.pop();
    } on InvalidPortfolioInput catch (error) {
      _show(error.userMessage);
    } on PortfolioPersistenceException {
      _show(portfolioWriteErrorMessage);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _show(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
