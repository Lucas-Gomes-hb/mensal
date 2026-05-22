import 'package:flutter/material.dart';
import '../models/month_data.dart';
import '../app_theme.dart';

class AddCalculationSheet extends StatefulWidget {
  final void Function(CalculationType type, String title) onCreate;

  const AddCalculationSheet({Key? key, required this.onCreate})
      : super(key: key);

  @override
  _AddCalculationSheetState createState() => _AddCalculationSheetState();
}

class _AddCalculationSheetState extends State<AddCalculationSheet> {
  CalculationType? _selectedType;
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _selectType(CalculationType type) {
    setState(() {
      _selectedType = type;
      _titleController.text = type == CalculationType.salary
          ? 'Controle de Salário'
          : 'Lista de Mercado';
    });
  }

  void _confirm() {
    final title = _titleController.text.trim();
    if (title.isNotEmpty && _selectedType != null) {
      Navigator.of(context).pop();
      widget.onCreate(_selectedType!, title);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
            const SizedBox(height: 20),
            const Text(
              'Novo cálculo',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _TypeButton(
                    icon: Icons.payments_outlined,
                    label: 'Controle de\nSalário',
                    selected: _selectedType == CalculationType.salary,
                    onTap: () => _selectType(CalculationType.salary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeButton(
                    icon: Icons.shopping_cart_outlined,
                    label: 'Lista de\nMercado',
                    selected: _selectedType == CalculationType.market,
                    onTap: () => _selectType(CalculationType.market),
                  ),
                ),
              ],
            ),
            if (_selectedType != null) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                autofocus: false,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _confirm(),
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Ex: Controle de Salário',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Criar',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color:
              selected ? kPrimary.withValues(alpha: 0.1) : const Color(0xFFF5F5F5),
          border: Border.all(
            color: selected ? kPrimary : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: selected ? kPrimary : Colors.grey[500]),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: selected ? kPrimary : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
