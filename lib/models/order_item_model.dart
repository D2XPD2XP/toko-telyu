class OrderItem {
  String orderItemId;
  int amount;
  double subtotal;
  String productId;
  String variantId;

  OrderItem({
    required this.orderItemId,
    required this.amount,
    required this.subtotal,
    required this.productId,
    required this.variantId,
  });

  factory OrderItem.fromFirestore(Map<String, dynamic> data, String id) {
    return OrderItem(
      orderItemId: id,
      amount: data['amount'],
      subtotal: (data['subtotal'] as num).toDouble(),
      productId: data['productId'],
      variantId: data['variantId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderItemId': orderItemId,
      'amount': amount,
      'subtotal': subtotal,
      'productId': productId,
      'variantId': variantId,
    };
  }
}

