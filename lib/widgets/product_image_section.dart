import 'package:flutter/material.dart';

class ProductImageSection extends StatelessWidget {
  final List<String> images;
  final int selectedIndex;
  final Function(int) onImageSelected;
  final List<String> tags; // ["YENİ", "%9 İNDİRİM"]
  final String? discount;

  const ProductImageSection({
    super.key,
    required this.images,
    required this.selectedIndex,
    required this.onImageSelected,
    required this.tags,
    this.discount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                images[selectedIndex],
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // Etiketler
            Positioned(
              left: 10,
              top: 10,
              child: Row(
                children: tags
                    .map(
                      (tag) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: tag.contains('YENİ')
                              ? Color(0xFF10B981)
                              : Color(0xFFFF2D55),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            // Sağ altta foto sayacı
            Positioned(
              right: 10,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.54),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  "${selectedIndex + 1}/${images.length}",
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            images.length,
            (idx) => GestureDetector(
              onTap: () => onImageSelected(idx),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedIndex == idx
                        ? Colors.deepPurple
                        : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.network(
                    images[idx],
                    height: 44,
                    width: 44,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
