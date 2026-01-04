import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../pages/product_detail_page.dart';
import '../services/cart_service.dart';
import '../services/favorite_service.dart';

final List<Map<String, dynamic>> megaDiscounts = [
  {
    "id": "mega_1",
    "name": "iPhone 15 Pro Max 512GB",
    "img": "https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?w=800",
    "discount": "%29 İNDİRİM",
    "time": "23:45:12",
    "review": "847 değerlendirme",
    "rating": "4.9",
    "price": "₺49.999",
    "oldPrice": "₺69.999",
    "savings": "₺20.000",
    "color": "Titanium",
    "warranty": "2 Yıl Garanti",
  },
  {
    "id": "mega_2",
    "name": "AirPods Pro 2. Nesil",
    "img": "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800",
    "discount": "%15 İNDİRİM",
    "time": "14:12:45",
    "review": "423 değerlendirme",
    "rating": "4.8",
    "price": "₺4.299",
    "oldPrice": "₺5.399",
    "savings": "₺1.100",
    "color": "Beyaz",
    "warranty": "1 Yıl Garanti",
  },
  {
    "id": "mega_3",
    "name": "Samsung Galaxy S24 Ultra",
    "img": "https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=800",
    "discount": "%22 İNDİRİM",
    "time": "08:30:22",
    "review": "1,247 değerlendirme",
    "rating": "4.9",
    "price": "₺39.999",
    "oldPrice": "₺51.999",
    "savings": "₺12.000",
    "color": "Siyah",
    "warranty": "2 Yıl Garanti",
  },
  {
    "id": "mega_4",
    "name": "MacBook Pro M3 14\"",
    "img": "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800",
    "discount": "%18 İNDİRİM",
    "time": "16:45:33",
    "review": "892 değerlendirme",
    "rating": "4.7",
    "price": "₺89.999",
    "oldPrice": "₺109.999",
    "savings": "₺20.000",
    "color": "Uzay Grisi",
    "warranty": "2 Yıl Garanti",
  },
  {
    "id": "mega_5",
    "name": "Apple Watch Series 9",
    "img": "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800",
    "discount": "%25 İNDİRİM",
    "time": "12:20:15",
    "review": "567 değerlendirme",
    "rating": "4.6",
    "price": "₺8.999",
    "oldPrice": "₺11.999",
    "savings": "₺3.000",
    "color": "Midnight",
    "warranty": "1 Yıl Garanti",
  },
];

class DiscountCarousel extends StatefulWidget {
  const DiscountCarousel({super.key});

  @override
  State<DiscountCarousel> createState() => _DiscountCarouselState();
}

class _DiscountCarouselState extends State<DiscountCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        int nextPage = _currentPage + 1;
        if (nextPage >= megaDiscounts.length) nextPage = 0;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Column(
        children: [
          // Üst Başlık
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFDF6F7),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF0E5E7), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.pink[100],
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Colors.pink,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Mega İndirimler",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "%70'e varan indirimler",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9D9D9D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B81),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B81).withAlpha(77),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      "CANLI",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Karusel
          SizedBox(
            height: 360,
            child: PageView.builder(
              controller: _pageController,
              itemCount: megaDiscounts.length,
              onPageChanged: (idx) => setState(() => _currentPage = idx),
              itemBuilder: (context, idx) {
                final item = megaDiscounts[idx];

                // --- Burası önemli: ProductDetailPage için key dönüştürmesi! ---
                final detailMap = {
                  "id": item["id"],
                  "isim": item["name"], // Detay sayfası için
                  "img": item["img"],
                  "fiyat": item["price"],
                  "eskiFiyat": item["oldPrice"],
                  "indirim": item["discount"],
                  "puan": item["rating"],
                  "deger": (item["review"] ?? "")
                      .toString()
                      .split(" ")
                      .first, // "847" gibi
                  "etiketler": ["Mega İndirim"],
                  "renk": item["color"],
                  "garanti": item["warranty"],
                };

                return _MegaDiscountCard(item: item, detailMap: detailMap);
              },
            ),
          ),
          const SizedBox(height: 16),
          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(megaDiscounts.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == i
                      ? const Color(0xFFFF6B81)
                      : const Color(0xFFF9DADA),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _MegaDiscountCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Map<String, dynamic> detailMap; // DÜZGÜN KEYLERLE VERİ

  const _MegaDiscountCard({required this.item, required this.detailMap});

  Widget _darkBadge(IconData icon, String txt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            txt,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartService>(
      builder: (context, cartService, child) {
        return GestureDetector(
          onTap: () {
            // --- Kart tıklandığında detay sayfasına git (null hatası engellenir) ---
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(product: detailMap),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
            ),
            child: Column(
              children: [
                // Üst: Görsel ve etiketler
                Stack(
                  children: [
                    // Ürün görseli
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: Image.network(
                        item["img"],
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 160,
                            color: const Color(0xFFF5F5F5),
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    // İndirim etiketi
                    Positioned(
                      left: 16,
                      top: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B81),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item["discount"] ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    // Favori (kalp)
                    Positioned(
                      right: 16,
                      top: 16,
                      child: Consumer<FavoriteService>(
                        builder: (context, favoriteService, child) {
                          final isFav = favoriteService.favorites.any(
                            (fav) => fav.id == item['id'],
                          );
                          return GestureDetector(
                            onTap: () {
                              if (isFav) {
                                favoriteService.removeFavorite(item['id']);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${item["name"]} favorilerden çıkarıldı',
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              } else {
                                favoriteService.addFavorite(item);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${item["name"]} favorilere eklendi!',
                                    ),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav
                                    ? Colors.red
                                    : const Color(0xFFED145B),
                                size: 22,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Alt solda süre
                    Positioned(
                      left: 16,
                      bottom: 12,
                      child: _darkBadge(Icons.timer, item["time"] ?? ""),
                    ),
                    // Alt sağda değerlendirme
                    Positioned(
                      right: 16,
                      bottom: 12,
                      child: _darkBadge(
                        Icons.people_alt_outlined,
                        item["review"] ?? "",
                      ),
                    ),
                  ],
                ),
                // Alt kart detayları
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["name"] ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFFFB800),
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "(${item["rating"] ?? ""})",
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              item["price"] ?? "",
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item["oldPrice"] ?? "",
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  "Tasarruf",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  item["savings"] ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              cartService.addToCart(detailMap, 1);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${item["name"]} sepete eklendi!',
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B3D),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              shadowColor: const Color(
                                0xFFFF6B3D,
                              ).withOpacity(0.2),
                            ),
                            icon: const Icon(
                              Icons.shopping_basket,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: const Text(
                              "Hemen Sepete Ekle",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
