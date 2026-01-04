import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:niceo/pages/product_detail_page.dart';
import '../services/cart_service.dart';
import '../services/favorite_service.dart';

final List<Map<String, dynamic>> featured = [
  {
    "id": "ftr_1",
    "etiket": "YENİ",
    "etiketRenk": Color(0xFF10B981),
    "indirim": "%9",
    "indirimRenk": Color(0xFFFF2D55),
    "img": "https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=400",
    "favori": false,
    "isim": "Samsung Galaxy S24 Ultra",
    "etiketler": ["Samsung", "Telefon"],
    "puan": 4.8,
    "deger": 189,
    "fiyat": "₺49.999",
    "eskiFiyat": "₺54.999",
  },
  {
    "id": "ftr_2",
    "etiket": "%25",
    "etiketRenk": Color(0xFFFF2D55),
    "indirim": "",
    "indirimRenk": Colors.transparent,
    "img": "https://images.unsplash.com/photo-1510070009289-b5bc34383727?w=400",
    "favori": false,
    "isim": "Sony WH-1000XM5",
    "etiketler": ["Sony", "Kulaklık"],
    "puan": 4.7,
    "deger": 203,
    "fiyat": "₺2.999",
    "eskiFiyat": "₺3.999",
  },
  {
    "id": "ftr_3",
    "etiket": "ÇOK SATAN",
    "etiketRenk": Color(0xFFFFB800),
    "indirim": "%17",
    "indirimRenk": Color(0xFFFF2D55),
    "img": "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400",
    "favori": true,
    "isim": "Apple Watch Series 8",
    "etiketler": ["Apple", "Saat"],
    "puan": 4.9,
    "deger": 127,
    "fiyat": "₺9.499",
    "eskiFiyat": "₺11.499",
  },
  {
    "id": "ftr_4",
    "etiket": "%30",
    "etiketRenk": Color(0xFFFF2D55),
    "indirim": "",
    "indirimRenk": Colors.transparent,
    "img": "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400",
    "favori": false,
    "isim": "JBL Tune 750BTNC",
    "etiketler": ["JBL", "Kulaklık"],
    "puan": 4.6,
    "deger": 91,
    "fiyat": "₺1.799",
    "eskiFiyat": "₺2.599",
  },
  {
    "id": "ftr_5",
    "etiket": "YENİ",
    "etiketRenk": Color(0xFF10B981),
    "indirim": "%5",
    "indirimRenk": Color(0xFFFF2D55),
    "img": "https://images.unsplash.com/photo-1454023492550-5696f8ff10e1?w=400",
    "favori": false,
    "isim": "Nintendo Switch OLED",
    "etiketler": ["Nintendo", "Konsol"],
    "puan": 4.8,
    "deger": 53,
    "fiyat": "₺12.499",
    "eskiFiyat": "₺13.199",
  },
];

class FeaturedProducts extends StatelessWidget {
  const FeaturedProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 35, left: 20, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    0,
                    0,
                    0,
                    0,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flash_on,
                  color: Color.fromARGB(255, 0, 0, 0),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Öne Çıkan Ürünler",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 9, 8, 8),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 44, top: 4),
            child: Text(
              "En popüler ve beğenilen ürünler",
              style: TextStyle(fontSize: 14, color: Color(0xFF6C757D)),
            ),
          ),
          const SizedBox(height: 0),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: featured.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, i) => GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductDetailPage(product: featured[i]),
                  ),
                );
              },
              child: _ProductCard(item: featured[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _ProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F3F4), width: 1),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ÜST: Ürün görseli ve rozetler
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.network(
                      item["img"],
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          color: const Color(0xFFF5F5F5),
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  // Sol üst etiket
                  if (item["etiket"] != null)
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: item["etiketRenk"],
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: (item["etiketRenk"] as Color).withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          item["etiket"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  // Sol alt indirim
                  if (item["indirim"] != null && item["indirim"] != "")
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: item["indirimRenk"],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item["indirim"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  // Sağ üst favori
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Consumer<FavoriteService>(
                      builder: (context, favoriteService, child) {
                        final isFav = favoriteService.favorites.any(
                          (fav) => fav.id == item["id"],
                        );
                        return GestureDetector(
                          onTap: () {
                            if (isFav) {
                              favoriteService.removeFavorite(item["id"]);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${item["name"] ?? item["isim"]} favorilerden çıkarıldı.',
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
                                    '${item["name"] ?? item["isim"]} favorilere eklendi!',
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.grey[400],
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              // Orta: Marka/kategori etiketleri
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: List.generate(item["etiketler"].length, (j) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFE9ECEF),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        item["etiketler"][j],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF495057),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // Ürün ismi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  item["isim"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 1),
              // Yıldız ve değerlendirme
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFB800), size: 16),
                    const SizedBox(width: 2),
                    Text(
                      "(${item["puan"]})",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "(${item["deger"]})",
                      style: const TextStyle(
                        color: Color(0xFF6C757D),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Fiyatlar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Text(
                      item["fiyat"],
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item["eskiFiyat"],
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Color(0xFFADB5BD),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 0),
              // Sepete Ekle Butonu
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Consumer<CartService>(
                  builder: (context, cartService, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 28,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          cartService.addToCart(item, 1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item["isim"]} sepete eklendi!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                        label: const Text(
                          "Sepete Ekle",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                          shadowColor: Colors.black.withValues(alpha: 0.2),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
