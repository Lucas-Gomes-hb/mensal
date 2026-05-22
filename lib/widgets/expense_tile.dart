import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/month_data.dart';

final _currency =
    NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final bool showDragHandle;

  const ExpenseTile({
    Key? key,
    required this.expense,
    required this.onDelete,
    required this.onEdit,
    this.showDragHandle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final showBreakdown = expense.quantity > 1;

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFD32F2F),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.only(left: 16, right: 4, top: 4, bottom: 4),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_upward,
                color: Color(0xFFD32F2F), size: 20),
          ),
          title: Text(
            expense.description.isEmpty ? 'Sem descrição' : expense.description,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _currency.format(expense.total),
                style: const TextStyle(
                  color: Color(0xFFD32F2F),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              if (showBreakdown)
                Text(
                  '${expense.quantity}× ${_currency.format(expense.value)}/un',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: Colors.grey[500],
                splashRadius: 20,
                onPressed: onEdit,
                tooltip: 'Editar',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.red[300],
                splashRadius: 20,
                onPressed: onDelete,
                tooltip: 'Remover',
              ),
              if (showDragHandle)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(Icons.drag_handle,
                      color: Colors.grey[350], size: 22),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
