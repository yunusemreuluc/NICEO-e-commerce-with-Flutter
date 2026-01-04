const axios = require('axios');

const baseURL = 'http://localhost:4003/api';

async function addProfileData() {
  try {
    console.log('🧪 Profil Verisi Ekleniyor...\n');

    // Test kullanıcısı ile giriş yap
    const login = await axios.post(`${baseURL}/auth/login`, {
      email: 'test@niceo.com',
      password: '123456'
    });
    console.log('✅ Giriş başarılı:', login.data.user.name);
    
    const token = login.data.token;
    
    // Adres ekle
    console.log('\n📍 Adres ekleniyor...');
    await axios.post(`${baseURL}/addresses`, {
      title: 'Ev',
      full_address: 'Test Mahallesi, Test Sokak No:1 Daire:5',
      city: 'İstanbul',
      district: 'Kadıköy',
      is_default: true
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ Ev adresi eklendi');

    await axios.post(`${baseURL}/addresses`, {
      title: 'İş',
      full_address: 'İş Merkezi, Ofis Blok A Kat:3',
      city: 'İstanbul',
      district: 'Şişli',
      is_default: false
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ İş adresi eklendi');

    // Ödeme yöntemi ekle
    console.log('\n💳 Ödeme yöntemi ekleniyor...');
    await axios.post(`${baseURL}/payment-methods`, {
      card_name: 'Test Kart',
      card_number: '1234567890123456',
      card_type: 'visa',
      is_default: true
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ Visa kartı eklendi');

    await axios.post(`${baseURL}/payment-methods`, {
      card_name: 'İş Kartı',
      card_number: '9876543210987654',
      card_type: 'mastercard',
      is_default: false
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ Mastercard kartı eklendi');

    console.log('\n🎉 Profil verisi başarıyla eklendi!');
    console.log('📊 Eklenen veriler:');
    console.log('- 2 adres');
    console.log('- 2 ödeme yöntemi');
    console.log('- Kuponlar için ayrı script gerekli (admin işlemi)');

  } catch (error) {
    console.error('❌ Hata:', error.response?.data || error.message);
  }
}

addProfileData();