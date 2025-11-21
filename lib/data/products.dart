import 'package:ecommerce/extensions.dart';

class Products {
  int limit;
  int skip;
  int total;
  List<Product>? products;

  Products(
      {required this.limit,
      required this.skip,
      required this.total,
      required this.products});


  factory Products.fromJson(Map<String, dynamic> json) {
    print("product list ${json}");
    var dynamicLists = json["products"] as List<dynamic>;
    var productList = dynamicLists.map((dynamicData) {
      var dynamicImageList = dynamicData["images"] as List<dynamic>;
      var images = dynamicImageList.map(
        (image) {
          return image.toString();
        },
      ).toList();

      return Product(
          brand: dynamicData["brand"].toString(),
          category: dynamicData["category"].toString(),
          description: dynamicData["description"].toString(),
          discountPercentage:
              double.tryParse(dynamicData["discountPercentage"].toString()) ??
                  0.0,
          id: int.tryParse(dynamicData["id"].toString()) ?? 0,
          images: images,
          price: (double.tryParse(dynamicData["price"].toString()) ?? 0.0).toRupees(),
          rating: double.tryParse(dynamicData["rating"].toString()) ?? 0.0,
          stock: int.tryParse(dynamicData["stock"].toString()) ?? 0,
          thumbnail: dynamicData["thumbnail"].toString(),
          title: dynamicData["title"].toString());
    }).toList();
    return Products(
        limit: json["limit"],
        skip: json["skip"],
        total: json["total"],
        products: productList);
  }
}

class Product {
  String brand;
  String category;
  String description;
  double discountPercentage;
  int id;
  List<String> images;
  double price;
  double rating;
  int stock;
  String thumbnail;
  String title;
  Product({
    required this.brand,
    required this.category,
    required this.description,
    required this.discountPercentage,
    required this.id,
    required this.images,
    required this.price,
    required this.rating,
    required this.stock,
    required this.thumbnail,
    required this.title,
  });
}
