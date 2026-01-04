//import '../models/favorite_item.dart';

class FavoriteItem {
  final String id;
  final String name;
  final String image;
  final String price;
  final String oldPrice;
  final String brand;
  final String tag;
  final String rating;
  final int reviewCount;

  FavoriteItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.oldPrice,
    required this.brand,
    required this.tag,
    required this.rating,
    required this.reviewCount,
  });
}
