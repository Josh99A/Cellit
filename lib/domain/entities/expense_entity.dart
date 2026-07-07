import 'package:equatable/equatable.dart';

class ExpenseEntity extends Equatable {
  final int? id;
  final String createdById;
  final String category;
  final int amount;
  final String? description;
  final String date;
  final String? createdAt;
  final String? updatedAt;

  const ExpenseEntity({
    this.id,
    required this.createdById,
    required this.category,
    required this.amount,
    this.description,
    required this.date,
    this.createdAt,
    this.updatedAt,
  });

  ExpenseEntity copyWith({
    int? id,
    String? createdById,
    String? category,
    int? amount,
    String? description,
    String? date,
    String? createdAt,
    String? updatedAt,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      createdById: createdById ?? this.createdById,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    createdById,
    category,
    amount,
    description,
    date,
    createdAt,
    updatedAt,
  ];
}
