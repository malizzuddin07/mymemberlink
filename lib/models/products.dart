class Product {
  final int productId;
  final String productName;
  final String productDescription;
  final double productPrice;
  final int productQuantity;
  final String productImage;

  Product({
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    required this.productQuantity,
    required this.productImage,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'],
      productName: json['product_name'],
      productDescription: json['product_description'],
      productPrice: double.parse(json['product_price']),
      productQuantity: json['product_quantity'],
      productImage: json['product_image'],
    );
  }
}
