import 'package:flutter/foundation.dart';
import '../models/favorite_item.dart';

class FavoriteService extends ChangeNotifier {
  final List<FavoriteItem> _favorites = [];

  List<FavoriteItem> get favorites => _favorites;

  void addFavorite(Map<String, dynamic> product) {
    if (_favorites.any((item) => item.id == product['id'])) return;
    _favorites.add(
      FavoriteItem(
        id: product['id'] ?? DateTime.now().toString(),
        name: product['isim'] ?? product['name'],
        image: product['img'] ?? '',
        price: product['fiyat'] ?? product['price'],
        oldPrice: product['eskiFiyat'] ?? product['oldPrice'] ?? '',
        brand: product['marka'] ?? 'Apple',
        tag: product['etiket'] ?? 'ÇOK SATAN',
        rating:
            product['puan']?.toString() ?? product['rating']?.toString() ?? '0',
        reviewCount:
            int.tryParse(
              product['deger']?.toString() ??
                  product['review']?.toString() ??
                  '0',
            ) ??
            0,
      ),
    );
    notifyListeners();
  }

  void removeFavorite(String id) {
    _favorites.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
