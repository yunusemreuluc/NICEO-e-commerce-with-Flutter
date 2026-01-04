import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:niceo/pages/profile/app_settings_page.dart';
import 'package:niceo/pages/profile/help_center_page.dart';
import 'package:niceo/pages/profile/my_reviews_page.dart';
import 'package:niceo/pages/profile/notifications_page.dart';
import 'package:niceo/pages/profile/orders_page.dart';
import 'package:niceo/pages/profile/address_book_page.dart';
import 'package:niceo/pages/profile/payment_methods_page.dart';
import 'package:niceo/pages/profile/coupons_page.dart';
import 'package:niceo/pages/profile/security_page.dart';
import 'package:niceo/pages/profile/edit_profile_page.dart';
import 'package:niceo/pages/login_page.dart';
import 'package:niceo/services/auth_service.dart';
import 'package:niceo/services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userStats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  static String _getMembershipStatus(String? createdAt) {
    if (createdAt == null) return "Aktif Üye";
    
    try {
      final created = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(created).inDays;
      
      if (difference < 7) {
        return "Yeni Üye";
      } else if (difference < 30) {
        return "Aktif Üye";
      } else if (difference < 365) {
        return "Deneyimli Üye";
      } else {
        return "Uzun Süreli Üye";
      }
    } catch (e) {
      return "Aktif Üye";
    }
  }

  Future<void> _loadUserStats() async {
    try {
      // Favorileri al
      final favResult = await ApiService.getFavorites();
      final favoriteCount = favResult['success'] ? favResult['data']['favorites'].length : 0;

      // Sepeti al
      final cartResult = await ApiService.getCart();
      final cartCount = cartResult['success'] ? cartResult['data']['cart'].length : 0;

      // Siparişleri al
      final ordersResult = await ApiService.getOrders();
      final orderCount = ordersResult['success'] ? ordersResult['data']['orders'].length : 0;

      // Adresleri al
      final addressResult = await ApiService.getAddresses();
      final addressCount = addressResult['success'] ? addressResult['data']['addresses'].length : 0;

      // Ödeme yöntemleri sayısını al
      final paymentMethodsResult = await ApiService.getPaymentMethods();
      final paymentMethodsCount = paymentMethodsResult['success'] ? paymentMethodsResult['data']['payment_methods'].length : 0;

      // Değerlendirmeler sayısını al
      final reviewsResult = await ApiService.getMyReviews();
      final reviewsCount = reviewsResult['success'] ? reviewsResult['data']['reviews'].length : 0;

      setState(() {
        userStats = {
          'orders': orderCount,
          'favorites': favoriteCount,
          'cart': cartCount,
          'addresses': addressCount,
          'payment_methods': paymentMethodsCount,
          'reviews': reviewsCount,
          'coupons': 0, // Şimdilik 0, API çalışmıyor
        };
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        userStats = {
          'orders': 0,
          'favorites': 0,
          'cart': 0,
          'addresses': 0,
          'payment_methods': 0,
          'reviews': 0,
          'coupons': 0,
        };
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Kullanıcı bilgisi bulunamadı')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ====== HERO HEADER (AppBar yok) ======
              _HeroHeader(
                user: user,
                onEdit: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfilePage(),
                    ),
                  );
                  // Profil düzenleme sayfasından döndüğünde kullanıcı verilerini yenile
                  if (result == true) {
                    setState(() {
                      // Sayfa yenilenecek - AuthService zaten refreshUser() çağırıyor
                    });
                  }
                },
              ),

              // ====== HIZLI ÖZET KARTLARI ======
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.shopping_bag_outlined,
                            value: "${userStats!['orders']}",
                            label: "Sipariş",
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.favorite_border,
                            value: "${userStats!['favorites']}",
                            label: "Favori",
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.shopping_cart_outlined,
                            value: "${userStats!['cart']}",
                            label: "Sepet",
                          ),
                        ),
                      ],
                    ),
              ),

              const SizedBox(height: 14),

              // ====== MENÜLER ======
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _SettingTile(
                      icon: Icons.receipt_long_outlined,
                      color: const Color(0xFF5B8DEF),
                      title: "Siparişlerim",
                      subtitle: "${userStats?['orders'] ?? 0} sipariş",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const OrdersPage()),
                        );
                      },
                    ),
                    _SettingTile(
                      icon: Icons.location_on_outlined,
                      color: const Color(0xFF8B5CF6),
                      title: "Adres Defterim",
                      subtitle: "${userStats?['addresses'] ?? 0} kayıtlı adres",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddressBookPage(),
                          ),
                        );
                      },
                    ),
                    _SettingTile(
                      icon: Icons.credit_card_outlined,
                      color: const Color(0xFF1ABC9C),
                      title: "Ödeme Yöntemlerim",
                      subtitle: "${userStats?['payment_methods'] ?? 0} kayıtlı kart",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PaymentMethodsPage(),
                          ),
                        );
                      },
                    ),
                    _SettingTile(
                      icon: Icons.star_border_rounded,
                      color: const Color(0xFFFFB800),
                      title: "Değerlendirmelerim",
                      subtitle: "${userStats?['reviews'] ?? 0} değerlendirme",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyReviewsPage(),
                          ),
                        );
                      },
                    ),
                    _SettingTile(
                      icon: Icons.card_giftcard_outlined,
                      color: const Color(0xFFFF6B81),
                      title: "Kuponlarım",
                      subtitle: "${userStats?['coupons'] ?? 0} aktif kupon",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CouponsPage(),
                          ),
                        );
                      },
                    ),
                    _SettingTile(
                      icon: Icons.notifications_none_rounded,
                      color: const Color(0xFFFFB020),
                      title: "Bildirimler",
                      subtitle: "Push ve e-posta ayarları",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsPage(),
                          ),
                        );
                      },
                    ),

                    _SettingTile(
                      icon: Icons.lock_outline,
                      color: const Color(0xFF6C757D),
                      title: "Gizlilik & Güvenlik",
                      subtitle: "Hesap koruması",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SecurityPage(),
                          ),
                        );
                      },
                    ),
                    _SettingTile(
                      icon: Icons.help_outline_rounded,
                      color: const Color(0xFF00B8D9),
                      title: "Yardım Merkezi",
                      subtitle: "SSS ve canlı destek",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HelpCenterPage(),
                          ),
                        );
                      },
                    ),
                    _SettingTile(
                      icon: Icons.settings_outlined,
                      color: const Color(0xFF111827),
                      title: "Uygulama Ayarları",
                      subtitle: "Tema, dil ve bildirim tercihleri",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AppSettingsPage(),
                          ),
                        );
                      },
                    ),
                    _SettingTile(
                      icon: Icons.logout_rounded,
                      color: const Color(0xFFE11D48),
                      title: "Güvenli Çıkış",
                      subtitle: "Hesabınızdan çıkış yapın",
                      destructive: true,
                      onTap: () async {
                        await auth.logout();
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    Text(
                      "NICEO v2.1.0",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Made with ❤️ in Turkey",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====== HERO HEADER BÖLÜMÜ ======
class _HeroHeader extends StatelessWidget {
  final dynamic user;
  final VoidCallback onEdit;
  const _HeroHeader({required this.user, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Kapak
        Container(
          height: 150,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1F2937)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Edit (kamera ikonlu) sağ üst
        Positioned(
          right: 16,
          top: 12,
          child: ElevatedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.photo_camera_outlined, size: 18),
            label: const Text("Düzenle"),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        // Avatar + bilgiler
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 110, 16, 0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF0F1F5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // avatar
                  Stack(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(34),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user.avatar ?? '👤',
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // bilgiler
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // isim + edit
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${user.name} ${user.surname}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EditProfilePage(),
                                  ),
                                );
                                // Profil düzenleme sayfasından döndüğünde kullanıcı verilerini yenile
                                if (result == true) {
                                  onEdit(); // Call the callback to refresh parent
                                }
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFFF6F7FB),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Düzenle",
                                style: TextStyle(color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // üyelik durumu
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF7EE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _ProfilePageState._getMembershipStatus(user.createdAt),
                            style: const TextStyle(
                              color: Color(0xFF22C55E),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // mail
                        Row(
                          children: [
                            const Icon(
                              Icons.mail_outline,
                              size: 18,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                user.email,
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // telefon
                        if (user.phone.isNotEmpty)
                          Row(
                            children: [
                              const Icon(
                                Icons.phone_outlined,
                                size: 18,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                user.phone,
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ====== KÜÇÜK BİLEŞENLER ======
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F1F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: Colors.black87),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final bool destructive;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.destructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F1F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: destructive ? const Color(0xFFE11D48) : Colors.black,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(subtitle!, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.black45,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }
}

// Basit boş sayfa (navigasyon hedefi)
class EmptyPage extends StatelessWidget {
  final String title;
  const EmptyPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Center(
        child: Text(
          "$title sayfası (şimdilik boş)",
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
