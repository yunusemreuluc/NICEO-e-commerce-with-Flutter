import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/review_service.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

// Ürün detayındaki "Yorumlar" sekmesi
class ProductReviewsTab extends StatefulWidget {
  final String productId;
  final String productName;
  final String? productImage;
  final Map<String, dynamic>? productPayload;

  const ProductReviewsTab({
    super.key,
    required this.productId,
    required this.productName,
    this.productImage,
    this.productPayload,
  });

  @override
  State<ProductReviewsTab> createState() => _ProductReviewsTabState();
}

class _ProductReviewsTabState extends State<ProductReviewsTab> {
  List<Review> _apiReviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      setState(() => _isLoading = true);
      
      // Product ID'den sayısal kısmı çıkar
      int numericProductId;
      try {
        numericProductId = int.parse(widget.productId);
      } catch (e) {
        final match = RegExp(r'\d+').firstMatch(widget.productId);
        if (match != null) {
          numericProductId = int.parse(match.group(0)!);
        } else {
          numericProductId = 1;
        }
      }

      print('🔄 API\'den yorumlar çekiliyor, product_id: $numericProductId');
      print('📦 Widget productId: ${widget.productId}');
      print('📦 Widget productName: ${widget.productName}');
      
      final result = await ApiService.getProductReviews(numericProductId);
      
      print('📊 API Response: $result');
      
