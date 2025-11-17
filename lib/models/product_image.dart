import 'package:uuid/uuid.dart';

class ProductImage {
  String _imageId;
  String _imageUrl;

  ProductImage({
    String? imageId,
    required String imageUrl,
  })  : _imageId = imageId ?? const Uuid().v4(),
        _imageUrl = imageUrl;

  factory ProductImage.fromMap(Map<String, dynamic> map, String id) {
    return ProductImage(
      imageId: id,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageId': _imageId,
      'imageUrl': _imageUrl,
    };
  }

  String get imageId => _imageId;
  String get imageUrl => _imageUrl;

  set imageId(String value) => _imageId = value;
  set imageUrl(String value) => _imageUrl = value;
}

