import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String name;
  final String image;
  final String price;
  final String oldPrice;
  final String color;
  final String warranty;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.oldPrice,
    required this.color,
    required this.warranty,
    required this.quantity,
  });
}

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalPrice {
    double total = 0;
    for (var item in _items) {
      String cleanPrice = item.price
          .replaceAll('₺', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      double price = double.tryParse(cleanPrice) ?? 0;
      total += price * item.quantity;
    }
    return total;
  }

  void addToCart(Map<String, dynamic> product, int quantity) {
    int existingIndex = _items.indexWhere(
      (item) => item.id == (product['id'] ?? product['isim']),
    );

    if (existingIndex >= 0) {
      // Sepette ürün zaten varsa miktarını artır
      _items[existingIndex].quantity += quantity;
    } else {
      // Yeni ürün ekle
      CartItem newItem = CartItem(
        id:
            product['id']?.toString() ??
            product['isim']?.toString() ??
            DateTime.now().toString(),
        name: product['isim']?.toString() ?? 'İsimsiz Ürün',
        image: product['img']?.toString() ?? '',
        price: product['fiyat']?.toString() ?? '₺0',
        oldPrice: product['eskiFiyat']?.toString() ?? '',
        color: product['renk']?.toString() ?? 'Belirtilmemiş',
        warranty: product['garanti']?.toString() ?? '1 Yıl Garanti',
        quantity: quantity,
      );
      _items.add(newItem);
    }
    notifyListeners(); // Sepet güncellendi
  }

  void removeFromCart(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void updateQuantity(String itemId, int newQuantity) {
    int index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
