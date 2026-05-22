import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/month_data.dart';
import '../services/storage_service.dart';
import '../app_theme.dart';

const _monthNames = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril',
  'Maio', 'Junho', 'Julho', 'Agosto',
  'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

class CopyCalculationScreen extends StatefulWidget {
  final int year;

  const CopyCalculationScreen({Key? key, required this.year}) : super(key: key);

  @override
  State<CopyCalculationScreen> createState() => _CopyCalculationScreenState();
}

class _CopyCalculationScreenState extends State<CopyCalculationScreen> {
  final _storage = StorageService();

  int? _sourceMonth;
  MonthData? _selectedCalc;
  int? _destMonth;
  List<MonthData> _sourceCalcs = [];
  bool _loadingCalcs = false;
  bool _copying = false;

  bool get _canCopy => _selectedCalc != null && _destMonth != null;

  Future<void> _pickSourceMonth() async {
    final picked = await _showMonthPicker(excluded: null);
    if (picked == null) return;
    setState(() {
      _sourceMonth = picked;
      _selectedCalc = null;
      _sourceCalcs = [];
      _loadingCalcs = true;
      if (_destMonth == picked) _destMonth = null;
    });
    final calcs = await _storage.loadMonthCalculations(widget.year, picked);
    if (mounted) {
      setState(() {
        _sourceCalcs = calcs;
        _loadingCalcs = false;
      });
    }
  }

  Future<void> _pickCalc() async {
    if (_sourceCalcs.isEmpty) return;
    final picked = await showModalBottomSheet<MonthData>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _CalcPickerSheet(calculations: _sourceCalcs),
    );
    if (picked != null) setState(() => _selectedCalc = picked);
  }

  Future<void> _pickDestMonth() async {
    final picked = await _showMonthPicker(excluded: _sourceMonth);
    if (picked != null) setState(() => _destMonth = picked);
  }

  Future<int?> _showMonthPicker({int? excluded}) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MonthPickerSheet(excluded: excluded),
    );
  }

  Future<void> _doCopy() async {
    if (_selectedCalc == null || _destMonth == null) return;
    setState(() => _copying = true);

    final destCalcs =
        await _storage.loadMonthCalculations(widget.year, _destMonth!);

    final copies = _selectedCalc!.expenses
        .map((e) => Expense(
              id: DateTime.now().millisecondsSinceEpoch.toString() + e.id,
              value: e.value,
              description: e.description,
              quantity: e.quantity,
            ))
        .toList();

    final newCalc = MonthData(
      title: _selectedCalc!.title,
      type: _selectedCalc!.type,
      income: _selectedCalc!.income,
      incomeLabel: _selectedCalc!.incomeLabel,
      expenses: copies,
    );

    destCalcs.insert(0, newCalc);
    await _storage.saveMonthCalculations(widget.year, _destMonth!, destCalcs);

    if (!mounted) return;
    setState(() => _copying = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '"${_selectedCalc!.title}" copiado para ${_monthNames[_destMonth! - 1]}!'),
        backgroundColor: kPrimary,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currency =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Copiar Cálculo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionLabel('ORIGEM'),
            const SizedBox(height: 8),
            _transferCard(children: [
              _pickerRow(
                icon: Icons.calendar_today,
                label: _sourceMonth != null
                    ? _monthNames[_sourceMonth! - 1]
                    : 'Selecionar mês de origem',
                placeholder: _sourceMonth == null,
                onTap: _pickSourceMonth,
              ),
              if (_sourceMonth != null) ...[
                const Divider(height: 1, indent: 16, endIndent: 16),
                if (_loadingCalcs)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Center(
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2))),
                  )
                else if (_sourceCalcs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Text(
                      'Nenhum cálculo neste mês',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  )
                else
                  _pickerRow(
                    icon: _selectedCalc?.type == CalculationType.market
                        ? Icons.shopping_cart_outlined
                        : Icons.payments_outlined,
                    label: _selectedCalc?.title ?? 'Selecionar cálculo',
                    placeholder: _selectedCalc == null,
                    subtitle: _selectedCalc != null
                        ? (_selectedCalc!.type == CalculationType.market
                            ? '${_selectedCalc!.totalItems} itens · ${currency.format(_selectedCalc!.totalExpenses)}'
                            : 'Sobra: ${currency.format(_selectedCalc!.sobra)}')
                        : null,
                    onTap: _pickCalc,
                  ),
              ],
            ]),
            const SizedBox(height: 4),
            Center(child: _TransferArrow(active: _selectedCalc != null)),
            const SizedBox(height: 4),
            _sectionLabel('DESTINO'),
            const SizedBox(height: 8),
            _transferCard(children: [
              _pickerRow(
                icon: Icons.calendar_today,
                label: _destMonth != null
                    ? _monthNames[_destMonth! - 1]
                    : 'Selecionar mês de destino',
                placeholder: _destMonth == null,
                onTap: _pickDestMonth,
              ),
            ]),
            const SizedBox(height: 36),
            AnimatedOpacity(
              opacity: _canCopy ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: ElevatedButton(
                onPressed: _canCopy && !_copying ? _doCopy : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _copying
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text(
                        'Confirmar cópia',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.grey[500],
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }

  Widget _transferCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _pickerRow({
    required IconData icon,
    required String label,
    required bool placeholder,
    String? subtitle,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: placeholder ? Colors.grey[100] : kPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                color: placeholder ? Colors.grey[400] : kPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: placeholder ? Colors.grey[400] : Colors.black87,
                      fontWeight:
                          placeholder ? FontWeight.w400 : FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[350], size: 20),
          ],
        ),
      ),
    );
  }
}

