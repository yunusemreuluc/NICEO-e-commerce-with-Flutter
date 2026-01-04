import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  List<dynamic> _addresses = [];
  List<dynamic> _paymentMethods = [];
  bool _isLoading = true;
  bool _isProcessing = false;
  
  String? _selectedAddressId;
  String? _selectedPaymentMethodId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      // Adresleri yükle
      final addressResult = await ApiService.getAddresses();
      final paymentResult = await ApiService.getPaymentMethods();
      
      if (addressResult['success']) {
        _addresses = addressResult['data']['addresses'];
        // Varsayılan adresi seç
        final defaultAddress = _addresses.firstWhere(
          (addr) => addr['is_default'] == 1,
          orElse: () => _addresses.isNotEmpty ? _addresses.first : null,
        );
        if (defaultAddress != null) {
          _selectedAddressId = defaultAddress['id'].toString();
        }
      }
      
      if (paymentResult['success']) {
        _paymentMethods = paymentResult['data']['payment_methods'];
        // Varsayılan ödeme yöntemini seç
        final defaultPayment = _paymentMethods.firstWhere(
          (payment) => payment['is_default'] == 1,
          orElse: () => _paymentMethods.isNotEmpty ? _paymentMethods.first : null,
        );
        if (defaultPayment != null) {
          _selectedPaymentMethodId = defaultPayment['id'].toString();
        }
      }
      
    } catch (e) {
      print('❌ Veri yükleme hatası: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processOrder() async {
    if (_selectedAddressId == null || _selectedPaymentMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen adres ve ödeme yöntemi seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cartService = Provider.of<CartService>(context, listen: false);
    if (cartService.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sepetiniz boş'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Seçilen adres ve ödeme bilgilerini al
      final selectedAddress = _addresses.firstWhere(
        (addr) => addr['id'].toString() == _selectedAddressId,
      );
      final selectedPayment = _paymentMethods.firstWhere(
        (payment) => payment['id'].toString() == _selectedPaymentMethodId,
      );

      // Local sepetteki ürün bilgilerini hazırla
      final cartItems = cartService.items.map((item) {
        // Fiyatı sayısal hale getir
        double itemPrice = 0;
        try {
          final priceStr = item.price.replaceAll('₺', '').replaceAll('.', '').replaceAll(',', '');
          itemPrice = double.parse(priceStr);
        } catch (e) {
          itemPrice = 999; // Varsayılan fiyat
        }

        return {
          'id': item.id,
          'name': item.name,
          'price': itemPrice.toString(),
          'quantity': item.quantity,
          'image': item.image,
        };
      }).toList();

      print('🛒 Sipariş için hazırlanan ürünler:');
      for (final item in cartItems) {
        print('  - ${item['name']} x${item['quantity']} = ₺${item['price']}');
      }

      // Sipariş oluştur - local sepet bilgilerini gönder
      final result = await ApiService.createOrderWithItems(
        shippingAddress: '${selectedAddress['title']} - ${selectedAddress['full_address']}, ${selectedAddress['district']}, ${selectedAddress['city']}',
        paymentMethod: '${selectedPayment['card_name']} (**** ${selectedPayment['card_number'].toString().substring(selectedPayment['card_number'].toString().length - 4)})',
        cartItems: cartItems,
      );

      if (result['success']) {
        // Local sepeti temizle
        cartService.clearCart();

        // Başarı mesajı göster
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Siparişiniz Alındı!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sipariş No: #${result['data']['order']['id']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Siparişiniz başarıyla oluşturuldu. Profil > Siparişlerim bölümünden takip edebilirsiniz.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Dialog'u kapat
                    Navigator.of(context).pop(); // Checkout sayfasını kapat
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tamam',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Sipariş oluşturulamadı'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Sipariş hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatTL = NumberFormat.currency(
      locale: "tr_TR",
      symbol: "₺",
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          'Ödeme',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<CartService>(
              builder: (context, cartService, child) {
                final totalAmount = cartService.totalPrice * 0.95; // %5 indirim

                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Teslimat Adresi
                          _buildSection(
                            title: 'Teslimat Adresi',
                            icon: Icons.location_on_outlined,
                            child: _addresses.isEmpty
                                ? _buildEmptyState(
                                    'Kayıtlı adres bulunamadı',
                                    'Profil > Adres Defterim\'den adres ekleyin',
                                  )
                                : Column(
                                    children: _addresses.map((address) {
                                      final isSelected = _selectedAddressId == address['id'].toString();
                                      return _buildAddressCard(address, isSelected);
                                    }).toList(),
                                  ),
                          ),

                          const SizedBox(height: 16),

                          // Ödeme Yöntemi
                          _buildSection(
                            title: 'Ödeme Yöntemi',
                            icon: Icons.credit_card_outlined,
                            child: _paymentMethods.isEmpty
                                ? _buildEmptyState(
                                    'Kayıtlı kart bulunamadı',
                                    'Profil > Ödeme Yöntemlerim\'den kart ekleyin',
                                  )
                                : Column(
                                    children: _paymentMethods.map((payment) {
                                      final isSelected = _selectedPaymentMethodId == payment['id'].toString();
                                      return _buildPaymentCard(payment, isSelected);
                                    }).toList(),
                                  ),
                          ),

                          const SizedBox(height: 16),

                          // Sipariş Özeti
                          _buildSection(
                            title: 'Sipariş Özeti',
                            icon: Icons.receipt_outlined,
                            child: Column(
                              children: [
                                ...cartService.items.map((item) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item.name} x${item.quantity}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      Text(
                                        formatTL.format(
                                          (double.tryParse(item.price.replaceAll('₺', '').replaceAll('.', '')) ?? 0) * item.quantity,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                                const Divider(height: 16),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Ara Toplam',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Text(
                                      formatTL.format(cartService.totalPrice),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'İndirim (%5)',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Text(
                                      '-${formatTL.format(cartService.totalPrice * 0.05)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Kargo',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Text(
                                      'Ücretsiz',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 16),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Toplam',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      formatTL.format(totalAmount),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Ödeme Butonu
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _processOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Siparişi Tamamla - ${formatTL.format(totalAmount)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.black87),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(dynamic address, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAddressId = address['id'].toString();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address['title'] ?? 'Adres',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${address['full_address']}, ${address['district']}, ${address['city']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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

  Widget _buildPaymentCard(dynamic payment, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethodId = payment['id'].toString();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.credit_card,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment['card_name'] ?? 'Kart',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '**** **** **** ${payment['card_number'].toString().substring(payment['card_number'].toString().length - 4)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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

  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}