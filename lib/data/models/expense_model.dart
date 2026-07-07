import '../../domain/entities/expense_entity.dart';

class ExpenseModel {
  int id;
  String createdById;
  String category;
  int amount;
  String? description;
  String date;
  String? createdAt;
  String? updatedAt;

  ExpenseModel({
    required this.id,
    required this.createdById,
    required this.category,
    required this.amount,
    this.description,
    required this.date,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      createdById: json['createdById'],
      category: json['category'],
      amount: json['amount'],
      description: json['description'],
      date: json['date'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdById': createdById,
      'category': category,
      'amount': amount,
      'description': description,
      'date': date,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id ?? DateTime.now().millisecondsSinceEpoch,
      createdById: entity.createdById,
      category: entity.category,
      amount: entity.amount,
      description: entity.description,
      date: entity.date,
      createdAt: entity.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: entity.updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  ExpenseEntity toEntity() {
    return ExpenseEntity(
      id: id,
      createdById: createdById,
      category: category,
      amount: amount,
      description: description,
      date: date,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
