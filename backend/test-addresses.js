const axios = require('axios');

const baseURL = 'http://localhost:4003/api';

async function testAddresses() {
  try {
    console.log('🧪 Adres Endpoint Testi...\n');

    // Test kullanıcısı ile giriş yap
    const login = await axios.post(`${baseURL}/auth/login`, {
      email: 'test@niceo.com',
      password: '123456'
    });
    console.log('✅ Giriş başarılı:', login.data.user.name);
    console.log('🔑 Token:', login.data.token.substring(0, 20) + '...');
    
    const token = login.data.token;
    
    // Adresleri getir (boş olabilir)
    console.log('\n📍 Adresler getiriliyor...');
    const addresses = await axios.get(`${baseURL}/addresses`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ Adresler alındı:', addresses.data);

  } catch (error) {
    console.error('❌ Hata:', error.response?.data || error.message);
    console.error('📊 Status:', error.response?.status);
    console.error('🔗 URL:', error.config?.url);
  }
}

testAddresses();