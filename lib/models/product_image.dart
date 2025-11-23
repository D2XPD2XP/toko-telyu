class ProductImage {
  String _imageId;
  String _imageUrl;

  ProductImage(
    this._imageId,
    this._imageUrl,
  );

  factory ProductImage.fromFirestore(
      Map<String, dynamic> data, String imageId) {
    return ProductImage(
      imageId,
      data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'imageUrl': _imageUrl,
    };
  }

  // Getters
  String get imageId => _imageId;
  String get imageUrl => _imageUrl;

  // Setters
  void setImageId(String id) => _imageId = id;
  void setImageUrl(String url) => _imageUrl = url;
}


