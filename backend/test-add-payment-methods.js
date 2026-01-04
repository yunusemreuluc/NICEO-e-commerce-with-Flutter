const axios = require('axios');

const baseURL = 'http://localhost:4003/api';

async function testAddPaymentMethods() {
  try {
    console.log('🧪 Ödeme Yöntemi Ekleme Testi başlıyor...\n');

    // Test kullanıcısı ile giriş yap
    const login = await axios.post(`${baseURL}/auth/login`, {
      email: 'test@niceo.com',
      password: '123456'
    });
    console.log('✅ Giriş başarılı:', login.data.user.name);
    
    const token = login.data.token;
    
    // 1. Visa kartı ekle (varsayılan)
    console.log('\n💳 Visa kartı ekleniyor...');
    const card1 = await axios.post(`${baseURL}/payment-methods`, {
      card_name: 'Ahmet Yılmaz',
      card_number: '4111111111111111',
      card_type: 'visa',
      is_default: true
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ Visa kartı eklendi:', card1.data.payment_method.card_last4);

    // 2. Mastercard ekle
    console.log('\n💳 Mastercard ekleniyor...');
    const card2 = await axios.post(`${baseURL}/payment-methods`, {
      card_name: 'Ahmet Yılmaz',
      card_number: '5555555555554444',
      card_type: 'mastercard',
      is_default: false
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ Mastercard eklendi:', card2.data.payment_method.card_last4);

    // 3. American Express ekle
    console.log('\n💳 American Express ekleniyor...');
    const card3 = await axios.post(`${baseURL}/payment-methods`, {
      card_name: 'Ahmet Yılmaz',
      card_number: '378282246310005',
      card_type: 'amex',
      is_default: false
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ American Express eklendi:', card3.data.payment_method.card_last4);

    // Kartları listele
    console.log('\n📋 Kartlar listeleniyor...');
    const cards = await axios.get(`${baseURL}/payment-methods`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ Toplam kart sayısı:', cards.data.payment_methods.length);
    
    cards.data.payment_methods.forEach((card, index) => {
      console.log(`${index + 1}. ${card.card_type.toUpperCase()} **** ${card.card_last4} ${card.is_default ? '(Varsayılan)' : ''}`);
      console.log(`   ${card.card_name}`);
    });

    console.log('\n🎉 Ödeme yöntemi ekleme testleri başarılı!');

  } catch (error) {
    console.error('❌ Test hatası:', error.response?.data || error.message);
  }
}

testAddPaymentMethods();