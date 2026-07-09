import 'dart:io';

class ProductFormState {
  final File? imageFile;
  final String? imageUrl;
  final String? name;
  final String? barcode;
  final int? price;
  final int? costPrice;
  final int? stock;
  final String? description;
  final bool isLoaded;

  const ProductFormState({
    this.imageFile,
    this.imageUrl,
    this.name,
    this.barcode,
    this.price,
    this.costPrice,
    this.stock,
    this.description,
    this.isLoaded = false,
  });

  ProductFormState copyWith({
    File? imageFile,
    String? imageUrl,
    String? name,
    String? barcode,
    int? price,
    int? costPrice,
    int? stock,
    String? description,
    bool? isLoaded,
  }) {
    return ProductFormState(
      imageFile: imageFile ?? this.imageFile,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}
