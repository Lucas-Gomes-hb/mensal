import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/month_data.dart';
import '../services/storage_service.dart';
import '../widgets/expense_tile.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/sobra_bar.dart';
import '../app_theme.dart';

const _monthNames = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril',
  'Maio', 'Junho', 'Julho', 'Agosto',
  'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

class MonthDetailScreen extends StatefulWidget {
  final int year;
  final int month;
  final MonthData initialData;

  const MonthDetailScreen({
    Key? key,
    required this.year,
    required this.month,
    required this.initialData,
  }) : super(key: key);

  @override
  _MonthDetailScreenState createState() => _MonthDetailScreenState();
}

class _MonthDetailScreenState extends State<MonthDetailScreen> {
  final _storage = StorageService();
  late MonthData _data;
  final _incomeController = TextEditingController();

  bool get _isMarket => _data.type == CalculationType.market;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
    _incomeController.text = _data.income > 0
        ? _data.income.toStringAsFixed(2).replaceAll('.', ',')
        : '';
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final all =
        await _storage.loadMonthCalculations(widget.year, widget.month);
    final idx = all.indexWhere((e) => e.id == _data.id);
    if (idx >= 0) {
      all[idx] = _data;
    } else {
      all.add(_data);
    }
    await _storage.saveMonthCalculations(widget.year, widget.month, all);
  }

  void _onIncomeSubmitted(String raw) {
    final value = double.tryParse(raw.trim().replaceAll(',', '.')) ?? 0.0;
    setState(() => _data.income = value);
    _save();
  }

  void _editLabel() {
    final controller = TextEditingController(text: _data.incomeLabel);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_isMarket ? 'Nome do orçamento' : 'Nome da entrada'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: _isMarket
                ? 'Ex: Orçamento, Limite...'
                : 'Ex: Salário, Freelance...',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final label = controller.text.trim();
              if (label.isNotEmpty) {
                setState(() => _data.incomeLabel = label);
                _save();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showAddSheet({Expense? editing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddExpenseSheet(
        editing: editing,
        type: _data.type,
        onAdd: (value, desc, qty) {
          setState(() {
            if (editing != null) {
              editing.value = value;
              editing.description = desc;
              editing.quantity = qty;
            } else {
              _data.expenses.insert(
                0,
                Expense(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  value: value,
                  description: desc,
                  quantity: qty,
                ),
              );
            }
          });
          _save();
        },
      ),
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
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
            const SizedBox(height: 16),
            const Text(
              'Compartilhar via WhatsApp',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.format_list_bulleted,
                    color: Color(0xFF388E3C)),
              ),
              title: const Text('Compartilhar lista',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Texto formatado com todos os itens'),
              onTap: () {
                Navigator.pop(context);
                _shareList();
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.code, color: Color(0xFF1976D2)),
              ),
              title: const Text('Compartilhar código',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Código para importar em outro dispositivo'),
              onTap: () {
                Navigator.pop(context);
                _shareCode();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareList() {
    final monthName = _monthNames[widget.month - 1];
    final currency =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);

    final sb = StringBuffer();
    sb.writeln('📋 *${_data.title} - $monthName ${widget.year}*');
    sb.writeln('');
    sb.writeln('💰 ${_data.incomeLabel}: ${currency.format(_data.income)}');
    sb.writeln('');
    if (_data.expenses.isNotEmpty) {
      sb.writeln(_isMarket ? '🛒 *Itens:*' : '📋 *Gastos:*');
      for (final e in _data.expenses) {
        if (_isMarket && e.quantity > 1) {
          sb.writeln(
              '• ${e.description}: ${e.quantity} × ${currency.format(e.value)} = ${currency.format(e.total)}');
        } else {
          sb.writeln('• ${e.description}: ${currency.format(e.total)}');
        }
      }
      sb.writeln('');
    }
    sb.writeln('💸 Total: ${currency.format(_data.totalExpenses)}');
    if (_isMarket) {
      if (_data.income > 0) {
        sb.writeln('✅ Sobra: ${currency.format(_data.sobra)}');
      }
    } else {
      sb.writeln('✅ Sobra: ${currency.format(_data.sobra)}');
    }

    final encoded = Uri.encodeComponent(sb.toString());
    // ignore: deprecated_member_use
    launch('whatsapp://send?text=$encoded');
  }

  void _shareCode() {
    final monthName = _monthNames[widget.month - 1];
    final code = base64Encode(utf8.encode(jsonEncode(_data.toJson())));

    final sb = StringBuffer();
    sb.writeln('📥 *Código de importação*');
    sb.writeln('*${_data.title} - $monthName ${widget.year}*');
    sb.writeln('');
    sb.write(code);

    final encoded = Uri.encodeComponent(sb.toString());
    // ignore: deprecated_member_use
    launch('whatsapp://send?text=$encoded');
  }

  void _importFromCode() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Importar dados'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Cole o código de importação aqui',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              try {
                final code = controller.text.trim();
                final decoded =
                    jsonDecode(utf8.decode(base64Decode(code)));
                final imported =
                    MonthData.fromJson(decoded as Map<String, dynamic>);
                imported.id = _data.id;
                setState(() {
                  _data = imported;
                  _incomeController.text = _data.income > 0
                      ? _data.income.toStringAsFixed(2).replaceAll('.', ',')
                      : '';
                });
                _save();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Dados importados com sucesso!')),
                );
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Código inválido. Verifique e tente novamente.')),
                );
              }
            },
            child: const Text('Importar'),
          ),
        ],
      ),
    );
  }

  void _deleteExpense(Expense expense) {
    final index = _data.expenses.indexOf(expense);
    setState(() => _data.expenses.remove(expense));
    _save();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item removido'),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () {
            setState(() => _data.expenses.insert(index, expense));
            _save();
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: Text(_data.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Importar',
            onPressed: _importFromCode,
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Compartilhar',
            onPressed: _showShareOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          _SaldoHeader(
            label: _data.incomeLabel,
            incomeController: _incomeController,
            income: _data.income,
            totalExpenses: _data.totalExpenses,
            totalItems: _data.totalItems,
            isMarket: _isMarket,
            currency: currency,
            onEditLabel: _editLabel,
            onIncomeSubmitted: _onIncomeSubmitted,
          ),
          Expanded(
            child: _data.expenses.isEmpty
                ? _EmptyState(onAdd: () => _showAddSheet())
                : ReorderableListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    buildDefaultDragHandles: false,
                    itemCount: _data.expenses.length,
                    onReorderItem: (oldIndex, newIndex) {
                      setState(() {
                        final item = _data.expenses.removeAt(oldIndex);
                        _data.expenses.insert(newIndex, item);
                      });
                      _save();
                    },
                    itemBuilder: (_, i) {
                      final expense = _data.expenses[i];
                      return ReorderableDelayedDragStartListener(
                        key: ValueKey(expense.id),
                        index: i,
                        child: ExpenseTile(
                          expense: expense,
                          showDragHandle: true,
                          onDelete: () => _deleteExpense(expense),
                          onEdit: () => _showAddSheet(editing: expense),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SobraBar(sobra: _data.sobra),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SaldoHeader extends StatelessWidget {
  final String label;
  final TextEditingController incomeController;
  final double income;
  final double totalExpenses;
  final int totalItems;
  final bool isMarket;
  final NumberFormat currency;
  final VoidCallback onEditLabel;
  final void Function(String) onIncomeSubmitted;

  const _SaldoHeader({
    Key? key,
    required this.label,
    required this.incomeController,
    required this.income,
    required this.totalExpenses,
    required this.totalItems,
    required this.isMarket,
    required this.currency,
    required this.onEditLabel,
    required this.onIncomeSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _BottomCurveClipper(),
      child: Container(
        color: kPrimary,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onEditLabel,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit, color: Colors.white54, size: 14),
                ],
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: incomeController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]'))
              ],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                filled: false,
                hintText: '0,00',
                hintStyle:
                    TextStyle(color: Colors.white38, fontSize: 28),
                prefixText: 'R\$ ',
                prefixStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: onIncomeSubmitted,
              onEditingComplete: () {
                onIncomeSubmitted(incomeController.text);
                FocusScope.of(context).unfocus();
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _StatChip(
                  label: 'Gastos',
                  value: currency.format(totalExpenses),
                  color: Colors.red[200]!,
                ),
                const SizedBox(width: 10),
                if (isMarket)
                  _StatChip(
                    label: 'Itens',
                    value: totalItems.toString(),
                    color: Colors.amber[200]!,
                  )
                else
                  _StatChip(
                    label: 'Entradas',
                    value: currency.format(income),
                    color: Colors.green[200]!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip(
      {Key? key, required this.label, required this.value, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 11)),
          const SizedBox(width: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({Key? key, required this.onAdd}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Nenhum item ainda.',
            style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em + para adicionar.',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(
        size.width / 2, size.height + 10, size.width, size.height - 20);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}
