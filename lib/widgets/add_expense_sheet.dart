import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/month_data.dart';
import '../app_theme.dart';

class AddExpenseSheet extends StatefulWidget {
  final Expense? editing;
  final CalculationType type;
  final void Function(double value, String description, int quantity) onAdd;

  const AddExpenseSheet({
    Key? key,
    this.editing,
    this.type = CalculationType.salary,
    required this.onAdd,
  }) : super(key: key);

  @override
  _AddExpenseSheetState createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _valueController = TextEditingController();
  final _descController = TextEditingController();
  final _qtyController = TextEditingController();
  final _valueFocus = FocusNode();
  final _descFocus = FocusNode();
  final _qtyFocus = FocusNode();

  bool get _isMarket => widget.type == CalculationType.market;

  @override
  void initState() {
    super.initState();
    if (widget.editing != null) {
      _valueController.text =
          widget.editing!.value.toStringAsFixed(2).replaceAll('.', ',');
      _descController.text = widget.editing!.description;
      _qtyController.text = widget.editing!.quantity.toString();
    } else {
      _qtyController.text = '1';
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _descController.dispose();
    _qtyController.dispose();
    _valueFocus.dispose();
    _descFocus.dispose();
    _qtyFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _valueController.text.trim().replaceAll(',', '.');
    final value = double.tryParse(raw);
    if (value == null || value <= 0) {
      _valueFocus.requestFocus();
      return;
    }
    final desc = _descController.text.trim();
    final qty = int.tryParse(_qtyController.text.trim()) ?? 1;
    final quantity = qty < 1 ? 1 : qty;
    widget.onAdd(value, desc, quantity);
    if (widget.editing == null) {
      _valueController.clear();
      _descController.clear();
      _qtyController.text = '1';
      _valueFocus.requestFocus();
    } else {
      Navigator.of(context).pop();
    }
  }

  String _buildPreview() {
    final raw = _valueController.text.trim().replaceAll(',', '.');
    final value = double.tryParse(raw) ?? 0;
    final qty = int.tryParse(_qtyController.text.trim()) ?? 1;
    if (value <= 0 || qty <= 1) return '';
    final currency =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);
    return '$qty × ${currency.format(value)} = ${currency.format(value * qty)}';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editing != null;
    final preview = _isMarket ? _buildPreview() : '';

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                isEditing ? 'Editar item' : 'Adicionar item',
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _valueController,
                      focusNode: _valueFocus,
                      autofocus: true,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
                      ],
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _isMarket
                          ? _qtyFocus.requestFocus()
                          : _descFocus.requestFocus(),
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Valor',
                        hintText: '0,00',
                        prefixText: 'R\$ ',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (_isMarket) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _qtyController,
                        focusNode: _qtyFocus,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _descFocus.requestFocus(),
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Qtd',
                          hintText: '1',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _descController,
                      focusNode: _descFocus,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Descrição',
                        hintText: _isMarket
                            ? 'Ex: Arroz, Feijão...'
                            : 'Ex: Aluguel, Mercado...',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccent,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(14),
                        minimumSize: Size.zero,
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
            if (_isMarket && preview.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.only(left: 16, right: 16, bottom: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    preview,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            if (!isEditing)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fechar'),
                ),
              )
            else
              const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
