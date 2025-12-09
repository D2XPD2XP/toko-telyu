import 'dart:io';

class ProductImage {
  String _imageId;
  String _imageUrl;
  File? file;

  ProductImage(this._imageId, this._imageUrl, {this.file});

  factory ProductImage.fromFirestore(
    Map<String, dynamic> data,
    String imageId,
  ) {
    return ProductImage(imageId, data['image_url']);
  }

  Map<String, dynamic> toFirestore() {
    return {'image_url': _imageUrl};
  }

  // Getters
  String get imageId => _imageId;
  String get imageUrl => _imageUrl;

  // Setters
  void setImageId(String id) => _imageId = id;
  void setImageUrl(String url) => _imageUrl = url;
}
