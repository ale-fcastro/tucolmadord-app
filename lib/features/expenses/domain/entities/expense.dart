class Expense {
  final String id;
  final double amount;
  final String concept;
  final String category;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.amount,
    required this.concept,
    required this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'amount': amount,
    'concept': concept,
    'category': category,
    'created_at': createdAt.toIso8601String(),
  };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
    id: map['id'] as String,
    amount: (map['amount'] as num).toDouble(),
    concept: map['concept'] as String,
    category: map['category'] as String,
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}
