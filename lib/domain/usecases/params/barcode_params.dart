import 'package:equatable/equatable.dart';

class BarcodeParams extends Equatable {
  final String userId;
  final String barcode;

  const BarcodeParams({
    required this.userId,
    required this.barcode,
  });

  @override
  List<Object> get props => [userId, barcode];
}
