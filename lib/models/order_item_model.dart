class OrderItem {
  String productId;
  String name;
  int price;
  int quantity;
  List<String> imageUrls;

  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrls,
  });

  factory OrderItem.fromFirestore(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      quantity: data['quantity'] ?? 1,
      imageUrls: data['image_urls'] != null
          ? List<String>.from(data['image_urls'])
          : [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image_urls': imageUrls,
    };
  }
}
