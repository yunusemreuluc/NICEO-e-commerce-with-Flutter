import 'package:flutter/material.dart';

class Review {
  final String id; // UUID veya benzeri
  final String productId;
  final String productName;
  final String? productImage; // kartta gösterilecek
  final Map<String, dynamic>? productPayload; // ProductDetailPage’e geçmek için

  final String? userId; // Yorumun sahibi

  int rating;
  String title;
  String body;
  DateTime createdAt;

  Review({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    this.productPayload,
    this.userId,
    required this.rating,
    required this.title,
    required this.body,
    required this.createdAt,
  });
}

class ReviewService extends ChangeNotifier {
  final List<Review> _reviews = [];

  List<Review> get userReviews => List.unmodifiable(_reviews);

  List<Review> reviewsForProduct(String productId) =>
      _reviews.where((r) => r.productId == productId).toList();

  void addReview({
    required String id,
    required String productId,
    required String productName,
    String? productImage,
    Map<String, dynamic>? productPayload,
    String? userId,
    required int rating,
    required String title,
    required String body,
    DateTime? createdAt,
  }) {
    _reviews.add(
      Review(
        id: id,
        productId: productId,
        productName: productName,
        productImage: productImage,
        productPayload: productPayload,
        userId: userId,
        rating: rating,
        title: title,
        body: body,
        createdAt: createdAt ?? DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void updateReview(String id, {int? rating, String? title, String? body}) {
    final i = _reviews.indexWhere((r) => r.id == id);
    if (i == -1) return;
    final r = _reviews[i];
    _reviews[i] = Review(
      id: r.id,
      productId: r.productId,
      productName: r.productName,
      productImage: r.productImage,
      productPayload: r.productPayload,
      userId: r.userId,
      rating: rating ?? r.rating,
      title: title ?? r.title,
      body: body ?? r.body,
      createdAt: r.createdAt,
    );
    notifyListeners();
  }

  void deleteReview(String id) {
    _reviews.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
