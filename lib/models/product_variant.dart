import 'package:uuid/uuid.dart';

class ProductVariant {
  String _variantId;
  String _optionName;
  int _stock;
  double _additionalPrice;

  ProductVariant({
    String? variantId,
    required String optionName,
    required int stock,
    required double additionalPrice,
  })  : _variantId = variantId ?? const Uuid().v4(),
        _optionName = optionName,
        _stock = stock,
        _additionalPrice = additionalPrice;

  factory ProductVariant.fromMap(Map<String, dynamic> map, String id) {
    return ProductVariant(
      variantId: id,
      optionName: map['optionName'] ?? '',
      stock: (map['stock'] ?? 0).toInt(),
      additionalPrice: (map['additionalPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'variantId': _variantId,
      'optionName': _optionName,
      'stock': _stock,
      'additionalPrice': _additionalPrice,
    };
  }

  String get variantId => _variantId;
  String get optionName => _optionName;
  int get stock => _stock;
  double get additionalPrice => _additionalPrice;

  set variantId(String value) => _variantId = value;
  set optionName(String value) => _optionName = value;
  set stock(int value) => _stock = value;
  set additionalPrice(double value) => _additionalPrice = value;
}

