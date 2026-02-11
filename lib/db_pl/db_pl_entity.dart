class BillEntity {
  final int? id;
  final String type;
  final String category;
  final String? subCategory;
  final double amount;
  final String date;
  final String? note;
  final String createdAt;
  final String updatedAt;
  BillEntity({
    this.id,
    required this.type,
    required this.category,
    this.subCategory,
    required this.amount,
    required this.date,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'sub_category': subCategory,
      'amount': amount,
      'date': date,
      'note': note,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
  factory BillEntity.fromMap(Map<String, dynamic> map) {
    return BillEntity(
      id: map['id'] as int?,
      type: map['type'] as String,
      category: map['category'] as String,
      subCategory: map['sub_category'] as String?,
      amount: map['amount'] as double,
      date: map['date'] as String,
      note: map['note'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
  BillEntity copyWith({
    int? id,
    String? type,
    String? category,
    String? subCategory,
    double? amount,
    String? date,
    String? note,
    String? createdAt,
    String? updatedAt,
  }) {
    return BillEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
class BudgetEntity {
  final int? id;
  final String month;
  final double amount;
  final String? category;
  final String createdAt;
  BudgetEntity({
    this.id,
    required this.month,
    required this.amount,
    this.category,
    required this.createdAt,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'month': month,
      'amount': amount,
      'category': category,
      'created_at': createdAt,
    };
  }
  factory BudgetEntity.fromMap(Map<String, dynamic> map) {
    return BudgetEntity(
      id: map['id'] as int?,
      month: map['month'] as String,
      amount: map['amount'] as double,
      category: map['category'] as String?,
      createdAt: map['created_at'] as String,
    );
  }
  BudgetEntity copyWith({
    int? id,
    String? month,
    double? amount,
    String? category,
    String? createdAt,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      month: month ?? this.month,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  bool get isTotal => category == null;
  bool get isCategory => category != null;
}
class TemplateEntity {
  final int? id;
  final String name;
  final String type;
  final String category;
  final String? subCategory;
  final double amount;
  final String? note;
  final String createdAt;
  final String updatedAt;
  TemplateEntity({
    this.id,
    required this.name,
    required this.type,
    required this.category,
    this.subCategory,
    required this.amount,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'category': category,
      'sub_category': subCategory,
      'amount': amount,
      'note': note,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
  factory TemplateEntity.fromMap(Map<String, dynamic> map) {
    return TemplateEntity(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String,
      category: map['category'] as String,
      subCategory: map['sub_category'] as String?,
      amount: map['amount'] as double,
      note: map['note'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
  TemplateEntity copyWith({
    int? id,
    String? name,
    String? type,
    String? category,
    String? subCategory,
    double? amount,
    String? note,
    String? createdAt,
    String? updatedAt,
  }) {
    return TemplateEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
