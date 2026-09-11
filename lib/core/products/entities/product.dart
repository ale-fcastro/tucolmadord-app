enum SellMode { unit, weight, amount }

SellMode sellModeFromString(String value) => SellMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => SellMode.unit,
    );

class Product {
  final String id;
  final String name;
  final double? price;
  final double? cost;
  final SellMode mode;
  final String category;
  final bool isFrequent;
  final bool trackStock;
  final double? stock;
  final double? minStock;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.cost,
    required this.mode,
    required this.category,
    required this.isFrequent,
    required this.trackStock,
    required this.stock,
    required this.minStock,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isLowStock => trackStock && stock != null && minStock != null && stock! <= minStock!;
  bool get isOutOfStock => trackStock && stock != null && stock! <= 0;

  Product copyWith({
    String? name,
    double? price,
    double? cost,
    SellMode? mode,
    String? category,
    bool? isFrequent,
    bool? trackStock,
    double? stock,
    double? minStock,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      mode: mode ?? this.mode,
      category: category ?? this.category,
      isFrequent: isFrequent ?? this.isFrequent,
      trackStock: trackStock ?? this.trackStock,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'price': price,
        'cost': cost,
        'mode': mode.name,
        'category': category,
        'is_frequent': isFrequent ? 1 : 0,
        'track_stock': trackStock ? 1 : 0,
        'stock': stock,
        'min_stock': minStock,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'] as String,
        name: map['name'] as String,
        price: (map['price'] as num?)?.toDouble(),
        cost: (map['cost'] as num?)?.toDouble(),
        mode: sellModeFromString(map['mode'] as String),
        category: map['category'] as String,
        isFrequent: (map['is_frequent'] as int) == 1,
        trackStock: (map['track_stock'] as int) == 1,
        stock: (map['stock'] as num?)?.toDouble(),
        minStock: (map['min_stock'] as num?)?.toDouble(),
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: DateTime.parse(map['updated_at'] as String),
      );
}