class _TransferArrow extends StatelessWidget {
  final bool active;

  const _TransferArrow({Key? key, required this.active}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lineColor =
        active ? kPrimary.withValues(alpha: 0.35) : Colors.grey[300]!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 2, height: 18, color: lineColor),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: active ? kPrimary : Colors.grey[200],
              shape: BoxShape.circle,
              boxShadow: active
                  ? [
                      BoxShadow(
                          color: kPrimary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ]
                  : [],
            ),
            child: Icon(
              Icons.arrow_downward_rounded,
              color: active ? Colors.white : Colors.grey[400],
              size: 18,
            ),
          ),
          Container(width: 2, height: 18, color: lineColor),
        ],
      ),
    );
  }
}

class _MonthPickerSheet extends StatelessWidget {
  final int? excluded;

  const _MonthPickerSheet({Key? key, this.excluded}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Selecionar mês',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 12,
            itemBuilder: (_, i) {
              final month = i + 1;
              final isExcluded = month == excluded;
              return GestureDetector(
                onTap: isExcluded
                    ? null
                    : () => Navigator.pop(context, month),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isExcluded
                        ? Colors.grey[100]
                        : kPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isExcluded
                          ? Colors.transparent
                          : kPrimary.withValues(alpha: 0.2),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _monthNames[i].substring(0, 3),
                    style: TextStyle(
                      color: isExcluded ? Colors.grey[400] : kPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
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

class _CalcPickerSheet extends StatelessWidget {
  final List<MonthData> calculations;

  const _CalcPickerSheet({Key? key, required this.calculations})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currency =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Selecionar cálculo',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...calculations.map((calc) {
            final isMarket = calc.type == CalculationType.market;
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  isMarket
                      ? Icons.shopping_cart_outlined
                      : Icons.payments_outlined,
                  color: kPrimary,
                  size: 20,
                ),
              ),
              title: Text(calc.title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                isMarket
                    ? '${calc.totalItems} itens · ${currency.format(calc.totalExpenses)}'
                    : 'Sobra: ${currency.format(calc.sobra)}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing:
                  const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD)),
              onTap: () => Navigator.pop(context, calc),
            );
          }).toList(),
        ],
      ),
    );
  }
}
