import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';

final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);

class SobraBar extends StatefulWidget {
  final double sobra;

  const SobraBar({Key? key, required this.sobra}) : super(key: key);

  @override
  _SobraBarState createState() => _SobraBarState();
}

class _SobraBarState extends State<SobraBar> {
  bool _showHalf = false;

  @override
  Widget build(BuildContext context) {
    final isNegative = widget.sobra < 0;
    final sobraColor = isNegative ? kSobraNegative : Colors.white;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryDark, Color(0xFF00695C)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sobra',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _currency.format(widget.sobra),
                    style: TextStyle(
                      color: sobraColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            if (_showHalf) ...[
              Container(width: 1, height: 40, color: Colors.white24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sobra ÷ 2',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currency.format(widget.sobra / 2),
                      style: TextStyle(
                        color: sobraColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            IconButton(
              onPressed: () => setState(() => _showHalf = !_showHalf),
              icon: Icon(
                _showHalf ? Icons.close : Icons.call_split,
                color: Colors.white70,
                size: 22,
              ),
              tooltip: _showHalf ? 'Ocultar metade' : 'Ver ÷ 2',
            ),
          ],
        ),
      ),
    );
  }
}
