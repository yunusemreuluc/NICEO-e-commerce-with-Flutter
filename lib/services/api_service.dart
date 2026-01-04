import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Bilgisayarın gerçek IP adresi
  static const String baseUrl = 'http://10.245.149.212:4003/api';
  static const _storage = FlutterSecureStorage();

  // Token işlemleri
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<void> removeToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // HTTP headers
  static Future<Map<String, String>> _getHeaders({bool needsAuth = false}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (needsAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Auth endpoints
  static Future<Map<String, dynamic>> register({
    required String name,
    required String surname,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      print('🔄 API register isteği gönderiliyor: $baseUrl/auth/register');
      print('📧 Email: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'name': name,
          'surname': surname,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );

      print('📡 API yanıt kodu: ${response.statusCode}');
      print('📄 API yanıt: ${response.body}');

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        await saveToken(data['token']);
        print('✅ API register başarılı');
        return {'success': true, 'data': data};
      } else {
        print('❌ API register başarısız: ${data['error']}');
        return {'success': false, 'error': data['error'] ?? 'Kayıt başarısız'};
      }
    } catch (e) {
      print('❌ API bağlantı hatası: $e');
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        await saveToken(data['token']);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Giriş başarısız'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  // User endpoints
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/profile'),
        headers: await _getHeaders(needsAuth: true),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Profil alınamadı'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String surname,
    required String phone,
    String? avatar,
  }) async {
    try {
      Map<String, dynamic> body = {
        'name': name,
        'surname': surname,
        'phone': phone,
      };
      
      if (avatar != null) {
        body['avatar'] = avatar;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: await _getHeaders(needsAuth: true),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Profil güncellenemedi'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  // Products endpoints
  static Future<Map<String, dynamic>> getProducts({
    int? categoryId,
    String? search,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      String url = '$baseUrl/products?limit=$limit&offset=$offset';
      if (categoryId != null) url += '&category_id=$categoryId';
      if (search != null && search.isNotEmpty) url += '&search=$search';

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Ürünler alınamadı'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  static Future<Map<String, dynamic>> getProduct(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Ürün alınamadı'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  // Categories endpoints
  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Kategoriler alınamadı'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  // Favorites endpoints
  static Future<Map<String, dynamic>> getFavorites() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/favorites'),
        headers: await _getHeaders(needsAuth: true),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Favoriler alınamadı'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  static Future<Map<String, dynamic>> addToFavorites(int productId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/favorites'),
        headers: await _getHeaders(needsAuth: true),
        body: jsonEncode({'product_id': productId}),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Favorilere eklenemedi'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  static Future<Map<String, dynamic>> removeFromFavorites(int productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/favorites/$productId'),
        headers: await _getHeaders(needsAuth: true),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Favorilerden çıkarılamadı'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  // Cart endpoints
  static Future<Map<String, dynamic>> getCart() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cart'),
        headers: await _getHeaders(needsAuth: true),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Sepet alınamadı'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  static Future<Map<String, dynamic>> addToCart(int productId, {int quantity = 1}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart'),
        headers: await _getHeaders(needsAuth: true),
        body: jsonEncode({
          'product_id': productId,
          'quantity': quantity,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Sepete eklenemedi'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  // Orders endpoints
  static Future<Map<String, dynamic>> getOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: await _getHeaders(needsAuth: true),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Siparişler alınamadı'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  static Future<Map<String, dynamic>> createOrder({
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: await _getHeaders(needsAuth: true),
        body: jsonEncode({
          'shipping_address': shippingAddress,
          'payment_method': paymentMethod,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Sipariş oluşturulamadı'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  // Sepet ürünleri ile sipariş oluştur
  static Future<Map<String, dynamic>> createOrderWithItems({
    required String shippingAddress,
    required String paymentMethod,
    required List<Map<String, dynamic>> cartItems,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: await _getHeaders(needsAuth: true),
        body: jsonEncode({
          'shipping_address': shippingAddress,
          'payment_method': paymentMethod,
          'cart_items': cartItems,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Sipariş oluşturulamadı'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  // Health check
  static Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Addresses endpoints
  static Future<Map<String, dynamic>> getAddresses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/addresses'),
        headers: await _getHeaders(needsAuth: true),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': 'Adresler alınamadı'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  static Future<Map<String, dynamic>> addAddress({
    required String title,
    required String fullAddress,
    required String city,
    required String district,
    required bool isDefault,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addresses'),
        headers: await _getHeaders(needsAuth: true),
        body: json.encode({
          'title': title,
          'full_address': fullAddress,
          'city': city,
          'district': district,
          'is_default': isDefault,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['error'] ?? 'Adres eklenemedi'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  static Future<Map<String, dynamic>> setDefaultAddress(int addressId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/addresses/$addressId/default'),
        headers: await _getHeaders(needsAuth: true),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['error'] ?? 'Varsayılan adres yapılamadı'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  // Payment Methods endpoints
  static Future<Map<String, dynamic>> getPaymentMethods() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payment-methods'),
        headers: await _getHeaders(needsAuth: true),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': 'Ödeme yöntemleri alınamadı'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  static Future<Map<String, dynamic>> addPaymentMethod({
    required String cardName,
    required String cardNumber,
    required String cardType,
    required bool isDefault,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payment-methods'),
        headers: await _getHeaders(needsAuth: true),
        body: json.encode({
          'card_name': cardName,
          'card_number': cardNumber,
          'card_type': cardType,
          'is_default': isDefault,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Ödeme yöntemi eklenemedi'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  // Coupons endpoints
  static Future<Map<String, dynamic>> getCoupons() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/coupons'),
        headers: await _getHeaders(needsAuth: true),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': 'Kuponlar alınamadı'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  // Reviews endpoints
  static Future<Map<String, dynamic>> getMyReviews() async {
    try {
      print('🔄 getMyReviews API çağrısı yapılıyor...');
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/my-reviews'),
        headers: await _getHeaders(needsAuth: true),
      );

      print('📊 Response status: ${response.statusCode}');
      print('📊 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ API başarılı, data: $data');
        return {'success': true, 'data': data};
      } else {
        print('❌ API hatası: ${response.statusCode}');
        return {'success': false, 'error': 'Değerlendirmeleriniz alınamadı'};
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  static Future<Map<String, dynamic>> getProductReviews(int productId) async {
    try {
      print('🔄 getProductReviews API çağrısı: productId=$productId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/product/$productId'),
        headers: await _getHeaders(needsAuth: false),
      );

      print('📊 Response status: ${response.statusCode}');
      print('📊 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ API başarılı, ${data['reviews']?.length ?? 0} yorum alındı');
        return {'success': true, 'data': data};
      } else {
        print('❌ API hatası: ${response.statusCode}');
        final errorData = json.decode(response.body);
        return {'success': false, 'error': errorData['error'] ?? 'Ürün yorumları alınamadı'};
      }
    } catch (e) {
      print('❌ getProductReviews Exception: $e');
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  static Future<Map<String, dynamic>> addReview({
    required int productId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews'),
        headers: await _getHeaders(needsAuth: true),
        body: json.encode({
          'product_id': productId,
          'rating': rating,
          'comment': comment,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Yorum eklenemedi'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteReview(String reviewId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/reviews/$reviewId'),
        headers: await _getHeaders(needsAuth: true),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = json.decode(response.body);
        return {'success': false, 'error': data['error'] ?? 'Yorum silinemedi'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateReview({
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/reviews/$reviewId'),
        headers: await _getHeaders(needsAuth: true),
        body: json.encode({
          'rating': rating,
          'comment': comment,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Yorum güncellenemedi'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  // Change password
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/change-password'),
        headers: await _getHeaders(needsAuth: true),
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Şifre değiştirilemedi'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }
}