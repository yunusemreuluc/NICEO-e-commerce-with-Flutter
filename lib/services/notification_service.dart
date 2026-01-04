import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final String type; // "order", "promo", "price", ...
  bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.type,
    this.read = false,
  });
}

class NotificationService extends ChangeNotifier {
  final _uuid = const Uuid();

  // ————— Ayarlar (switch’ler)
  bool pushEnabled = true;
  bool emailEnabled = false;

  bool orderUpdatesEnabled = true; // Sipariş Güncellemeleri
  bool marketingEnabled = true; // Kampanya ve indirimler
  bool favoritesEnabled = true; // Favori Ürün Güncellemeleri
  bool priceDropEnabled = true; // Fiyat Düşüş Bildirimleri

  // ————— Bildirim listesi (mock)
  final List<AppNotification> _items = [
    AppNotification(
      id: const Uuid().v4(),
      title: "Siparişiniz Kargoya Verildi",
      body:
          "ORD-2024-003 numaralı siparişiniz kargoya verildi. Takip: TRK123456789",
      date: DateTime(2024, 1, 25),
      type: "order",
      read: false,
    ),
    AppNotification(
      id: const Uuid().v4(),
      title: "Özel İndirim!",
      body: "Favori ürünlerinizde %25 indirim! Sınırlı süre.",
      date: DateTime(2024, 1, 24),
      type: "promo",
      read: false,
    ),
    AppNotification(
      id: const Uuid().v4(),
      title: "Fiyat Düşüşü",
      body: "Sepetindeki iPhone 13 Pro Max için ₺500 fiyat düşüşü yakalandı!",
      date: DateTime(2024, 1, 23),
      type: "price",
      read: true,
    ),
  ];

  List<AppNotification> get all => List.unmodifiable(_items);
  List<AppNotification> get unread => _items.where((e) => !e.read).toList();
  int get unreadCount => unread.length;

  void markAsRead(String id) {
    final i = _items.indexWhere((e) => e.id == id);
    if (i >= 0 && !_items[i].read) {
      _items[i].read = true;
      notifyListeners();
    }
  }

  void markAllRead() {
    for (final n in _items) n.read = true;
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void addManual({
    required String title,
    required String body,
    String type = "promo",
  }) {
    _items.insert(
      0,
      AppNotification(
        id: _uuid.v4(),
        title: title,
        body: body,
        date: DateTime.now(),
        type: type,
        read: false,
      ),
    );
    notifyListeners();
  }

  // Ayar değiştiriciler
  void togglePush(bool v) {
    pushEnabled = v;
    notifyListeners();
  }

  void toggleEmail(bool v) {
    emailEnabled = v;
    notifyListeners();
  }

  void toggleOrder(bool v) {
    orderUpdatesEnabled = v;
    notifyListeners();
  }

  void toggleMarketing(bool v) {
    marketingEnabled = v;
    notifyListeners();
  }

  void toggleFavorites(bool v) {
    favoritesEnabled = v;
    notifyListeners();
  }

  void togglePriceDrop(bool v) {
    priceDropEnabled = v;
    notifyListeners();
  }
}
