import 'package:flutter/material.dart';
import 'product_detail_page.dart';

class YoYoPage extends StatefulWidget {
  const YoYoPage({super.key});

  @override
  State<YoYoPage> createState() => _YoYoPageState();
}

class _YoYoPageState extends State<YoYoPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  bool _busy = false; // re-entrancy kilidi

  final List<_ChatItem> _messages = [];

  // Hafif demo katalog (gerekirse kendi data kaynağınızla değiştirin)
  final List<Map<String, dynamic>> _catalog = [
    {
      "id": 1001,
      "isim": "iPhone 15 Pro Max 256GB",
      "img":
          "https://images.unsplash.com/photo-1678685888221-cda773a3dc2a?auto=format&fit=crop&w=800&q=60",
      "kategori": "Telefon",
      "marka": "Apple",
      "fiyat": "₺54.999",
      "eskiFiyat": "₺59.999",
      "indirim": "%8",
      "puan": "4.8",
      "deger": "245",
      "etiketler": ["Apple", "Telefon"],
    },
    {
      "id": 1002,
      "isim": "Samsung Galaxy S24 Ultra",
      "img":
          "https://images.unsplash.com/photo-1607863680052-f1945c9a83dd?auto=format&fit=crop&w=800&q=60",
      "kategori": "Telefon",
      "marka": "Samsung",
      "fiyat": "₺49.999",
      "eskiFiyat": "₺54.999",
      "indirim": "%9",
      "puan": "4.9",
      "deger": "189",
      "etiketler": ["Samsung", "Telefon"],
    },
    {
      "id": 1003,
      "isim": "Sony WH-1000XM5",
      "img":
          "https://images.unsplash.com/photo-1510070009289-b5bc34383727?auto=format&fit=crop&w=800&q=60",
      "kategori": "Kulaklık",
      "marka": "Sony",
      "fiyat": "₺12.499",
      "eskiFiyat": "₺14.999",
      "indirim": "%17",
      "puan": "4.8",
      "deger": "312",
      "etiketler": ["Sony", "Kulaklık"],
    },
    {
      "id": 1004,
      "isim": "MacBook Pro M3",
      "img":
          "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=800&q=60",
      "kategori": "Bilgisayar",
      "marka": "Apple",
      "fiyat": "₺89.999",
      "eskiFiyat": "₺99.999",
      "indirim": "%10",
      "puan": "4.7",
      "deger": "423",
      "etiketler": ["Apple", "Bilgisayar"],
    },
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      _ChatItem.bot("Merhaba! Ben YoYo, alışveriş asistanın. Ne arıyorsun? ✨"),
    );
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    if (_busy) return; // ikinci tıklamayı yut
    final text = _input.text.trim();
    if (text.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _messages.add(_ChatItem.user(text));
      _input.clear();
    });
    _scrollToBottom();

    _busy = true;
    try {
      // UI’ı bloklamamak için microtask + basit arama
      final results = await Future<List<Map<String, dynamic>>>.microtask(() {
        final q = text.toLowerCase();
        return _catalog.where((p) {
          final name = (p["isim"] ?? "").toString().toLowerCase();
          final brand = (p["marka"] ?? "").toString().toLowerCase();
          final cat = (p["kategori"] ?? "").toString().toLowerCase();
          return name.contains(q) || brand.contains(q) || cat.contains(q);
        }).toList();
      });

      if (!mounted) return;

      if (results.isEmpty) {
        setState(() {
          _messages.add(
            _ChatItem.bot(
              "Aradığın ürünü bulamadım. Bunlar benzer olabilir 👇",
              products: _catalog.take(3).toList(),
            ),
          );
        });
      } else {
        setState(() {
          _messages.add(
            _ChatItem.bot(
              "Buldum! İşte uygun seçenekler 👇",
              products: results.take(6).toList(),
            ),
          );
        });
      }
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatItem.bot("Üzgünüm, bir hata oluştu. Lütfen tekrar dener misin?"),
        );
      });
      _scrollToBottom();
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Column(
        children: [
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                return Align(
                  alignment: m.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * .82,
                    ),
                    decoration: BoxDecoration(
                      color: m.isUser ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: m.isUser
                            ? Colors.black
                            : const Color(0xFFE5E7EB),
                      ),
                      boxShadow: m.isUser
                          ? []
                          : [
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
                        Text(
                          m.text,
                          style: TextStyle(
                            color: m.isUser ? Colors.white : Colors.black,
                            fontSize: 15,
                          ),
                        ),
                        if (m.products != null && m.products!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _ProductCarousel(
                            items: m.products!,
                            onTap: (p) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailPage(product: p),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Hızlı öneriler
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _quick("En uygun telefon öner"),
                _quick("Gaming kulaklık ara"),
                _quick("Apple dizüstü göster"),
              ],
            ),
          ),
          // Giriş
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: "YoYo'ya ne istediğini söyle ✨",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: ElevatedButton(
                      onPressed: _send,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quick(String text) => InkWell(
    onTap: () {
      _input.text = text;
      _send();
    },
    borderRadius: BorderRadius.circular(24),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, size: 16, color: Colors.black87),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    ),
  );
}

class _ChatItem {
  final bool isUser;
  final String text;
  final List<Map<String, dynamic>>? products;
  _ChatItem.user(this.text) : isUser = true, products = null;
  _ChatItem.bot(this.text, {this.products}) : isUser = false;
}

class _ProductCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final ValueChanged<Map<String, dynamic>> onTap;
  const _ProductCarousel({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final p = items[i];
          final img = (p["img"] ?? "").toString();
          return InkWell(
            onTap: () => onTap(p),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: img.isEmpty
                        ? Container(
                            height: 90,
                            color: const Color(0xFFE5E7EB),
                            child: const Center(child: Icon(Icons.image)),
                          )
                        : Image.network(
                            img,
                            height: 90,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            cacheWidth: 360, // küçük decode
                            filterQuality: FilterQuality.low,
                            errorBuilder: (_, __, ___) => Container(
                              height: 90,
                              color: const Color(0xFFE5E7EB),
                              child: const Center(
                                child: Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Text(
                      (p["isim"] ?? "").toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Text(
                          (p["fiyat"] ?? "").toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          (p["eskiFiyat"] ?? "").toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
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
        },
      ),
    );
  }
}
