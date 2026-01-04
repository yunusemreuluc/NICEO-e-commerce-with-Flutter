import 'package:flutter/material.dart';
import 'package:niceo/pages/category_products_page.dart';

final List<Map<String, dynamic>> categories = [
  {
    "name": "Telefon",
    "icon": Icons.smartphone,
    "color": const Color(0xFF2563EB),
    "count": 1247,
  },
  {
    "name": "Bilgisayar",
    "icon": Icons.laptop_mac,
    "color": const Color(0xFF9333EA),
    "count": 856,
  },
  {
    "name": "Kulaklık",
    "icon": Icons.headphones,
    "color": const Color(0xFF10B981),
    "count": 634,
  },
  {
    "name": "Akıllı Saat",
    "icon": Icons.watch,
    "color": const Color(0xFFF97316),
    "count": 423,
  },
  {
    "name": "Kamera",
    "icon": Icons.camera_alt,
    "color": const Color(0xFFEC4899),
    "count": 298,
  },
  {
    "name": "Oyun",
    "icon": Icons.sports_esports,
    "color": const Color(0xFF8B5CF6),
    "count": 567,
  },
];

class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 0, right: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              "Kategoriler",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20, bottom: 16),
            child: Text(
              "Aradığın kategoriye göz at",
              style: TextStyle(fontSize: 15, color: Color(0xFF6C757D)),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: categories
                  .map((cat) => _categoryCard(context, cat))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryCard(BuildContext context, Map<String, dynamic> cat) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryProductsPage(
              categoryName: cat['name'] as String,
              categoryIcon: cat['icon'] as IconData,
              categoryColor: cat['color'] as Color,
            ),
          ),
        );
      },
      child: Container(
        width: 110,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE9ECEF), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: (cat['color'] as Color).withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (cat['color'] as Color).withOpacity(0.20),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                cat['icon'] as IconData,
                color: cat['color'] as Color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              cat['name'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${cat['count']} ürün",
              style: const TextStyle(fontSize: 12, color: Color(0xFF6C757D)),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
