import '../../domain/entities/product_entity.dart';

class ProductModel {
  int id;
  String createdById;
  String name;
  String imageUrl;
  String? barcode;
  int stock;
  int sold;
  int price;
  int? costPrice;
  String? description;
  String? createdAt;
  String? updatedAt;

  ProductModel({
    required this.id,
    required this.createdById,
    required this.name,
    required this.imageUrl,
    this.barcode,
    required this.stock,
    required this.sold,
    required this.price,
    this.costPrice,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      createdById: json['createdById'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      barcode: json['barcode'],
      stock: json['stock'],
      sold: json['sold'],
      price: json['price'],
      costPrice: json['costPrice'],
      description: json['description'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdById': createdById,
      'name': name,
      'imageUrl': imageUrl,
      'barcode': barcode,
      'stock': stock,
      'sold': sold,
      'price': price,
      'costPrice': costPrice,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id ?? DateTime.now().millisecondsSinceEpoch,
      createdById: entity.createdById,
      name: entity.name,
      imageUrl: entity.imageUrl,
      barcode: entity.barcode,
      stock: entity.stock,
      sold: entity.sold ?? 0,
      price: entity.price,
      costPrice: entity.costPrice,
      description: entity.description,
      createdAt: entity.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: entity.updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      createdById: createdById,
      name: name,
      imageUrl: imageUrl,
      barcode: barcode,
      stock: stock,
      sold: sold,
      price: price,
      costPrice: costPrice,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
