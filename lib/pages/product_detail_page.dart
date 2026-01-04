import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import 'package:intl/intl.dart';
import '../widgets/bottom_nav_bar.dart';
import '../pages/main_layout.dart';
import '../services/favorite_service.dart';
import '../widgets/product_reviews_tab.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic>? product;
  final String? productId;
  final String? productName;
  final String? productImage;
  final int initialTabIndex;
  
  const ProductDetailPage({
    this.product,
    this.productId,
    this.productName,
    this.productImage,
    this.initialTabIndex = 0,
    super.key,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  int adet = 1;
  int aktifResim = 0;
  late TabController tabController;
  int selectedBottomIndex = 0;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 3, 
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🔄 ProductDetailPage build çağrıldı');
    print('📦 widget.product: ${widget.product}');
    print('📦 widget.productId: ${widget.productId}');
    print('📦 widget.productName: ${widget.productName}');
    print('📦 widget.initialTabIndex: ${widget.initialTabIndex}');
    
    // Product bilgilerini widget parametrelerinden veya product map'inden al
    final product = widget.product ?? {
      'id': widget.productId ?? '1',
      'name': widget.productName ?? 'Ürün',
      'img': widget.productImage ?? '',
      'price': 0,
      'description': 'Ürün açıklaması',
    };
    
    print('📦 Final product: $product');
    
    List<String> images = List.generate(3, (i) => product["img"] ?? "");

    return Scaffold(
      backgroundColor: Color(0xFFF8F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: Container(
          height: 38,
          decoration: BoxDecoration(
            color: Color(0xFFF3F5F7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Ürün, kategori ara...",
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              contentPadding: EdgeInsets.symmetric(vertical: 7),
            ),
            style: TextStyle(fontSize: 15),
          ),
        ),
        actions: [
          Consumer<FavoriteService>(
            builder: (context, favoriteService, child) {
              final isFav = favoriteService.favorites.any(
                (fav) => fav.id == product['id'],
              );
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.black54,
                ),
                onPressed: () {
                  if (isFav) {
                    favoriteService.removeFavorite(product['id']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${product["isim"] ?? product["name"]} favorilerden çıkarıldı.',
                        ),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    favoriteService.addFavorite(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${product["isim"] ?? product["name"]} favorilere eklendi!',
                        ),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.share, color: const Color.fromARGB(136, 0, 0, 0)),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          // Ürün ana görseli ve etiket
          Padding(
            padding: const EdgeInsets.only(
              top: 14,
              left: 14,
              right: 14,
              bottom: 5,
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    images[aktifResim],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                if ((product["indirim"] ?? "").toString().isNotEmpty)
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF2D55),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        "${product["indirim"]} İNDİRİM",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  right: 13,
                  bottom: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.57),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${aktifResim + 1}/${images.length}",
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Alt görsel seçiciler
          Padding(
            padding: const EdgeInsets.only(
              left: 13,
              right: 13,
              top: 5,
              bottom: 2,
            ),
            child: Row(
              children: List.generate(
                images.length,
                (i) => GestureDetector(
                  onTap: () => setState(() => aktifResim = i),
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: aktifResim == i
                            ? Colors.deepPurple
                            : Colors.transparent,
                        width: 2.2,
                      ),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.network(
                        images[i],
                        width: 46,
                        height: 46,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 20,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Marka / Kategori etiketleri
          Padding(
            padding: const EdgeInsets.only(
              left: 15,
              top: 6,
              bottom: 0,
              right: 10,
            ),
            child: Wrap(
              spacing: 7,
              runSpacing: 4,
              children: [
                ...(product["etiketler"] is List
                        ? product["etiketler"]
                        : <dynamic>[])
                    .map<Widget>(
                      (e) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFF1F1F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          e.toString(),
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
          // Ürün Adı
          Padding(
            padding: const EdgeInsets.only(
              left: 15,
              top: 7,
              right: 10,
              bottom: 2,
            ),
            child: Text(
              product["isim"]?.toString() ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
          ),
          // Puan, değerlendirme
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 10, bottom: 2),
            child: Row(
              children: [
                Icon(Icons.star, color: Color(0xFFFFB800), size: 19),
                SizedBox(width: 4),
                Text(
                  (product["puan"] ?? "0").toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(width: 4),
                Text(
                  "(${product["deger"] ?? "0"} değerlendirme)",
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          // Fiyat, eski fiyat, tasarruf
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 6, right: 10),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        product["fiyat"]?.toString() ?? "",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        product["eskiFiyat"]?.toString() ?? "",
                        style: TextStyle(
                          color: Color(0xFFBCBCBC),
                          fontSize: 16,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(width: 13),
                      Text(
                        "₺${_calculateTasarruf(product)} tasarruf",
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Avantaj kutuları
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _miniInfoBox(
                  Icons.local_shipping,
                  "Ücretsiz Kargo",
                  Colors.green[100]!,
                ),
                _miniInfoBox(Icons.autorenew, "30 Gün İade", Colors.blue[100]!),
                _miniInfoBox(
                  Icons.verified,
                  "2 Yıl Garanti",
                  Colors.purple[100]!,
                ),
              ],
            ),
          ),
          // Adet ve Sepete Ekle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: Row(
              children: [
                Text(
                  "Adet:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(width: 10),
                _adetCounter(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 5),
            child: Consumer<CartService>(
              builder: (context, cartService, child) {
                return ElevatedButton.icon(
                  onPressed: () {
                    cartService.addToCart(
                      product,
                      adet,
                    ); // Ürünü ve adedi gönder
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product["isim"]} sepete eklendi!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.shopping_cart_outlined, color: Colors.white),
                  label: Text(
                    "Sepete Ekle - ${_totalFiyat(product["fiyat"])}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                );
              },
            ),
          ),

          // TabBar (Açıklama, Yorumlar, Özellikler)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TabBar(
                controller: tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                indicatorPadding: EdgeInsets.symmetric(
                  horizontal: -20,
                  vertical: 4,
                ),
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(
                    child: Text(
                      "Açıklama",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Özellikler",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Yorumlar",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: tabController,
              children: [
                _aciklamaTab(),
                _ozelliklerTab(),
                ProductReviewsTab(
                  productId: (product['id'] ?? widget.productId ?? '1').toString(),
                  productName: product['name'] ?? product['isim'] ?? widget.productName ?? 'Ürün',
                  productImage: product['img'] ?? widget.productImage,
                  productPayload: product,
                ),
              ],
            ),
          ),

          // Benzer Ürünler
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 18, 8, 7),
            child: Text(
              "Benzer Ürünler",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          SizedBox(
            height: 180,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _benzerUrunCard(
                  "AirPods Pro 3rd Gen",
                  "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400",
                  "₺3.999",
                  "₺4.999",
                  "%20",
                  156,
                ),
                _benzerUrunCard(
                  "Sony WH-1000XM6",
                  "https://images.unsplash.com/photo-1510070009289-b5bc34383727?w=400",
                  "₺3.499",
                  "₺4.299",
                  "%19",
                  89,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
        onTabSelected: (index) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => MainLayout(initialIndex: index)),
            (route) => false,
          );
        },
      ),
    );
  }

  Widget _miniInfoBox(IconData icon, String label, Color color) {
    return Container(
      width: 100, // Sabit genişlik ver
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.black54, size: 21),
          SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _adetCounter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12, width: 1),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.remove, size: 21),
            onPressed: () {
              if (adet > 1) setState(() => adet--);
            },
          ),
          Text(
            '$adet',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(Icons.add, size: 21),
            onPressed: () => setState(() => adet++),
          ),
        ],
      ),
    );
  }

  String _totalFiyat(String fiyatText) {
    String temiz = fiyatText
        .replaceAll('₺', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    double fiyat = double.tryParse(temiz) ?? 0;
    double toplam = fiyat * adet;

    // Türkçe format için:
    final format = NumberFormat("#,##0", "tr_TR");
    return "₺${format.format(toplam)}";
  }

  String _calculateTasarruf(Map<String, dynamic> p) {
    String eskiTemiz = (p["eskiFiyat"] ?? "")
        .toString()
        .replaceAll('₺', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    String yeniTemiz = (p["fiyat"] ?? "")
        .toString()
        .replaceAll('₺', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    double eskiFiyat = double.tryParse(eskiTemiz) ?? 0;
    double fiyat = double.tryParse(yeniTemiz) ?? 0;
    final format = NumberFormat("#,##0", "tr_TR");
    return format.format(eskiFiyat - fiyat);
  }

  // TABLAR
  Widget _aciklamaTab() => Container(
    margin: const EdgeInsets.only(top: 8),
    padding: const EdgeInsets.all(13.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.grey.shade300),
      color: Colors.white,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Ürün Açıklaması",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          "AirPods Pro 3rd Gen, yüksek kaliteli malzemeler ve son teknoloji ile üretilmiştir. Günlük kullanımınızda size en iyi deneyimi sunmak için tasarlanmıştır.",
          style: TextStyle(fontSize: 15, color: Colors.black87),
        ),
        SizedBox(height: 18),
        Text(
          "Öne Çıkan Özellikler:",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        SizedBox(height: 8),
      ],
    ),
  );

  // İstersen özellik maddelerini alt alta Text olarak eklemeye devam edebilirsin

  Widget _ozelliklerTab() => Container(
    margin: const EdgeInsets.only(top: 8),
    padding: const EdgeInsets.all(13.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.grey.shade300),
      color: Colors.white,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Teknik Özellikler",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 9),
        _ozellikSatir("Bağlantı", "Bluetooth 5.3"),
        _ozellikSatir("Gürültü Engelleme", "Aktif"),
        _ozellikSatir("Batarya Süresi", "6 Saat"),
        _ozellikSatir("Şarj Kutusu", "Var"),
        _ozellikSatir("Suya Dayanıklılık", "IPX4"),
      ],
    ),
  );

  Widget _ozellikSatir(String ozellik, String deger) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              ozellik,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              deger,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _benzerUrunCard(
    String isim,
    String img,
    String fiyat,
    String eskiFiyat,
    String indirim,
    int yorum,
  ) {
    return Container(
      width: 155,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F1F4), width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: Image.network(
                  img,
                  height: 75,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 75,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 30,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                left: 7,
                top: 7,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF2D55),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    indirim,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 7, top: 5),
            child: Text(
              isim,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 7, top: 2, bottom: 2),
            child: Row(
              children: const [
                Icon(Icons.star, color: Color(0xFFFFB800), size: 15),
                SizedBox(width: 3),
                Text("(0)", style: TextStyle(fontSize: 13)), // örnek
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 7, top: 1, bottom: 3),
            child: Row(
              children: [
                Text(
                  fiyat,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  eskiFiyat,
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Color(0xFFBCBCBC),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
