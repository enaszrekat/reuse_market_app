class CartItem {
  final int productId;
  final String title;
  final String imageUrl;
  final double price;
  int quantity;

  CartItem({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: int.tryParse(json['productId']?.toString() ?? "") ?? 0,
      title: json['title']?.toString() ?? "",
      imageUrl: json['imageUrl']?.toString() ?? "",
      price: double.tryParse(json['price']?.toString() ?? "0") ?? 0.0,
      quantity: int.tryParse(json['quantity']?.toString() ?? "1") ?? 1,
    );
  }
}

