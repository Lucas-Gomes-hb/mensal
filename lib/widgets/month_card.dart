import 'package:flutter/material.dart';
import '../app_theme.dart';

const _months = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril',
  'Maio', 'Junho', 'Julho', 'Agosto',
  'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

class MonthCard extends StatelessWidget {
  final int month;
  final bool isCurrent;
  final bool isPast;
  final int? count;
  final VoidCallback onTap;

  const MonthCard({
    Key? key,
    required this.month,
    required this.isCurrent,
    required this.isPast,
    required this.onTap,
    this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = _months[month - 1];
    final abbr = name.substring(0, 3).toUpperCase();
    final hasData = count != null && count! > 0;

    Color cardColor;
    Color textColor;
    if (isCurrent) {
      cardColor = kPrimary;
      textColor = Colors.white;
    } else if (isPast && hasData) {
      cardColor = kCard;
      textColor = const Color(0xFF212121);
    } else {
      cardColor = const Color(0xFFEAEAE8);
      textColor = const Color(0xFF9E9E9E);
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                abbr,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(
                  fontSize: 10,
                  color: textColor.withValues(alpha: 0.75),
                ),
                textAlign: TextAlign.center,
              ),
              if (hasData) ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? Colors.white.withValues(alpha: 0.2)
                        : kPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    count == 1 ? '1 cálculo' : '$count cálculos',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isCurrent ? Colors.white : kPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