      if (result['success']) {
        final reviewsData = result['data']['reviews'] as List;
        print('✅ API\'den ${reviewsData.length} yorum alındı');
        
        _apiReviews = reviewsData.map((reviewJson) {
          return Review(
            id: reviewJson['id'].toString(),
            productId: widget.productId,
            productName: widget.productName,
            productImage: widget.productImage,
            productPayload: widget.productPayload,
            userId: reviewJson['user_id']?.toString(),
            rating: reviewJson['rating'] ?? 5,
            title: '${reviewJson['name'] ?? 'Kullanıcı'} ${reviewJson['surname'] ?? ''}',
            body: reviewJson['comment'] ?? '',
            createdAt: DateTime.tryParse(reviewJson['created_at'] ?? '') ?? DateTime.now(),
          );
        }).toList();
      } else {
        print('❌ API hatası: ${result['error']}');
        _apiReviews = [];
      }
    } catch (e) {
      print('❌ Exception: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      _apiReviews = [];
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      print('🔄 ProductReviewsTab build çağrıldı');
      print('📦 productId: ${widget.productId}');
      print('📦 productName: ${widget.productName}');
      
      // Local reviews ile API reviews'ı birleştir
      final localReviews = context.watch<ReviewService>().reviewsForProduct(widget.productId);
      final allReviews = [..._apiReviews, ...localReviews];
      
      // Duplicate'ları kaldır (aynı ID'ye sahip olanları)
      final uniqueReviews = <String, Review>{};
      for (final review in allReviews) {
        uniqueReviews[review.id] = review;
      }
      final reviews = uniqueReviews.values.toList();
      
      // Tarihe göre sırala (en yeni önce)
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 22),
              const SizedBox(width: 6),
              Text(
                reviews.isEmpty ? '0.0' : _avg(reviews).toStringAsFixed(1),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              Text("(${reviews.length} değerlendirme)"),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _openWriteDialog(context),
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text("Değerlendirme Yaz"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : reviews.isEmpty
                    ? const Center(child: Text("İlk değerlendirmeyi sen yaz!"))
                    : RefreshIndicator(
                        onRefresh: _loadReviews,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 8),
                          itemCount: reviews.length,
                          itemBuilder: (_, i) => _ReviewTile(
                            review: reviews[i],
                            onReviewChanged: _loadReviews,
                          ),
                        ),
                      ),
          ),
        ],
      );
    } catch (e, stackTrace) {
      print('❌ ProductReviewsTab build hatası: $e');
      print('❌ Stack trace: $stackTrace');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Hata: $e'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReviews,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }
  }

  static double _avg(List<Review> list) =>
      list.map((e) => e.rating).fold<double>(0, (a, b) => a + b) /
      (list.isEmpty ? 1 : list.length);

  void _openWriteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _WriteReviewDialog(
        productId: widget.productId,
        productName: widget.productName,
        productImage: widget.productImage,
        productPayload: widget.productPayload,
        onReviewAdded: _loadReviews,
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;
  final VoidCallback? onReviewChanged;
  
  const _ReviewTile({
    required this.review,
    this.onReviewChanged,
  });

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final currentUser = authService.user;
    final isOwner = currentUser != null && 
                   review.userId != null && 
                   currentUser.id.toString() == review.userId;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık ve butonlar
            Row(
              children: [
                Expanded(
                  child: Text(
                    review.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                // Edit ve Delete butonları - sadece kendi yorumlarında göster
                if (isOwner)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Color(0xFF8B5CF6),
                          ),
                          onPressed: () => _editReview(context),
                          tooltip: 'Düzenle',
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: Colors.grey[300],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Color(0xFFDC2626),
                          ),
                          onPressed: () => _deleteReview(context),
                          tooltip: 'Sil',
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Yıldızlar
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 18,
                  color: const Color(0xFFFFB800),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Yorum metni
            Text(
              review.body,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 8),
            
            // Tarih
            Text(
              _formatDate(review.createdAt),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editReview(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _WriteReviewDialog(
        editing: review,
        onReviewAdded: onReviewChanged,
      ),
    );
  }

  void _deleteReview(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFDC2626),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Yorumu Sil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: const Text(
            'Bu yorumu silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'İptal',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _performDelete(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Sil',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDelete(BuildContext context) async {
    try {
      // API'den sil
      final result = await ApiService.deleteReview(review.id);
      
      if (!context.mounted) return;
      
      if (result['success']) {
        // Sadece listeyi yenile, local service'den silme
        // Çünkü _loadReviews() API'den güncel listeyi çekecek
        
        // Listeyi yenile
        onReviewChanged?.call();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Yorum silindi'),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text(result['error'] ?? 'Yorum silinemedi'),
              ],
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text('Hata: $e'),
              ],
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  static String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";
}

class _WriteReviewDialog extends StatefulWidget {
  final String? productId;
  final String? productName;
  final String? productImage;
  final Map<String, dynamic>? productPayload;
  final Review? editing;
  final VoidCallback? onReviewAdded;

  const _WriteReviewDialog({
    this.productId,
    this.productName,
    this.productImage,
    this.productPayload,
    this.editing,
    this.onReviewAdded,
  });

  @override
  State<_WriteReviewDialog> createState() => _WriteReviewDialogState();
}

class _WriteReviewDialogState extends State<_WriteReviewDialog> {
  int rating = 0;
  final commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.editing != null) {
      rating = widget.editing!.rating;
      commentCtrl.text = widget.editing!.body;
    }
  }

  @override
  void dispose() {
    commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final currentUser = authService.user;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // Başlık
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB800).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFB800),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.editing == null ? "Değerlendirme Yaz" : "Değerlendirmeyi Düzenle",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          widget.productName ?? 'Ürün',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Kullanıcı bilgisi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF8B5CF6),
                      child: Text(
                        currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${currentUser?.name ?? 'Kullanıcı'} ${currentUser?.surname ?? ''}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Değerlendirme yazıyor',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Yıldız puanlama
              const Text(
                'Puanınız',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () => setState(() => rating = i + 1),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: const Color(0xFFFFB800),
                          size: 32,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              
              if (rating > 0) ...[
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB800),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$rating/5 ${_getRatingText(rating)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 20),
              
              // Yorum alanı
              const Text(
                'Yorumunuz',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(
                  minHeight: 80,
                  maxHeight: 120,
                ),
                child: TextField(
                  controller: commentCtrl,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'Ürün hakkındaki deneyiminizi paylaşın...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Butonlar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        foregroundColor: const Color(0xFF374151),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'İptal',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Gönder',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
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
          ],
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1: return 'Çok Kötü';
      case 2: return 'Kötü';
      case 3: return 'Orta';
      case 4: return 'İyi';
      case 5: return 'Mükemmel';
      default: return '';
    }
  }

  Future<void> _submitReview() async {
    if (rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Lütfen puan verin'),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    
    if (commentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Lütfen yorum yazın'),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    try {
      final authService = context.read<AuthService>();
      final currentUser = authService.user;
      
      Map<String, dynamic> result;
      
      if (widget.editing != null) {
        // Güncelleme işlemi
        result = await ApiService.updateReview(
          reviewId: widget.editing!.id,
          rating: rating,
          comment: commentCtrl.text.trim(),
        );
      } else {
        // Yeni yorum ekleme işlemi
        // Product ID'den sayısal kısmı çıkar
        int numericProductId;
        try {
          numericProductId = int.parse(widget.productId!);
        } catch (e) {
          final match = RegExp(r'\d+').firstMatch(widget.productId!);
          if (match != null) {
            numericProductId = int.parse(match.group(0)!);
          } else {
            numericProductId = 1;
          }
        }
        
        result = await ApiService.addReview(
          productId: numericProductId,
          rating: rating,
          comment: commentCtrl.text.trim(),
        );
      }

      if (!mounted) return;

      if (result['success']) {
        // Sadece listeyi yenile, local service'e ekleme
        // Çünkü _loadReviews() API'den çekip gösterecek
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(widget.editing != null ? 'Değerlendirmeniz güncellendi' : 'Değerlendirmeniz kaydedildi'),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        
        // Listeyi yenile
        widget.onReviewAdded?.call();
        
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text(result['error'] ?? 'İşlem başarısız'),
              ],
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text('Hata: $e'),
              ],
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}
