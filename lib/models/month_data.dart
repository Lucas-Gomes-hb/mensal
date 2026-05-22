enum CalculationType { salary, market }

class Expense {
  final String id;
  double value;
  String description;
  int quantity;

  Expense({
    required this.id,
    required this.value,
    required this.description,
    this.quantity = 1,
  });

  double get total => value * quantity;

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String,
        value: (json['value'] as num).toDouble(),
        description: json['description'] as String,
        quantity: (json['quantity'] as int?) ?? 1,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'value': value,
        'description': description,
        'quantity': quantity,
      };
}

class MonthData {
  String id;
  String title;
  CalculationType type;
  double income;
  String incomeLabel;
  List<Expense> expenses;

  MonthData({
    String? id,
    this.title = 'Controle de Salário',
    this.type = CalculationType.salary,
    this.income = 0.0,
    this.incomeLabel = 'Salário',
    List<Expense>? expenses,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        expenses = expenses ?? [];

  double get totalExpenses => expenses.fold(0.0, (s, e) => s + e.total);
  double get sobra => income - totalExpenses;
  int get totalItems => expenses.fold(0, (s, e) => s + e.quantity);

  factory MonthData.fromJson(Map<String, dynamic> json) => MonthData(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] as String? ?? 'Controle de Salário',
        type: json['type'] == 'market' ? CalculationType.market : CalculationType.salary,
        income: (json['income'] as num? ?? 0).toDouble(),
        incomeLabel: json['incomeLabel'] as String? ?? 'Salário',
        expenses: ((json['expenses'] as List<dynamic>?) ?? [])
            .map((e) => Expense.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type == CalculationType.market ? 'market' : 'salary',
        'income': income,
        'incomeLabel': incomeLabel,
        'expenses': expenses.map((e) => e.toJson()).toList(),
      };
}
