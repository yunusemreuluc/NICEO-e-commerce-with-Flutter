const axios = require('axios');

const baseURL = 'http://localhost:4003/api';

async function addTestData() {
  try {
    console.log('🧪 Test Verisi Ekleniyor...\n');

    // Test kullanıcısı ile giriş yap
    const login = await axios.post(`${baseURL}/auth/login`, {
      email: 'test@niceo.com',
      password: '123456'
    });
    console.log('✅ Giriş başarılı:', login.data.user.name);
    
    const token = login.data.token;
    
    // Sepete ürün ekle
    console.log('\n📦 Sepete ürün ekleniyor...');
    await axios.post(`${baseURL}/cart`, 
      { product_id: 1, quantity: 2 },
      { headers: { Authorization: `Bearer ${token}` } }
    );
    console.log('✅ Ürün 1 sepete eklendi (2 adet)');

    await axios.post(`${baseURL}/cart`, 
      { product_id: 2, quantity: 1 },
      { headers: { Authorization: `Bearer ${token}` } }
    );
    console.log('✅ Ürün 2 sepete eklendi (1 adet)');

    // Favorilere ürün ekle
    console.log('\n❤️ Favorilere ürün ekleniyor...');
    await axios.post(`${baseURL}/favorites`, 
      { product_id: 3 },
      { headers: { Authorization: `Bearer ${token}` } }
    );
    console.log('✅ Ürün 3 favorilere eklendi');

    await axios.post(`${baseURL}/favorites`, 
      { product_id: 4 },
      { headers: { Authorization: `Bearer ${token}` } }
    );
    console.log('✅ Ürün 4 favorilere eklendi');

    // Sipariş oluştur
    console.log('\n🛍️ Sipariş oluşturuluyor...');
    const order = await axios.post(`${baseURL}/orders`, {
      shipping_address: 'Test Mahallesi, Test Sokak No:1, İstanbul',
      payment_method: 'credit_card'
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ Sipariş oluşturuldu:', order.data.order.order_code);

    // Tekrar sepete ürün ekle (yeni sipariş için)
    await axios.post(`${baseURL}/cart`, 
      { product_id: 5, quantity: 1 },
      { headers: { Authorization: `Bearer ${token}` } }
    );
    console.log('✅ Yeni ürün sepete eklendi');

    console.log('\n🎉 Test verisi başarıyla eklendi!');
    console.log('📊 Güncel durum:');
    console.log('- 1 sipariş');
    console.log('- 3 favori ürün');
    console.log('- 1 sepet ürünü');

  } catch (error) {
    console.error('❌ Hata:', error.response?.data || error.message);
  }
}

addTestData();