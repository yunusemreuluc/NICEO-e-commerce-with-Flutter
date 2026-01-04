import 'package:flutter/material.dart';
import 'product_detail_page.dart';

class CategoryProductsPage extends StatefulWidget {
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;

  const CategoryProductsPage({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
  });

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  /// DEMO veri – gerçek projede servisten besleyin
  final List<Map<String, dynamic>> _allProducts = [
    {
      "id": 1,
      "isim": "iPhone 15 Pro Max 256GB",
      "img":
          "https://images.unsplash.com/photo-1678685888221-cda773a3dc2a?w=1200",
      "kategori": "Telefon",
      "marka": "Apple",
      "fiyat": "₺54.999",
      "eskiFiyat": "₺59.999",
      "indirim": "%8",
      "puan": "4.8",
      "deger": "245",
      "etiketler": ["Apple", "Telefon"],
      "yeniMi": false,
      "begeni": 921,
      "populer": 98,
      "tarih": DateTime(2024, 12, 20),
    },
    {
      "id": 2,
      "isim": "Samsung Galaxy S24 Ultra",
      "img":
          "https://images.unsplash.com/photo-1607863680052-f1945c9a83dd?w=1200",
      "kategori": "Telefon",
      "marka": "Samsung",
      "fiyat": "₺49.999",
      "eskiFiyat": "₺54.999",
      "indirim": "%9",
      "puan": "4.9",
      "deger": "189",
      "etiketler": ["Samsung", "Telefon"],
      "yeniMi": true,
      "begeni": 840,
      "populer": 96,
      "tarih": DateTime(2025, 02, 12),
    },
    {
      "id": 3,
      "isim": "MacBook Pro M3",
      "img":
          "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=1200",
      "kategori": "Bilgisayar",
      "marka": "Apple",
      "fiyat": "₺89.999",
      "eskiFiyat": "₺99.999",
      "indirim": "%10",
      "puan": "4.7",
      "deger": "423",
      "etiketler": ["Apple", "Bilgisayar"],
      "yeniMi": false,
      "begeni": 610,
      "populer": 90,
      "tarih": DateTime(2024, 10, 1),
    },
    {
      "id": 4,
      "isim": "Sony WH-1000XM5",
      "img":
          "https://images.unsplash.com/photo-1510070009289-b5bc34383727?w=1200",
      "kategori": "Kulaklık",
      "marka": "Sony",
      "fiyat": "₺12.499",
      "eskiFiyat": "₺14.999",
      "indirim": "%17",
      "puan": "4.8",
      "deger": "312",
      "etiketler": ["Sony", "Kulaklık"],
      "yeniMi": false,
      "begeni": 740,
      "populer": 94,
      "tarih": DateTime(2024, 11, 5),
    },
    {
      "id": 5,
      "isim": "Logitech G Pro X",
      "img":
          "https://images.unsplash.com/photo-1517816428104-797678c7cf0d?w=1200",
      "kategori": "Oyun",
      "marka": "Logitech",
      "fiyat": "₺3.499",
      "eskiFiyat": "₺4.199",
      "indirim": "%17",
      "puan": "4.6",
      "deger": "98",
      "etiketler": ["Logitech", "Oyun"],
      "yeniMi": true,
      "begeni": 290,
      "populer": 80,
      "tarih": DateTime(2025, 01, 8),
    },
    {
      "id": 6,
      "isim": "Apple Watch Series 9",
      "img":
          "https://images.unsplash.com/photo-1518442546067-8d48f9ea8b83?w=1200",
      "kategori": "Akıllı Saat",
      "marka": "Apple",
      "fiyat": "₺19.999",
      "eskiFiyat": "₺22.999",
      "indirim": "%13",
      "puan": "4.7",
      "deger": "210",
      "etiketler": ["Apple", "Akıllı Saat"],
      "yeniMi": true,
      "begeni": 520,
      "populer": 92,
      "tarih": DateTime(2025, 03, 3),
    },
  ];

  String _search = "";
  String _sort = "popular"; // popular | priceAsc | priceDesc | newest | liked
  bool _isGrid = true;
  Set<String> _brandFilter = {};

