import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/favorite_service.dart';
import '../models/favorite_item.dart';
import '../services/cart_service.dart';
import '../pages/product_detail_page.dart'; // Ürün detay sayfanı import et

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<FavoriteService>(
        builder: (context, favService, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            children: [
              // BAŞLIK + PAYLAŞ + ÜRÜN SAYISI
              SizedBox(height: 14),
              _FavoritesHeader(favCount: favService.favorites.length),
              SizedBox(height: 4),
              if (favService.favorites.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 36.0),
                  child: Center(
                    child: Text(
                      'Favoriler listeniz boş',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ),
                ),
              ...favService.favorites.map((item) => _FavoriteCard(item: item)),
              SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}

class _FavoritesHeader extends StatelessWidget {
  final int favCount;
  const _FavoritesHeader({required this.favCount});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Favorilerim",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 3),
              Text(
                "$favCount ürün",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.share, color: Colors.black87, size: 18),
          label: Text(
            "Paylaş",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.white,
            side: BorderSide(color: Color(0xFFEDEDED)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
            padding: EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          ),
        ),
      ],
    );
  }
}

// --- FAVORİ KARTI (tamamı tıklanabilir)
class _FavoriteCard extends StatelessWidget {
  final FavoriteItem item;
  const _FavoriteCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Detay sayfasına git
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              product: {
                'id': item.id,
                'isim': item.name,
                'img': item.image,
                'fiyat': item.price,
                'eskiFiyat': item.oldPrice,
                'renk': 'Belirtilmemiş',
                'garanti': '1 Yıl Garanti',
                'marka': item.brand,
                'etiket': item.tag,
                'puan': item.rating,
                'deger': item.reviewCount,
              },
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Görsel
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  item.image,
                  width: 65,
                  height: 65,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12),
              // Ürün Detay
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand ve Tag
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.brand,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.yellow[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.tag,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    // Name
                    Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3),
                    // Rating & Review
                    Row(
                      children: [
                        Icon(Icons.star, color: Color(0xFFFFB800), size: 16),
                        SizedBox(width: 3),
                        Text(
                          "${item.rating} ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          "(${item.reviewCount})",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    // Price
                    Row(
                      children: [
                        Text(
                          item.price,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(width: 7),
                        Text(
                          item.oldPrice,
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Color(0xFFBCBCBC),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Sepete Ekle ve Sil
              Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      Provider.of<FavoriteService>(
                        context,
                        listen: false,
                      ).removeFavorite(item.id);
                    },
                  ),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Provider.of<CartService>(
                          context,
                          listen: false,
                        ).addToCart({
                          'id': item.id,
                          'isim': item.name,
                          'img': item.image,
                          'fiyat': item.price,
                          'eskiFiyat': item.oldPrice,
                          'renk': 'Belirtilmemiş',
                          'garanti': '1 Yıl Garanti',
                        }, 1);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.name} sepete eklendi!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.shopping_cart_outlined,
                        size: 18,
                        color: Colors.white, // <-- ikon beyaz
                      ),
                      label: Text(
                        "Sepete Ekle",
                        style: TextStyle(fontSize: 13, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: Size(90, 35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
