const axios = require('axios');

const baseURL = 'http://localhost:4003/api';

async function testAPI() {
  try {
    console.log('🧪 API Testleri başlıyor...\n');

    // 1. Health Check
    console.log('1️⃣ Health Check...');
    const health = await axios.get(`${baseURL}/health`);
    console.log('✅', health.data.message);

    // 2. Kategoriler
    console.log('\n2️⃣ Kategoriler...');
    const categories = await axios.get(`${baseURL}/categories`);
    console.log('✅', `${categories.data.categories.length} kategori bulundu`);

    // 3. Ürünler
    console.log('\n3️⃣ Ürünler...');
    const products = await axios.get(`${baseURL}/products`);
    console.log('✅', `${products.data.products.length} ürün bulundu`);

    // 4. Kullanıcı Kaydı
    console.log('\n4️⃣ Kullanıcı Kaydı...');
    const registerData = {
      name: 'Test',
      surname: 'Kullanıcı',
      email: 'test@niceo.com',
      phone: '05551234567',
      password: '123456'
    };

    try {
      const register = await axios.post(`${baseURL}/auth/register`, registerData);
      console.log('✅ Kayıt başarılı:', register.data.user.email);
      
      // 5. Kullanıcı Girişi
      console.log('\n5️⃣ Kullanıcı Girişi...');
      const login = await axios.post(`${baseURL}/auth/login`, {
        email: 'test@niceo.com',
        password: '123456'
      });
      console.log('✅ Giriş başarılı:', login.data.user.name);
      
      const token = login.data.token;
      
      // 6. Profil Bilgileri
      console.log('\n6️⃣ Profil Bilgileri...');
      const profile = await axios.get(`${baseURL}/users/profile`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      console.log('✅ Profil alındı:', profile.data.user.email);

      // 7. Favorilere Ekleme
      console.log('\n7️⃣ Favorilere Ekleme...');
      await axios.post(`${baseURL}/favorites`, 
        { product_id: 1 },
        { headers: { Authorization: `Bearer ${token}` } }
      );
      console.log('✅ Favorilere eklendi');

      // 8. Favorileri Getirme
      console.log('\n8️⃣ Favorileri Getirme...');
      const favorites = await axios.get(`${baseURL}/favorites`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      console.log('✅', `${favorites.data.favorites.length} favori bulundu`);

    } catch (authError) {
      if (authError.response?.data?.error?.includes('zaten kayıtlı')) {
        console.log('ℹ️ Kullanıcı zaten kayıtlı, giriş testi yapılıyor...');
        
        const login = await axios.post(`${baseURL}/auth/login`, {
          email: 'test@niceo.com',
          password: '123456'
        });
        console.log('✅ Giriş başarılı:', login.data.user.name);
      } else {
        throw authError;
      }
    }

    console.log('\n🎉 Tüm testler başarılı!');

  } catch (error) {
    console.error('❌ Test hatası:', error.response?.data || error.message);
  }
}

testAPI();