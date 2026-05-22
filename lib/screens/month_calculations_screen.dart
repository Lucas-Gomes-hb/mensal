import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/month_data.dart';
import '../services/storage_service.dart';
import '../widgets/add_calculation_sheet.dart';
import '../app_theme.dart';
import 'month_detail_screen.dart';

const _monthNames = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril',
  'Maio', 'Junho', 'Julho', 'Agosto',
  'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

class MonthCalculationsScreen extends StatefulWidget {
  final int year;
  final int month;

  const MonthCalculationsScreen(
      {Key? key, required this.year, required this.month})
      : super(key: key);

  @override
  _MonthCalculationsScreenState createState() =>
      _MonthCalculationsScreenState();
}

class _MonthCalculationsScreenState extends State<MonthCalculationsScreen> {
  final _storage = StorageService();
  List<MonthData> _calculations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data =
        await _storage.loadMonthCalculations(widget.year, widget.month);
    if (mounted) {
      setState(() {
        _calculations = data;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    await _storage.saveMonthCalculations(
        widget.year, widget.month, _calculations);
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddCalculationSheet(
        onCreate: (type, title) => _handleCreate(type, title),
      ),
    );
  }

  Future<void> _handleCreate(CalculationType type, String title) async {
    final defaultLabel =
        type == CalculationType.market ? 'Orçamento' : 'Salário';
    final newEntry = MonthData(
      title: title,
      type: type,
      incomeLabel: defaultLabel,
    );
    setState(() => _calculations.insert(0, newEntry));
    await _save();
    _openCalculation(newEntry);
  }

  Future<void> _openCalculation(MonthData data) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MonthDetailScreen(
          year: widget.year,
          month: widget.month,
          initialData: data,
        ),
      ),
    );
    _load();
  }

  Future<void> _renameCalculation(MonthData data) async {
    final controller = TextEditingController(text: data.title);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renomear cálculo'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Nome do cálculo'),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        final idx = _calculations.indexWhere((e) => e.id == data.id);
        if (idx >= 0) _calculations[idx].title = result;
      });
      await _save();
    }
  }

  Future<void> _changeType(MonthData data) async {
    final newType = await showDialog<CalculationType>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Alterar tipo do cálculo'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, CalculationType.salary),
            child: Row(
              children: [
                Icon(
                  Icons.payments_outlined,
                  color: data.type == CalculationType.salary
                      ? kPrimary
                      : Colors.grey[600],
                ),
                const SizedBox(width: 12),
                Text(
                  'Controle de Salário',
                  style: TextStyle(
                    fontWeight: data.type == CalculationType.salary
                        ? FontWeight.w700
                        : FontWeight.normal,
                    color: data.type == CalculationType.salary
                        ? kPrimary
                        : null,
                  ),
                ),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, CalculationType.market),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  color: data.type == CalculationType.market
                      ? kPrimary
                      : Colors.grey[600],
                ),
                const SizedBox(width: 12),
                Text(
                  'Lista de Mercado',
                  style: TextStyle(
                    fontWeight: data.type == CalculationType.market
                        ? FontWeight.w700
                        : FontWeight.normal,
                    color: data.type == CalculationType.market
                        ? kPrimary
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (newType != null && newType != data.type) {
      setState(() {
        final idx = _calculations.indexWhere((e) => e.id == data.id);
        if (idx >= 0) {
          _calculations[idx].type = newType;
          if (_calculations[idx].incomeLabel == 'Salário' ||
              _calculations[idx].incomeLabel == 'Orçamento') {
            _calculations[idx].incomeLabel =
                newType == CalculationType.market ? 'Orçamento' : 'Salário';
          }
        }
      });
      await _save();
    }
  }

  Future<void> _deleteCalculation(MonthData data) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir cálculo'),
        content: Text(
            'Deseja excluir "${data.title}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _calculations.removeWhere((e) => e.id == data.id));
      await _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthName = _monthNames[widget.month - 1];
    final currency = NumberFormat.currency(
        locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: Text('$monthName ${widget.year}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _calculations.isEmpty
              ? _EmptyCalculations(onAdd: _showAddSheet)
              : ReorderableListView.builder(
                  padding: const EdgeInsets.only(top: 12, bottom: 80),
                  buildDefaultDragHandles: false,
                  itemCount: _calculations.length,
                  onReorderItem: (oldIndex, newIndex) {
                    setState(() {
                      final item = _calculations.removeAt(oldIndex);
                      _calculations.insert(newIndex, item);
                    });
                    _save();
                  },
                  itemBuilder: (_, i) {
                    final calc = _calculations[i];
                    return ReorderableDelayedDragStartListener(
                      key: ValueKey(calc.id),
                      index: i,
                      child: _CalculationCard(
                        data: calc,
                        currency: currency,
                        onTap: () => _openCalculation(calc),
                        onRename: () => _renameCalculation(calc),
                        onChangeType: () => _changeType(calc),
                        onDelete: () => _deleteCalculation(calc),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CalculationCard extends StatelessWidget {
  final MonthData data;
  final NumberFormat currency;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onChangeType;
  final VoidCallback onDelete;

  const _CalculationCard({
    Key? key,
    required this.data,
    required this.currency,
    required this.onTap,
    required this.onRename,
    required this.onChangeType,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMarket = data.type == CalculationType.market;
    final icon =
        isMarket ? Icons.shopping_cart_outlined : Icons.payments_outlined;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.drag_handle, color: Colors.grey[300], size: 20),
              const SizedBox(width: 10),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: kPrimary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    if (isMarket)
                      Text(
                        '${data.totalItems} ${data.totalItems == 1 ? 'item' : 'itens'} · ${currency.format(data.totalExpenses)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      )
                    else
                      Text(
                        'Sobra: ${currency.format(data.sobra)}',
                        style: TextStyle(
                          color: data.sobra >= 0
                              ? kSobraPositive
                              : kSobraNegative,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<_CardAction>(
                icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                onSelected: (action) {
                  if (action == _CardAction.rename) onRename();
                  if (action == _CardAction.changeType) onChangeType();
                  if (action == _CardAction.delete) onDelete();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: _CardAction.rename,
                    child: Row(
                      children: const [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 10),
                        Text('Renomear'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _CardAction.changeType,
                    child: Row(
                      children: const [
                        Icon(Icons.swap_horiz_outlined, size: 18),
                        SizedBox(width: 10),
                        Text('Alterar tipo'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _CardAction.delete,
                    child: Row(
                      children: const [
                        Icon(Icons.delete_outline,
                            size: 18, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Excluir',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _CardAction { rename, changeType, delete }

class _EmptyCalculations extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyCalculations({Key? key, required this.onAdd}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calculate_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Nenhum cálculo ainda.',
            style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em + para começar.',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Novo cálculo'),
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
          ),
        ],
      ),
    );
  }
}