  @override
  Widget build(BuildContext context) {
    final products = _filteredSortedProducts();
    final brandsInCategory =
        _allProducts
            .where((p) => (p["kategori"] ?? "") == widget.categoryName)
            .map((p) => (p["marka"] ?? "").toString())
            .where((b) => b.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.categoryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(widget.categoryIcon, color: widget.categoryColor),
            ),
            Text(
              widget.categoryName,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "${products.length} ürün",
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Filtrele",
            icon: const Icon(Icons.tune_rounded, color: Colors.black87),
            onPressed: () => _openFilter(brandsInCategory),
          ),
          IconButton(
            tooltip: _isGrid ? "Liste görünümü" : "Grid görünümü",
            icon: Icon(
              _isGrid ? Icons.grid_view_rounded : Icons.view_list_rounded,
              color: Colors.black87,
            ),
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Arama
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: TextField(
              onChanged: (v) => setState(() => _search = v.trim()),
              decoration: InputDecoration(
                hintText: "${widget.categoryName} içinde ara...",
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                filled: true,
                fillColor: const Color(0xFFF3F5F7),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),

          // Sıralama menüsü + aktif filtre etiketi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _SortDropdown(
                  value: _sort,
                  onChanged: (v) => setState(() => _sort = v),
                ),
                const Spacer(),
                if (_brandFilter.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_alt, size: 16),
                        const SizedBox(width: 6),
                        Text(_brandFilter.join(", ")),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => setState(() => _brandFilter.clear()),
                          child: const Icon(Icons.close, size: 16),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Liste / Grid
          Expanded(
            child: products.isEmpty
                ? _emptyState()
                : _isGrid
                ? GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: .68,
                        ),
                    itemCount: products.length,
                    itemBuilder: (_, i) => _ProductCard(
                      product: products[i],
                      onTap: () => _openDetail(products[i]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: products.length,
                    itemBuilder: (_, i) => _ProductTile(
                      product: products[i],
                      onTap: () => _openDetail(products[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ---------- Helpers ----------

  List<Map<String, dynamic>> _filteredSortedProducts() {
    var list = _allProducts
        .where((p) => (p["kategori"] ?? "") == widget.categoryName)
        .where(
          (p) =>
              _search.isEmpty ||
              (p["isim"] ?? "").toString().toLowerCase().contains(
                _search.toLowerCase(),
              ),
        )
        .where((p) => _brandFilter.isEmpty || _brandFilter.contains(p["marka"]))
        .toList();

    int parsePrice(dynamic v) {
      final s = (v ?? "0").toString().replaceAll("₺", "").replaceAll(".", "");
      final d = double.tryParse(s.replaceAll(",", ".")) ?? 0;
      return (d * 100).round();
    }

    DateTime asDate(dynamic v) =>
        (v is DateTime) ? v : DateTime.fromMillisecondsSinceEpoch(0);

    switch (_sort) {
      case "priceAsc":
        list.sort(
          (a, b) => parsePrice(a["fiyat"]).compareTo(parsePrice(b["fiyat"])),
        );
        break;
      case "priceDesc":
        list.sort(
          (a, b) => parsePrice(b["fiyat"]).compareTo(parsePrice(a["fiyat"])),
        );
        break;
      case "newest":
        list.sort((a, b) => asDate(b["tarih"]).compareTo(asDate(a["tarih"])));
        break;
      case "liked":
        list.sort((a, b) => (b["begeni"] ?? 0).compareTo(a["begeni"] ?? 0));
        break;
      default: // popular
        list.sort((a, b) => (b["populer"] ?? 0).compareTo(a["populer"] ?? 0));
    }
    return list;
  }

  void _openFilter(List<String> brands) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final tmp = {..._brandFilter};
        return StatefulBuilder(
          builder: (ctx, setModal) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "Filtrele",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Marka",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: -4,
                  children: brands
                      .map(
                        (b) => FilterChip(
                          label: Text(b),
                          selected: tmp.contains(b),
                          onSelected: (sel) =>
                              setModal(() => sel ? tmp.add(b) : tmp.remove(b)),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      setState(() => _brandFilter = tmp);
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      "Uygula",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openDetail(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Colors.black45,
            ),
            const SizedBox(height: 10),
            Text(
              "Bu kategori için sonuç bulunamadı",
              style: TextStyle(
                color: Colors.black.withOpacity(.75),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text("Filtreleri daralttıysan genişletmeyi deneyebilirsin."),
          ],
        ),
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _SortDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.expand_more),
          items: const [
            DropdownMenuItem(value: "popular", child: Text("En Popüler")),
            DropdownMenuItem(value: "priceAsc", child: Text("Fiyat (Düşük)")),
            DropdownMenuItem(value: "priceDesc", child: Text("Fiyat (Yüksek)")),
            DropdownMenuItem(value: "newest", child: Text("En Yeni")),
            DropdownMenuItem(value: "liked", child: Text("En Çok Beğenilen")),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

/// ----------- Kart Bileşenleri -----------

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;
  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final String img = (product["img"] ?? "").toString();
    final String ind = (product["indirim"] ?? "").toString();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFF1F1F4)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
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
                  child: img.isEmpty
                      ? Container(
                          height: 120,
                          color: const Color(0xFFE5E7EB),
                          child: const Center(child: Icon(Icons.image)),
                        )
                      : Image.network(
                          img,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          cacheWidth: 600,
                          errorBuilder: (_, __, ___) => Container(
                            height: 120,
                            color: const Color(0xFFE5E7EB),
                            child: const Center(
                              child: Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                ),
                if (ind.isNotEmpty)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2D55),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ind,
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
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Text(
                (product["isim"] ?? "").toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFFFFB800), size: 16),
                  const SizedBox(width: 3),
                  Text((product["puan"] ?? "0").toString()),
                  const SizedBox(width: 4),
                  Text(
                    "(${product["deger"] ?? 0})",
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
              child: Row(
                children: [
                  Text(
                    (product["fiyat"] ?? "").toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    (product["eskiFiyat"] ?? "").toString(),
                    style: const TextStyle(
                      color: Color(0xFFBCBCBC),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;
  const _ProductTile({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final String img = (product["img"] ?? "").toString();
    final String ind = (product["indirim"] ?? "").toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(14),
              ),
              child: img.isEmpty
                  ? Container(
                      width: 120,
                      height: 100,
                      color: const Color(0xFFE5E7EB),
                      child: const Center(child: Icon(Icons.image)),
                    )
                  : Image.network(
                      img,
                      width: 120,
                      height: 100,
                      fit: BoxFit.cover,
                      cacheWidth: 500,
                      errorBuilder: (_, __, ___) => Container(
                        width: 120,
                        height: 100,
                        color: const Color(0xFFE5E7EB),
                        child: const Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (product["isim"] ?? "").toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFB800),
                          size: 16,
                        ),
                        const SizedBox(width: 3),
                        Text((product["puan"] ?? "0").toString()),
                        const SizedBox(width: 4),
                        Text(
                          "(${product["deger"] ?? 0})",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const Spacer(),
                        if (ind.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF2D55),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              ind,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          (product["fiyat"] ?? "").toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          (product["eskiFiyat"] ?? "").toString(),
                          style: const TextStyle(
                            color: Color(0xFFBCBCBC),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
